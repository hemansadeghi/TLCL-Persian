# فصل ۲۶ – طراحی از بالا به پایین

اکنون که اسکلت اسکریپت `sys_info_page` را ایجاد کرده‌ایم، وقت آن است ساختار آن را حرفه‌ای‌تر کنیم.
یکی از روش‌های کلاسیک در مهندسی نرم‌افزار «طراحی از بالا به پایین» (Top-Down Design) است؛
در این روش ابتدا تصویر کلی و وظایف اصلی را مشخص می‌کنیم، سپس هر وظیفه را به زیرکارهای کوچک‌تر تقسیم می‌کنیم تا در نهایت به جزئیات قابل‌پیاده‌سازی برسیم.
این فصل نشان می‌دهد چگونه با استفاده از توابع، متغیرها و بررسی خطاها، اسکریپتی منظم، قابل نگه‌داری و قابل توسعه بسازیم.

---

## طرح کلی اسکریپت

برای شروع، لازم است تشخیص دهیم چه بخش‌هایی وجود دارد و هر بخش چه داده‌ای تولید می‌کند.
چک‌لیست زیر را در نظر بگیرید:

1. تولید عنوان و سربرگ HTML.
2. جمع‌آوری اطلاعات سیستم.
3. جمع‌آوری زمان کارکرد.
4. نمایش کاربران فعال.
5. گزارش فضای دیسک و شاخه‌های خانگی.
6. خاتمهٔ فایل HTML و اعلام نتیجه.

هر یک از این موارد می‌تواند به صورت یک «تابع» پیاده‌سازی شود تا کد اصلی خواناتر گردد.

## تعریف توابع

در bash دو شیوهٔ رایج برای تعریف تابع وجود دارد:

```bash
function function_name {
    # دستورات
}
```

یا:

```bash
function_name() {
    # دستورات
}
```

هر دو شکل معادل‌اند؛ در این کتاب از فرم دوم استفاده می‌کنیم.
توابع مقدار بازگشتی یک فرمان را با دستور `return` تعیین می‌کنند (مقدار عددی بین ۰ تا ۲۵۵).
اگر `return` ننویسیم، مقدار بازگشتی آخرین فرمان داخل تابع استفاده می‌شود.

### ساخت قالب اولیه

در اسکریپت `sys_info_page` ابتدا توابعی می‌سازیم که فعلاً فقط پیام‌های نمونه چاپ می‌کنند.
سپس در ادامه آنها را تکمیل می‌کنیم.

```bash
write_html_header() {
    cat << _EOF_
<html>
<head>
    <title>$TITLE</title>
</head>
<body>
    <h1>$TITLE</h1>
    <p>$TIME_STAMP</p>
_EOF_
}

write_html_footer() {
    cat << _EOF_
</body>
</html>
_EOF_
}
```

اکنون توابعی برای هر بخش گزارش ایجاد می‌کنیم:

```bash
report_system_info() {
    echo "    <h2>اطلاعات کلی سیستم</h2>"
    echo "    <pre>$(uname -mp)</pre>"
    echo "    <pre>$(uname -sr)</pre>"
    return 0
}

report_uptime() {
    echo "    <h2>زمان کارکرد سیستم</h2>"
    echo "    <pre>$(uptime)</pre>"
    return 0
}

report_users() {
    echo "    <h2>کاربران حاضر</h2>"
    echo "    <pre>$(who)</pre>"
    return 0
}

report_disk_space() {
    echo "    <h2>فضای دیسک موجود</h2>"
    echo "    <pre>$(df -h)</pre>"
    return 0
}

report_home_space() {
    echo "    <h2>وضعیت شاخهٔ خانگی</h2>"
    if [[ $UID -eq 0 ]]; then
        echo "    <pre>$(du -sh /home/* 2>/dev/null)</pre>"
    else
        echo "    <pre>$(du -sh "$HOME" 2>/dev/null)</pre>"
    fi
    return 0
}
```

در تابع آخر بررسی کردیم که اگر اسکریپت با دسترسی ریشه اجرا شود، می‌تواند اطلاعات تمام شاخه‌های خانگی را تهیه کند؛ در غیر این صورت تنها شاخهٔ کاربر جاری گزارش می‌شود.

## بدنهٔ اصلی برنامه

اکنون که توابع آماده‌اند، بدنهٔ اسکریپت بسیار ساده می‌شود.

```bash
main() {
    if ! write_html_header > "$REPORT_FILE"; then
        echo "خطا در نوشتن سربرگ HTML." >&2
        exit 1
    fi

    report_system_info >> "$REPORT_FILE"
    report_uptime >> "$REPORT_FILE"
    report_users >> "$REPORT_FILE"
    report_disk_space >> "$REPORT_FILE"
    report_home_space >> "$REPORT_FILE"

    if write_html_footer >> "$REPORT_FILE"; then
        echo "گزارش در $REPORT_FILE ذخیره شد."
    else
        echo "خطا در تکمیل گزارش." >&2
        exit 1
    fi
}
```

در این الگو از عملگر `!` استفاده کرده‌ایم تا در صورت شکست تابع، پیام خطا چاپ شود و اجرای برنامه با `exit 1` خاتمه یابد.
توجه کنید که خروجی هر تابع به کمک `>>` به فایل افزوده می‌شود؛ سربرگ برای اولین بار با `>` فایل را ایجاد می‌کند.

در انتهای فایل کافی است `main` را فراخوانی کنیم:

```bash
main
```

## استفاده از متغیرهای محلی

تابع‌ها می‌توانند متغیرهای «محلی» داشته باشند تا از تداخل با سایر بخش‌های برنامه جلوگیری شود.
برای تعریف متغیر محلی از کلیدواژهٔ `local` استفاده می‌کنیم:

```bash
report_disk_space() {
    local temp_file=$(mktemp /tmp/diskspace.XXXXXX)
    df -h > "$temp_file"
    echo "    <h2>فضای دیسک موجود</h2>"
    echo "    <pre>$(cat "$temp_file")</pre>"
    rm -f "$temp_file"
    return 0
}
```

اینجا متغیر `temp_file` فقط درون تابع اعتبار دارد و پس از پایان تابع از بین می‌رود.
البته در مثال فوق می‌توانستیم خروجی `df` را مستقیم در `echo` قرار دهیم؛ هدف نشان دادن الگوی کار با متغیرهای محلی است.

## دستکاری جریان خطا

هنگام استفاده از فرمان‌های خارجی، بهتر است خطاها را مدیریت کنیم تا صفحهٔ HTML به هم نریزد.
برای مثال می‌توانیم خروجی خطای `who` را به فایل موقتی یا `/dev/null` هدایت کنیم:

```bash
report_users() {
    echo "    <h2>کاربران حاضر</h2>"
    if users_list=$(who 2>/dev/null); then
        if [[ -n $users_list ]]; then
            echo "    <pre>$users_list</pre>"
        else
            echo "    <pre>هیچ کاربری متصل نیست.</pre>"
        fi
    else
        echo "    <pre>خطا در اجرای who.</pre>"
        return 1
    fi
}
```

اگر فرمان `who` شکست بخورد، تابع مقدار `1` برمی‌گرداند؛ بدنهٔ اصلی می‌تواند آن را تشخیص دهد و اقدام مناسب انجام دهد (مثلاً چاپ پیام هشدار).

## نسخهٔ کامل اسکریپت

کد زیر همهٔ نکات گفته‌شده را در یک اسکریپت واحد جمع می‌کند:

```bash
#!/bin/bash

TITLE="گزارش وضعیت سیستم برای $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="گزارش تولید شده در $RIGHT_NOW توسط $USER"
REPORT_FILE=${1:-/tmp/system_info.html}

write_html_header() {
    cat << _EOF_
<html>
<head>
    <title>$TITLE</title>
</head>
<body>
    <h1>$TITLE</h1>
    <p>$TIME_STAMP</p>
_EOF_
}

write_html_footer() {
    cat << _EOF_
</body>
</html>
_EOF_
}

report_system_info() {
    echo "    <h2>اطلاعات کلی سیستم</h2>"
    echo "    <pre>$(uname -mp)</pre>"
    echo "    <pre>$(uname -sr)</pre>"
}

report_uptime() {
    echo "    <h2>زمان کارکرد سیستم</h2>"
    echo "    <pre>$(uptime)</pre>"
}

report_users() {
    echo "    <h2>کاربران حاضر</h2>"
    if users_list=$(who 2>/dev/null); then
        [[ -n $users_list ]] || users_list="هیچ کاربری متصل نیست."
        echo "    <pre>$users_list</pre>"
    else
        echo "    <pre>خطا در اجرای who.</pre>"
        return 1
    fi
}

report_disk_space() {
    echo "    <h2>فضای دیسک موجود</h2>"
    if disk_info=$(df -h 2>/dev/null); then
        echo "    <pre>$disk_info</pre>"
    else
        echo "    <pre>اطلاعات دیسک در دسترس نیست.</pre>"
        return 1
    fi
}

report_home_space() {
    echo "    <h2>وضعیت شاخهٔ خانگی</h2>"
    if [[ $UID -eq 0 ]]; then
        target=/home/*
    else
        target="$HOME"
    fi

    if home_info=$(du -sh $target 2>/dev/null); then
        echo "    <pre>$home_info</pre>"
    else
        echo "    <pre>عدم دسترسی به شاخهٔ خانگی.</pre>"
        return 1
    fi
}

main() {
    if ! write_html_header > "$REPORT_FILE"; then
        echo "خطا در ایجاد فایل گزارش." >&2
        exit 1
    fi

    report_system_info >> "$REPORT_FILE" || true
    report_uptime >> "$REPORT_FILE" || true
    report_users >> "$REPORT_FILE" || true
    report_disk_space >> "$REPORT_FILE" || true
    report_home_space >> "$REPORT_FILE" || true

    if write_html_footer >> "$REPORT_FILE"; then
        echo "گزارش در $REPORT_FILE ذخیره شد."
    else
        echo "خطا در تکمیل فایل گزارش." >&2
        exit 1
    fi
}

main "$@"
```

چند نکتهٔ مهم:

* متغیر `REPORT_FILE` با استفاده از ساختار `${1:-default}` مقدار آرگومان اول خط فرمان را می‌پذیرد؛ اگر هیچ آرگومانی داده نشود مسیر پیش‌فرض `/tmp/system_info.html` استفاده می‌شود.
* در فراخوانی توابع داخل `main` پس از عملگر `>>` از `|| true` استفاده کردیم تا در صورت بازگشت مقدار غیر صفر، اجرای کل برنامه متوقف نشود. می‌توانید به جای آن سازوکاری برای ثبت خطاها پیاده کنید.
* `main "$@"` تضمین می‌کند اگر بعداً گزینه‌های بیشتری اضافه کردیم، به راحتی در تابع اصلی در دسترس باشند.

## گسترش‌های احتمالی

* افزودن گزینه‌ای برای تعیین گزارش مختصر یا کامل.
* ذخیرهٔ خروجی در قالب‌های دیگر مانند متن ساده (`text/plain`).
* ارسال گزارش از طریق ایمیل یا کپی خودکار به یک سرور دوردست با `scp`.

این ایده‌ها در فصل‌های بعدی هنگام مطالعهٔ کنترل جریان و پردازش ورودی به کار خواهند آمد.

---

### تمرین‌ها

1. تابعی به نام `report_memory` بنویسید که خروجی `free -h` را نمایش دهد و آن را بین بخش‌های سیستم و uptime قرار دهید.
2. اسکریپت را تغییر دهید تا در صورت شکست هر تابع، نام تابع شکست‌خورده در فایل گزارش نیز نوشته شود.
3. تابعی با عنوان `check_command` بسازید که در ابتدای اسکریپت فراخوانی شود و مطمئن شود فرمان‌های مورد نیاز (`uname`, `uptime`, `who`, `df`, `du`) در `PATH` موجودند؛ در غیر این صورت پیام خطا چاپ کند و از برنامه خارج شود.

### مطالعهٔ بیشتر

* صفحهٔ راهنمای `man bash`، بخش «FUNCTIONS» برای توضیح کامل توابع.
* مستندات پروژهٔ `Shell Style Guide` (از Google یا سایر منابع) برای یادگیری بهترین شیوه‌های قالب‌بندی کد.
* مقالهٔ «Command Substitution» در راهنمای Bash Hackers جهت درک عمیق‌تر نحوهٔ قرار دادن خروجی فرمان‌ها در متغیرها.
