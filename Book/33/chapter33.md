# ۳۳ – کنترل جریان: حلقه‌زنی با for

در این فصل پایانی مربوط به کنترل جریان، به یکی دیگر از ساختارهای حلقه‌ای شِل نگاه می‌کنیم. حلقهٔ **for** با حلقه‌های **while** و **until** تفاوت دارد، زیرا روشی برای پردازش *توالی‌ها* داخل یک حلقه فراهم می‌کند. این ویژگی هنگام برنامه‌نویسی بسیار مفید است.
به همین دلیل، حلقهٔ for در اسکریپت‌نویسی bash بسیار محبوب است.

دستور for در شِل، به‌طور طبیعی، با فرمان **for** پیاده‌سازی می‌شود. در نسخه‌های جدید bash، حلقهٔ for در دو شکل در دسترس است.

---

# **حلقهٔ for: شکل سنتی در شِل**

دستور سنتی for این ساختار را دارد:

```
for variable [in words]; do
    commands
done
```

* **variable** نام متغیری است که در هر تکرار مقدار جدیدی می‌گیرد.
* **words** یک فهرست اختیاری از مواردی است که هر بار به variable اختصاص داده می‌شود.
* **commands** مجموعه دستورات اجرایی در هر تکرار حلقه هستند.

حلقهٔ for روی خط فرمان نیز بسیار کاربرد دارد:

```
[me@linuxbox ~]$ for i in A B C D; do echo $i; done
A
B
C
D
```

در این مثال، چهار کلمهٔ «A»، «B»، «C» و «D» به دستور for داده می‌شود، و بنابراین حلقه چهار بار اجرا می‌شود. در هر تکرار، یکی از این کلمات به متغیر **i** اختصاص داده می‌شود و با دستور echo نمایش داده می‌شود.
همانند حلقه‌های while و until، واژهٔ `done` پایان حلقه را مشخص می‌کند.

---

# **قدرت اصلی حلقهٔ for**

قدرت حلقهٔ for در این است که می‌توان *فهرست words* را به روش‌های مختلف ساخت.

### **۱. گسترش آکولادی (brace expansion)**

```
[me@linuxbox ~]$ for i in {A..D}; do echo $i; done
A
B
C
D
```

### **۲. گسترش مسیر فایل (pathname expansion)**

```
[me@linuxbox ~]$ for i in distros*.txt; do echo $i; done
distros-by-date.txt
distros-dates.txt
distros-key-names.txt
distros-key-vernums.txt
distros-names.txt
distros.txt
distros-vernums.txt
distros-versions.txt
```

### **۳. جایگزینی فرمان (command substitution)**

نمونهٔ کامل:

```bash
#!/bin/bash
# longest-word : find longest string in a file

while [[ -n $1 ]]; do
    if [[ -r $1 ]]; then
        max_word=
        max_len=0
        for i in $(strings $1); do
            len=$(echo $i | wc -c)
            if (( len > max_len )); then
                max_len=$len
                max_word=$i
            fi
        done
        echo "$1: '$max_word' ($max_len characters)"
    fi
    shift
done
```

در این مثال:

* برنامه متن قابل‌خواندن داخل فایل را با دستور **strings** دریافت می‌کند.
* حلقهٔ for تک‌تک کلمات را پردازش می‌کند.
* طول هر کلمه سنجیده می‌شود.
* طولانی‌ترین کلمهٔ یافت‌شده در پایان چاپ می‌شود.

---

# **استفاده از پارامترهای موضعی در for**

اگر بخش `in words` حذف شود، حلقهٔ for به‌طور پیش‌فرض **پارامترهای موضعی** را پردازش خواهد کرد.

نسخهٔ ساده‌تر برنامهٔ قبل:

```bash
#!/bin/bash
# longest-word2 : find longest string in a file

for i; do
    if [[ -r $i ]]; then
        max_word=
        max_len=0
        for j in $(strings $i); do
            len=$(echo $j | wc -c)
            if (( len > max_len )); then
                max_len=$len
                max_word=$j
            fi
        done
        echo "$i: '$max_word' ($max_len characters)"
    fi
done
```

در این نسخه:

* بخش `in ...` حذف شده است.
* بنابراین for به‌طور خودکار `$1`, `$2`, ... را پردازش می‌کند.
* متغیر خارجی از **i** به **j** تغییر یافته تا با حلقه بیرونی تداخل نکند.
* دیگر نیازی به `shift` نیست.

---

# **چرا همیشه از i استفاده می‌شود؟**

حتماً متوجه شده‌اید که در مثال‌های for معمولاً از متغیر **i** استفاده می‌شود.

دلیل خاصی ندارد… فقط **سنت** است!

* معمولاً پس از i، از **j** و **k** نیز استفاده می‌شود.
* این عادت از زبان برنامه‌نویسی **Fortran** آمده است.

### **در Fortran:**

* متغیرهایی که با حروف **I, J, K, L, M** شروع می‌شدند به‌طور خودکار **عدد صحیح (integer)** شناخته می‌شدند.
* سایر متغیرها **real (عدد اعشاری)** بودند.

بنابراین برنامه‌نویسان از i، j و k برای متغیرهای موقتی مانند متغیرهای حلقه استفاده می‌کردند.

---

## **و لطیفهٔ معروف فرترن:**

> **“GOD is real, unless declared integer.”**

(خدا واقعی است… مگر اینکه به‌عنوان integer تعریف شود!)

---

# **حلقهٔ for: شکل زبان C (for: C Language Form)**

نسخه‌های جدیدتر bash شکل دومِ دستور for را اضافه کرده‌اند؛ شکلی که شبیه حلقهٔ for در زبان برنامه‌نویسی **C** است. بسیاری از زبان‌های برنامه‌نویسی دیگر نیز از این شکل حلقه پشتیبانی می‌کنند.

ساختار آن به صورت زیر است:

```
for (( expression1; expression2; expression3 )); do
    commands
done
```

که در آن:

* **expression1** → عبارت آغازین برای مقداردهی اولیه
* **expression2** → شرط ادامه یافتن حلقه
* **expression3** → اجرا در پایان هر تکرار حلقه
* **commands** → دستورات اجراشونده در هر دور حلقه

از نظر رفتاری، این ساختار دقیقاً معادل این کد است:

```
(( expression1 ))
while (( expression2 )); do
    commands
    (( expression3 ))
done
```

---

## **مثالی از کاربرد حلقهٔ C-style**

```bash
#!/bin/bash
# simple_counter : demo of C style for command

for (( i=0; i<5; i=i+1 )); do
    echo $i
done
```

اجرای این اسکریپت نتیجهٔ زیر را تولید می‌کند:

```
[me@linuxbox ~]$ simple_counter
0
1
2
3
4
```

در این مثال:

* **expression1** → مقدار اولیه: `i=0`
* **expression2** → شرط ادامه: `i<5`
* **expression3** → افزایش مقدار: `i=i+1` در هر تکرار

حلقهٔ C‌-style هر زمان که یک دنبالهٔ عددی نیاز باشد، بسیار مفید است.
در دو فصل بعدی چند کاربرد بیشتر از این نوع حلقه را خواهیم دید.

---

# **جمع‌بندی**

اکنون با دستور for آشنا شدیم؛ بنابراین می‌توانیم آخرین بهبودها را به اسکریپت **sys_info_page** اضافه کنیم.

در حال حاضر تابع `report_home_space` این‌گونه است:

```bash
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
```

اکنون می‌خواهیم آن را بازنویسی کنیم تا برای هر دایرکتوری خانگی (home directory) اطلاعات بیشتری ارائه دهد؛
از جمله **تعداد فایل‌ها**، **تعداد پوشه‌ها** و **حجم کل**.

---

# **نسخهٔ جدید و بهبود یافتهٔ تابع**

```bash
report_home_space () {
    local format="%8s%10s%10s\n"
    local i dir_list total_files total_dirs total_size user_name

    if [[ $(id -u) -eq 0 ]]; then
        dir_list=/home/*
        user_name="All Users"
    else
        dir_list=$HOME
        user_name=$USER
    fi

    echo "<H2>Home Space Utilization ($user_name)</H2>"

    for i in $dir_list; do
        total_files=$(find $i -type f | wc -l)
        total_dirs=$(find $i -type d | wc -l)
        total_size=$(du -sh $i | cut -f 1)

        echo "<H3>$i</H3>"
        echo "<PRE>"
        printf "$format" "Dirs" "Files" "Size"
        printf "$format" "----" "-----" "----"
        printf "$format" $total_dirs $total_files $total_size
        echo "</PRE>"
    done

    return
}
```

## **تحلیل بازنویسی**

در نسخهٔ جدید:

* هنوز بررسی می‌کنیم که آیا کاربر **root** است یا خیر.
* اما به‌جای اجرای کامل عملیات داخل if، فقط متغیرهای مورد نیاز حلقهٔ for را مقداردهی می‌کنیم.
* چند متغیر محلی (local) اضافه شده است.
* از **printf** برای قالب‌بندی بهتر خروجی استفاده شده است.
* با استفاده از find تعداد فایل‌ها و پوشه‌ها محاسبه شده است.
* حجم دایرکتوری با `du -sh` استخراج می‌شود.

این نسخه باعث تولید گزارش بسیار دقیق‌تر و حرفه‌ای‌تری نسبت به نسخهٔ قبلی می‌شود.

---

# **مطالعهٔ بیشتر (Further Reading)**

● **Advanced Bash-Scripting Guide** — فصل مربوط به حلقه‌ها (شامل مثال‌های متعدد از for):
[http://tldp.org/LDP/abs/html/loops1.html](http://tldp.org/LDP/abs/html/loops1.html)

● **Bash Reference Manual** — توضیح ساختارهای حلقه‌ای (از جمله for):
[http://www.gnu.org/software/bash/manual/bashref.html#Looping-Constructs](http://www.gnu.org/software/bash/manual/bashref.html#Looping-Constructs)
