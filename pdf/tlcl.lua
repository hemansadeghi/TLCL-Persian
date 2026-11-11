-- Pandoc filter that adapts TLCL-Persian chapters to main.tex

local input = PANDOC_STATE.input_files[1] or ""
local chapter_dir = pandoc.path.directory(input)
local is_intro = input:find("/00/") ~= nil

local function tex_escape(s)
  local map = {
    ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}",
    ["#"] = "\\#", ["$"] = "\\$", ["%"] = "\\%", ["&"] = "\\&",
    ["_"] = "\\_", ["^"] = "\\textasciicircum{}", ["~"] = "\\textasciitilde{}",
  }
  return (s:gsub("[\\{}#%$%%&_%^~]", map))
end

-- Inside CodeVerbatim only \ { } are special (commandchars)
local function verb_escape(s)
  return (s:gsub("[\\{}]", { ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}" }))
end

-- Left-to-right island inside Persian text; plain text for PDF bookmarks
local function ltr(tex, plain)
  return pandoc.RawInline("latex",
    "\\texorpdfstring{\\lr{" .. tex .. "}}{" .. tex_escape(plain) .. "}")
end

local function is_ascii(s) return s:find("^[!-~]+$") ~= nil end

function Code(el)
  return ltr("\\texttt{" .. tex_escape(el.text) .. "}", el.text)
end

function Link(el)
  local target = el.target
  if pandoc.utils.stringify(el.content) == target then
    local url = target:gsub("[%%#]", { ["%"] = "\\%", ["#"] = "\\#" })
    return pandoc.RawInline("latex", "\\lr{\\url{" .. url .. "}}")
  end
  -- Links between chapter files have no meaning in a single PDF
  if not target:find("^%a+:") and not target:find("^#") then
    return el.content
  end
end

function Image(el)
  local src = el.src
  if src:find("^https?://") then
    return ltr("\\url{" .. src:gsub("[%%#]", { ["%"] = "\\%", ["#"] = "\\#" }) .. "}", src)
  end
  if not pandoc.path.is_absolute(src) then
    src = pandoc.path.join({ chapter_dir, src })
  end
  return pandoc.RawInline("latex",
    "\\includegraphics[width=\\linewidth,height=0.5\\textheight,keepaspectratio]{" .. src .. "}")
end

-- Group consecutive English words so their order survives in RTL text
function Inlines(inlines)
  local out = pandoc.Inlines{}
  local i = 1
  while i <= #inlines do
    local el = inlines[i]
    if el.t == "Str" and is_ascii(el.text) and el.text:find("%a") then
      local words = { el.text }
      local j = i + 1
      while j + 1 <= #inlines and inlines[j].t == "Space"
            and inlines[j + 1].t == "Str" and is_ascii(inlines[j + 1].text) do
        table.insert(words, inlines[j + 1].text)
        j = j + 2
      end
      local text = table.concat(words, " ")
      out:insert(ltr(tex_escape(text), text))
      i = j
    else
      out:insert(el)
      i = i + 1
    end
  end
  return out
end

-- "فصل ۹ – مجوزها" -> "مجوزها", since the template prints the chapter number
local function strip_chapter_prefix(content)
  if #content < 3 or content[1].t ~= "Str" or content[1].text ~= "فصل" then
    return content
  end
  for k = 2, math.min(#content, 8) do
    local c = content[k]
    if c.t == "Str" and (c.text == "–" or c.text == "-" or c.text == "—"
                         or c.text:sub(-1) == ":") then
      local rest = pandoc.Inlines{}
      for m = k + 1, #content do rest:insert(content[m]) end
      while #rest > 0 and rest[1].t == "Space" do rest:remove(1) end
      return rest
    end
  end
  return content
end

function Header(el)
  if el.level == 1 then
    el.content = strip_chapter_prefix(el.content)
  end
  if is_intro then
    el.classes:insert("unnumbered")
    if el.level == 1 then
      local title = tex_escape(pandoc.utils.stringify(el.content))
      return { el, pandoc.RawBlock("latex", "\\markboth{" .. title .. "}{" .. title .. "}") }
    end
  end
  return el
end

function HorizontalRule()
  return {}
end

function CodeBlock(el)
  local lines = {}
  for line in (el.text .. "\n"):gmatch("(.-)\n") do
    -- First Arabic-script byte: the rest of the line is a Persian comment
    local i = line:find("[\216-\219]")
    if i then
      line = verb_escape(line:sub(1, i - 1)) .. "\\codefa{" .. verb_escape(line:sub(i)) .. "}"
    else
      line = verb_escape(line)
    end
    table.insert(lines, line)
  end
  return pandoc.RawBlock("latex",
    "\\begin{latin}\\begin{codebox}\n\\begin{CodeVerbatim}\n"
    .. table.concat(lines, "\n")
    .. "\n\\end{CodeVerbatim}\n\\end{codebox}\\end{latin}")
end

-- "> **نکته:** ..." -> notebox, "> **هشدار:** ..." -> warnbox
local box_for = {
  ["نکته"] = "notebox", ["ترفند"] = "notebox",
  ["هشدار"] = "warnbox", ["توجه"] = "warnbox", ["احتیاط"] = "warnbox",
}

function BlockQuote(el)
  local first = el.content[1]
  if not (first and first.t == "Para" and first.content[1]
          and first.content[1].t == "Strong") then
    return nil
  end
  local label = pandoc.utils.stringify(first.content[1]):gsub("[:%s]+$", "")
  local env = box_for[label]
  if not env then return nil end
  first.content:remove(1)
  while #first.content > 0
        and (first.content[1].t == "Space" or first.content[1].t == "SoftBreak") do
    first.content:remove(1)
  end
  local blocks = pandoc.Blocks{ pandoc.RawBlock("latex", "\\begin{" .. env .. "}[" .. label .. "]") }
  blocks:extend(el.content)
  blocks:insert(pandoc.RawBlock("latex", "\\end{" .. env .. "}"))
  return blocks
end

-- Give every table column an explicit width so long cells wrap instead of
-- running off the page. Widths follow the longest text in each column.
local function cell_text(cell)
  local contents = cell.contents:walk {
    RawInline = function(r)
      local plain = r.text:match("\\texorpdfstring{.*}{(.*)}$")
                    or r.text:gsub("\\%a+", ""):gsub("[{}]", "")
      return pandoc.Str(plain)
    end
  }
  local s = pandoc.utils.stringify(contents)
  return utf8.len(s) or #s
end

function Table(tbl)
  local n = #tbl.colspecs
  local longest = {}
  for i = 1, n do longest[i] = 1 end

  local function scan(rows)
    for _, row in ipairs(rows) do
      local col = 1
      for _, cell in ipairs(row.cells) do
        local span = cell.col_span or 1
        if span == 1 and col <= n then
          longest[col] = math.max(longest[col], cell_text(cell))
        end
        col = col + span
      end
    end
  end

  scan(tbl.head.rows)
  for _, body in ipairs(tbl.bodies) do
    scan(body.head)
    scan(body.body)
  end

  -- Square root keeps short columns (commands) from being squeezed too thin
  local weights, total = {}, 0
  for i = 1, n do
    weights[i] = math.sqrt(longest[i])
    total = total + weights[i]
  end
  for i = 1, n do
    tbl.colspecs[i] = { tbl.colspecs[i][1], weights[i] / total }
  end
  return tbl
end

-- Commands written after a shell prompt without a code fence,
-- e.g. "[me@linuxbox ~]$ pwd", become code blocks
local function is_prompt(line)
  return line:find("^%[[^%]]+%][%$#]") ~= nil
end

local function split_prompt_lines(el)
  local lines, cur = {}, pandoc.Inlines{}
  for _, x in ipairs(el.content) do
    if x.t == "SoftBreak" or x.t == "LineBreak" then
      table.insert(lines, cur)
      cur = pandoc.Inlines{}
    else
      cur:insert(x)
    end
  end
  table.insert(lines, cur)

  local first
  for i, line in ipairs(lines) do
    if is_prompt(pandoc.utils.stringify(line)) then
      first = i
      break
    end
  end
  if not first then return nil end

  local out = pandoc.Blocks{}
  if first > 1 then
    local prose = pandoc.Inlines{}
    for i = 1, first - 1 do
      if i > 1 then prose:insert(pandoc.LineBreak()) end
      prose:extend(lines[i])
    end
    out:insert(el.t == "Para" and pandoc.Para(prose) or pandoc.Plain(prose))
  end
  local code = {}
  for i = first, #lines do
    table.insert(code, pandoc.utils.stringify(lines[i]))
  end
  out:insert(pandoc.CodeBlock(table.concat(code, "\n")))
  return out
end

-- Prompts must be found before English words are wrapped in \lr{},
-- so this runs as a separate first pass
return {
  { Para = split_prompt_lines, Plain = split_prompt_lines },
  {
    Code = Code, Link = Link, Image = Image, Inlines = Inlines,
    Header = Header, HorizontalRule = HorizontalRule,
    CodeBlock = CodeBlock, BlockQuote = BlockQuote,
  },
}