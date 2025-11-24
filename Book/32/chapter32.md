# ۳۲ – پارامترهای موضعی (Positional Parameters)

یکی از قابلیت‌هایی که تاکنون در برنامه‌هایمان وجود نداشت، توانایی دریافت و پردازش گزینه‌ها و آرگومان‌های خط فرمان بود. در این فصل، ویژگی‌های شِل را بررسی می‌کنیم که به برنامه‌های ما اجازه می‌دهد به محتوای خط فرمان دسترسی پیدا کنند.

---

## **دسترسی به خط فرمان**

شِل مجموعه‌ای از متغیرها به نام **پارامترهای موضعی** در اختیار قرار می‌دهد که شامل تک‌تک کلمات موجود در خط فرمان هستند. نام این متغیرها از **۰ تا ۹** است. می‌توان آن‌ها را به این شکل نشان داد:

```bash
#!/bin/bash
# posit-param: script to view command line parameters
echo "
\$0 = $0 
\$1 = $1 
\$2 = $2 
\$3 = $3 
\$4 = $4 
\$5 = $5 
\$6 = $6 
\$7 = $7 
\$8 = $8 
\$9 = $9 
"
```

این یک اسکریپت بسیار ساده است که مقدار متغیرهای `$0` تا `$9` را نمایش می‌دهد.

وقتی بدون هیچ آرگومان خط فرمانی اجرا شود:

```
[me@linuxbox ~]$ posit-param
$0 = /home/me/bin/posit-param
$1 =
$2 =
$3 =
$4 =
$5 =
$6 =
$7 =
$8 =
$9 =
```

حتی زمانی که هیچ آرگومانی ارائه نشود، `$0` همیشه شامل اولین آیتم ظاهرشده در خط فرمان است، یعنی مسیر برنامه‌ای که در حال اجرا است.

وقتی آرگومان‌ها ارائه شوند، نتیجه را می‌بینیم:

```
[me@linuxbox ~]$ posit-param a b c d
$0 = /home/me/bin/posit-param
$1 = a
$2 = b
$3 = c
$4 = d
$5 =
$6 =
$7 =
$8 =
$9 =
```

**نکته:**
در واقع می‌توانید به بیش از ۹ پارامتر نیز با استفاده از **گسترش پارامترها (parameter expansion)** دسترسی داشته باشید. برای مشخص کردن عددی بزرگ‌تر از ۹، باید آن را داخل آکولاد قرار دهید.
مثلاً: `${10}`, `${55}`, `${211}` و غیره.

---

## **تعیین تعداد آرگومان‌ها**

شِل همچنین متغیری به نام `$#` فراهم می‌کند که تعداد آرگومان‌های موجود در خط فرمان را برمی‌گرداند:

```bash
#!/bin/bash
# posit-param: script to view command line parameters
echo "
Number of arguments: $#
\$0 = $0
\$1 = $1
\$2 = $2
\$3 = $3
\$4 = $4
\$5 = $5
\$6 = $6
\$7 = $7
\$8 = $8
\$9 = $9
"
```

نتیجه:

```
[me@linuxbox ~]$ posit-param a b c d
Number of arguments: 4
$0 = /home/me/bin/posit-param
$1 = a
$2 = b
$3 = c
$4 = d
$5 =
$6 =
$7 =
$8 =
$9 =
```

---

## **shift – دسترسی به تعداد زیادی آرگومان**

اما چه اتفاقی می‌افتد وقتی تعداد زیادی آرگومان به برنامه بدهیم؟ مثلاً:

```
[me@linuxbox ~]$ posit-param *
Number of arguments: 82
$0 = /home/me/bin/posit-param
$1 = addresses.ldif
$2 = bin
$3 = bookmarks.html
$4 = debian-500-i386-netinst.iso
$5 = debian-500-i386-netinst.jigdo
$6 = debian-500-i386-netinst.template
$7 = debian-cd_info.tar.gz
$8 = Desktop
$9 = dirlist-bin.txt
```

در این سیستم نمونه، wildcard یعنی `*` به ۸۲ آرگومان توسعه می‌یابد. چطور می‌توانیم این تعداد را پردازش کنیم؟

شِل روشی (البته کمی دست‌وپاگیر) برای انجام این کار ارائه می‌دهد. دستور **shift** باعث می‌شود پارامترها هر بار که این دستور اجرا می‌شود، “یک خانه به پایین منتقل شوند”.

در واقع، با استفاده از **shift** حتی می‌توان تنها با یک پارامتر (به‌جز `$0` که هرگز تغییر نمی‌کند) همه آرگومان‌ها را پردازش کرد:

```bash
#!/bin/bash
# posit-param2: script to display all arguments
count=1
while [[ $# -gt 0 ]]; do
    echo "Argument $count = $1"
    count=$((count + 1))
    shift
done
```

هر بار که `shift` اجرا می‌شود:

* مقدار `$2` به `$1` منتقل می‌شود
* مقدار `$3` به `$2` منتقل می‌شود
* همین‌طور تا انتها
* و مقدار `$#` نیز یک واحد کاهش می‌یابد

در برنامهٔ **posit-param2** یک حلقه ایجاد کرده‌ایم که تعداد آرگومان‌های باقی‌مانده را بررسی می‌کند و تا وقتی حداقل یک آرگومان وجود دارد ادامه می‌دهد.
در هر تکرار:

1. آرگومان فعلی نمایش داده می‌شود
2. شمارنده یک واحد افزایش می‌یابد
3. با `shift` مقدار بعدی جایگزین `$1` می‌شود

نمونهٔ اجرا:

```
[me@linuxbox ~]$ posit-param2 a b c d
Argument 1 = a
Argument 2 = b
Argument 3 = c
Argument 4 = d
```

---

## **کاربردهای ساده**

حتی بدون shift نیز می‌توان برنامه‌های کاربردی با استفاده از پارامترهای موضعی نوشت. برای مثال، یک برنامهٔ سادهٔ نمایش اطلاعات فایل:

```bash
#!/bin/bash
# file_info: simple file information program
PROGNAME=$(basename $0)

if [[ -e $1 ]]; then
    echo -e "\nFile Type:"
    file $1
    echo -e "\nFile Status:"
    stat $1
else
    echo "$PROGNAME: usage: $PROGNAME file" >&2
    exit 1
fi
```

این برنامه نوع فایل (با دستور `file`) و وضعیت فایل (با دستور `stat`) را برای فایلی که مشخص شده، نمایش می‌دهد.

یک ویژگی جالب در این برنامه استفاده از متغیر **PROGNAME** است. این متغیر نتیجهٔ دستور:

```
basename $0
```

را دریافت می‌کند. دستور `basename` بخش ابتدایی مسیر را حذف می‌کند و فقط نام اصلی فایل را باقی می‌گذارد.
در این مثال، نام برنامهٔ در حال اجرا بدون مسیر جلوتر به دست می‌آید. این برای ساخت پیام‌هایی مانند پیام usage بسیار مفید است، زیرا اگر اسکریپت تغییر نام داده شود، پیام به‌طور خودکار با نام جدید تطبیق پیدا می‌کند.

---

## **استفاده از پارامترهای موضعی در توابع شِل**

پارامترهای موضعی فقط برای اسکریپت‌ها نیستند؛ می‌توان از آن‌ها برای ارسال آرگومان به توابع شِل نیز استفاده کرد.

برای نشان دادن این موضوع، نسخهٔ تابعیِ اسکریپت file_info را می‌نویسیم:

```bash
file_info () {
    # file_info: function to display file information
    if [[ -e $1 ]]; then
        echo -e "\nFile Type:"
        file $1
        echo -e "\nFile Status:"
        stat $1
    else
        echo "$FUNCNAME: usage: $FUNCNAME file" >&2
        return 1
    fi
}
```

حال اگر اسکریپتی که این تابع را دارد، تابع `file_info` را با یک نام فایل فراخوانی کند، آرگومان به تابع ارسال می‌شود.

با این قابلیت، می‌توان توابع شِل بسیار مفیدی نوشت که نه‌تنها در اسکریپت‌ها بلکه داخل فایل `.bashrc` نیز قابل‌استفاده‌اند.

دقت کنید که در نسخهٔ تابع، متغیر **PROGNAME** با متغیر شِل به نام **FUNCNAME** جایگزین شده است. شِل به‌طور خودکار این متغیر را به نام تابع در حال اجرا مقداردهی می‌کند.

به یاد داشته باشید:

* `$0` همیشه شامل نام برنامهٔ اصلی (آیتم اول خط فرمان) است
* و **نام تابع را در خود نگه نمی‌دارد**؛ برخلاف چیزی که شاید انتظار داشته باشیم

---

# **مدیریت گروهی پارامترهای موضعی (Handling Positional Parameters En Masse)**

گاهی لازم است همهٔ پارامترهای موضعی را به‌صورت یک مجموعه مدیریت کنیم.
برای مثال ممکن است بخواهیم یک **wrapper** برای یک برنامهٔ دیگر بنویسیم؛ یعنی یک اسکریپت یا تابع شِل که اجرای برنامهٔ دیگری را ساده‌تر کند. این wrapper مجموعه‌ای از گزینه‌های پیچیدهٔ خط فرمان را فراهم می‌کند و سپس آرگومان‌ها را به برنامهٔ سطح پایین‌تر ارسال می‌کند.

شِل برای این کار دو پارامتر ویژه ارائه می‌دهد. هر دو به **فهرست کامل پارامترهای موضعی** توسعه پیدا می‌کنند، اما تفاوت‌های ظریفی دارند:

---

## **جدول 32-1: پارامترهای ویژهٔ `*` و `@`**

| پارامتر | توضیح                                                                                                                                                                                                        |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `$*`    | به فهرست پارامترهای موضعی (از شماره ۱ به بعد) گسترش می‌یابد. وقتی داخل دابل‌کوتیشن قرار گیرد، به یک *رشتهٔ واحد* تبدیل می‌شود که در آن تمام پارامترها با کاراکتر اول متغیر IFS جدا می‌شوند (پیش‌فرض: فاصله). |
| `$@`    | به فهرست پارامترهای موضعی گسترش می‌یابد. وقتی داخل دابل‌کوتیشن قرار گیرد، **هر پارامتر جداگانه** در یک رشتهٔ دابل‌کوتیشن‌شده قرار می‌گیرد.                                                                   |

---

## **نمونهٔ اسکریپت برای نمایش تفاوت $* و $@**

```bash
#!/bin/bash
# posit-params3 : script to demonstrate $* and $@

print_params () {
    echo "\$1 = $1"
    echo "\$2 = $2"
    echo "\$3 = $3"
    echo "\$4 = $4"
}

pass_params () {
    echo -e "\n" '$* :';    print_params $*
    echo -e "\n" '"$*" :';  print_params "$*"
    echo -e "\n" '$@ :';    print_params $@
    echo -e "\n" '"$@" :';  print_params "$@"
}

pass_params "word" "words with spaces"
```

در این برنامهٔ پیچیده، دو آرگومان ساخته می‌شود:

* `"word"`
* `"words with spaces"`

و به تابع `pass_params` ارسال می‌شوند، که خود آن‌ها را با چهار روش مختلف به تابع `print_params` می‌دهد.

نتیجهٔ اجرای اسکریپت:

```
$* :
$1 = word
$2 = words
$3 = with
$4 = spaces

"$*" :
$1 = word words with spaces
$2 =
$3 =
$4 =

$@ :
$1 = word
$2 = words
$3 = with
$4 = spaces

"$@" :
$1 = word
$2 = words with spaces
$3 =
$4 =
```

### **تحلیل تفاوت‌ها**

* `$*` و `$@` هر دو نتیجه‌ای چهار کلمه‌ای می‌دهند:

  ```
  word words with spaces
  ```

* `"${*}"` نتیجه‌ای تک‌کلمه‌ای می‌دهد:

  ```
  "word words with spaces"
  ```

* `"${@}"` نتیجه‌ای دو کلمه‌ای می‌دهد:

  ```
  "word" "words with spaces"
  ```

که همان چیزی است که انتظار داریم.

### **نتیجهٔ مهم**

گرچه چهار روش برای دریافت پارامترهای موضعی داریم، اما:

### **`"$@"` تقریباً همیشه بهترین انتخاب است**

زیرا هر پارامتر را به‌طور مستقل و درست منتقل می‌کند.

---

# **یک کاربرد کامل‌تر (A More Complete Application)**

پس از یک وقفهٔ طولانی، کار روی برنامهٔ **sys_info_page** را ادامه می‌دهیم.
در این مرحله چند گزینهٔ خط فرمان اضافه می‌کنیم:

### **۱. فایل خروجی**

گزینهٔ:

* `-f file`
* یا `--file file`

برای مشخص کردن نام فایل خروجی برنامه.

### **۲. حالت تعاملی (Interactive Mode)**

گزینهٔ:

* `-i`
* یا `--interactive`

در این حالت، برنامه از کاربر نام فایل می‌پرسد و اگر فایل وجود داشته باشد، برای overwrite اجازه می‌گیرد.

### **۳. کمک (Help)**

گزینهٔ:

* `-h`
* یا `--help`

جهت نمایش پیام راهنما.

---

## **کد پردازش خط فرمان**

```bash
usage () {
    echo "$PROGNAME: usage: $PROGNAME [-f file | -i]"
    return
}

# process command line options
interactive=
filename=

while [[ -n $1 ]]; do
    case $1 in
        -f | --file) shift
                     filename=$1
                     ;;
        -i | --interactive) interactive=1
                            ;;
        -h | --help) usage
                     exit
                     ;;
        *) usage >&2
           exit 1
           ;;
    esac
    shift
done
```

### **توضیح پردازش**

* تابع `usage` پیام راهنما را نمایش می‌دهد.
* حلقه به‌شرطی ادامه پیدا می‌کند که `$1` خالی نباشد.
* در انتهای حلقه، `shift` آرگومان فعلی را حذف می‌کند.
* گزینهٔ `-f` یک `shift` اضافی دارد تا `$1` برابر نام فایل شود.

---

## **کد حالت تعاملی**

```bash
# interactive mode
if [[ -n $interactive ]]; then
    while true; do
        read -p "Enter name of output file: " filename
        if [[ -e $filename ]]; then
            read -p "'$filename' exists. Overwrite? [y/n/q] > "
            case $REPLY in
                Y|y) break ;;
                Q|q) echo "Program terminated."
                     exit ;;
                *) continue ;;
            esac
        elif [[ -z $filename ]]; then
            continue
        else
            break
        fi
    done
fi
```

* اگر فایل موجود باشد: پرسش overwrite، انتخاب نام دیگر، یا خروج
* انتخاب overwrite ⇒ خروج از حلقه
* انتخاب دیگر ⇒ ادامهٔ پرسش

---

## **تبدیل بخش تولید صفحه به تابع**

```bash
write_html_page () {
cat <<- _EOF_
<HTML>
<HEAD>
<TITLE>$TITLE</TITLE>
</HEAD>
<BODY>
<H1>$TITLE</H1>
<P>$TIMESTAMP</P>
$(report_uptime)
$(report_disk_space)
$(report_home_space)
</BODY>
</HTML>
_EOF_
return
}
```

---

## **ایجاد فایل خروجی**

```bash
# output html page
if [[ -n $filename ]]; then
    if touch $filename && [[ -f $filename ]]; then
        write_html_page > $filename
    else
        echo "$PROGNAME: Cannot write file '$filename'" >&2
        exit 1
    fi
else
    write_html_page
fi
```

### **توضیح عملکرد**

* اگر نام فایل مشخص شده باشد:

  * با `touch` بررسی می‌کنیم که مسیر معتبر است
  * سپس بررسی می‌کنیم فایل معمولی است
  * خروجی تابع به فایل هدایت می‌شود

* اگر نام فایل مشخص نشده باشد: خروجی به **stdout** می‌رود.

---

# **جمع‌بندی (Summing Up)**

با اضافه‌شدن پارامترهای موضعی (positional parameters)، اکنون می‌توانیم اسکریپت‌های نسبتاً کاربردی و کامل بنویسیم.
برای کارهای ساده و تکرارشونده، پارامترهای موضعی امکان نوشتن توابع شِل بسیار مفیدی را می‌دهند که می‌توان آن‌ها را در فایل `.bashrc` کاربر قرار داد.

برنامهٔ **sys_info_page** ما پیچیده‌تر و پیشرفته‌تر شده است. در ادامه، فهرست کامل برنامه را مشاهده می‌کنید که تغییرات اخیر در آن اعمال شده‌اند:

---

## **کد کامل برنامه sys_info_page**

```bash
#!/bin/bash
# sys_info_page: program to output a system information page

PROGNAME=$(basename $0)
TITLE="System Information Report For $HOSTNAME"
CURRENT_TIME=$(date +"%x %r %Z")
TIMESTAMP="Generated $CURRENT_TIME, by $USER"

report_uptime () {
cat <<- _EOF_
<H2>System Uptime</H2>
<PRE>$(uptime)</PRE>
_EOF_
return
}

report_disk_space () {
cat <<- _EOF_
<H2>Disk Space Utilization</H2>
<PRE>$(df -h)</PRE>
_EOF_
return
}

report_home_space () {
if [[ $(id -u) -eq 0 ]]; then
cat <<- _EOF_
<H2>Home Space Utilization (All Users)</H2>
<PRE>$(du -sh /home/*)</PRE>
_EOF_
else
cat <<- _EOF_
<H2>Home Space Utilization ($USER)</H2>
<PRE>$(du -sh $HOME)</PRE>
_EOF_
fi
return
}

usage () {
echo "$PROGNAME: usage: $PROGNAME [-f file | -i]"
return
}

write_html_page () {
cat <<- _EOF_
<HTML>
<HEAD>
<TITLE>$TITLE</TITLE>
</HEAD>
<BODY>
<H1>$TITLE</H1>
<P>$TIMESTAMP</P>
$(report_uptime)
$(report_disk_space)
$(report_home_space)
</BODY>
</HTML>
_EOF_
return
}

# process command line options
interactive=
filename=

while [[ -n $1 ]]; do
case $1 in
    -f | --file) shift
                 filename=$1
                 ;;
    -i | --interactive) interactive=1
                        ;;
    -h | --help) usage
                 exit
                 ;;
    *) usage >&2
       exit 1
       ;;
esac
shift
done

# interactive mode
if [[ -n $interactive ]]; then
while true; do
read -p "Enter name of output file: " filename
if [[ -e $filename ]]; then
read -p "'$filename' exists. Overwrite? [y/n/q] > "
case $REPLY in
    Y|y) break ;;
    Q|q) echo "Program terminated."
         exit ;;
    *) continue ;;
esac
fi
done
fi

# output html page
if [[ -n $filename ]]; then
if touch $filename && [[ -f $filename ]]; then
write_html_page > $filename
else
echo "$PROGNAME: Cannot write file '$filename'" >&2
exit 1
fi
else
write_html_page
fi
```

---

# **ما هنوز تمام نکرده‌ایم**

هنوز قابلیت‌های بیشتری می‌توان به برنامه اضافه کرد و بهبودهای زیادی امکان‌پذیر است.

---

# **مطالعهٔ بیشتر (Further Reading)**

● **Bash Hackers Wiki** دارای مقالهٔ خوبی دربارهٔ پارامترهای موضعی است:
[http://wiki.bash-hackers.org/scripting/posparams](http://wiki.bash-hackers.org/scripting/posparams)

● **Bash Reference Manual** مقاله‌ای دربارهٔ پارامترهای ویژه، شامل `$*` و `$@` دارد:
[http://www.gnu.org/software/bash/manual/bashref.html#Special-Parameters](http://www.gnu.org/software/bash/manual/bashref.html#Special-Parameters)

● علاوه بر روش‌هایی که در این فصل بررسی کردیم، bash یک دستور داخلی به نام **getopts** دارد که می‌توان برای پردازش آرگومان‌های خط فرمان از آن استفاده کرد. توضیحات آن در بخش **SHELL BUILTIN COMMANDS** در صفحهٔ manual مربوط به bash و همچنین در Bash Hackers Wiki آمده است:
[http://wiki.bash-hackers.org/howto/getopts_tutorial](http://wiki.bash-hackers.org/howto/getopts_tutorial)
