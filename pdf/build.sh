#!/usr/bin/env bash
# Builds TLCL-Persian.pdf from the Markdown chapters in ../Book
# Usage: bash pdf/build.sh          (whole book)
#        bash pdf/build.sh 09 24    (only the listed chapters, for quick tests)
set -euo pipefail
cd "$(dirname "$0")"

if [ "$#" -gt 0 ]; then
  dirs=()
  for n in "$@"; do dirs+=("../Book/$n/"); done
else
  dirs=(../Book/*/)
fi

rm -rf build
mkdir -p build
: > build/chapters.tex

for dir in "${dirs[@]}"; do
  for md in "$dir"*.md; do
    [ -e "$md" ] || continue
    name="$(basename "$dir")-$(basename "$md" .md)"
    pandoc "$md" -f gfm -t latex --top-level-division=chapter \
      --lua-filter=tlcl.lua -o "build/$name.tex"
    echo "\\input{build/$name}" >> build/chapters.tex
  done
done

for _ in 1 2; do
  xelatex -interaction=nonstopmode -halt-on-error main.tex > /dev/null \
    || { tail -n 40 main.log; exit 1; }
done
mv main.pdf TLCL-Persian.pdf
echo "Done: pdf/TLCL-Persian.pdf"

