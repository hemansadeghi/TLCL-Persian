# ۳۱ – کنترل جریان: انشعاب با case

در این فصل، به بررسی بیشتر کنترل جریان ادامه می‌دهیم.
در فصل ۲۸، منوهای ساده‌ای ساختیم و منطق لازم برای اجرای انتخاب کاربر را نوشتیم.
برای این کار از مجموعه‌ای از دستورات `if` استفاده کردیم تا بفهمیم کدام گزینه انتخاب شده است.

این نوع ساختار آن‌قدر رایج است که بسیاری از زبان‌های برنامه‌نویسی (از جمله شل) یک سازوکار مخصوص برای تصمیم‌گیری چندگزینه‌ای ارائه می‌کنند.

---

## **case**

دستور چندگزینه‌ای bash با نام **case** شناخته می‌شود. سینتکس آن این است:

```
case word in
    pattern ) commands ;; 
    pattern ) commands ;;
    ...
esac
```

اگر به برنامهٔ read-menu از فصل ۲۸ نگاه کنیم، منطق اجرایی آن بر اساس if بود:

```bash
if [[ $REPLY =~ ^[0-3]$ ]]; then
    if [[ $REPLY == 0 ]]; then
        ...
    fi
    if [[ $REPLY == 1 ]]; then
        ...
    fi
    if [[ $REPLY == 2 ]]; then
        ...
    fi
    if [[ $REPLY == 3 ]]; then
        ...
    fi
else
    invalid entry
fi
```

با استفاده از **case** می‌توانیم همین منطق را بسیار ساده‌تر کنیم:

---

## **نسخهٔ ساده‌شده با case**

```bash
#!/bin/bash
# case-menu: a menu driven system information program

clear
echo "
Please Select:
1. Display System Information
2. Display Disk Space
3. Display Home Space Utilization
0. Quit
"

read -p "Enter selection [0-3] > "

case $REPLY in
0)
    echo "Program terminated."
    exit
    ;;

1)
    echo "Hostname: $HOSTNAME"
    uptime
    ;;

2)
    df -h
    ;;

3)
    if [[ $(id -u) -eq 0 ]]; then
        echo "Home Space Utilization (All Users)"
        du -sh /home/*
    else
        echo "Home Space Utilization ($USER)"
        du -sh "$HOME"
    fi
    ;;

*)
    echo "Invalid entry" >&2
    exit 1
    ;;
esac
```

دستور **case** مقدار *word* (در اینجا `$REPLY`) را بررسی می‌کند و تلاش می‌کند آن را با یکی از الگوها (pattern) هماهنگ کند. وقتی یک مورد مطابق پیدا شد، دستورات همان بخش اجرا می‌شوند و هیچ الگوی دیگری بررسی نمی‌شود.

---

## **Patterns — الگوها در case**

الگوهای مورد استفاده در case همان الگوهایی هستند که در *pathname expansion* به‌کار می‌روند.
الگو با `)` پایان می‌یابد.

**چند نمونه از الگوهای معتبر:**

| الگو           | توضیح                                                                  |
| -------------- | ---------------------------------------------------------------------- |
| `a)`           | اگر word دقیقاً “a” باشد.                                              |
| `[[:alpha:]])` | اگر یک حرف الفبایی تک‌کاراکتری باشد.                                   |
| `???)`         | اگر word دقیقاً سه کاراکتر باشد.                                       |
| `*.txt)`       | اگر به `.txt.` ختم شود.                                                |
| `*)`           | هر مقداری را می‌پذیرد؛ معمولاً آخرین الگو برای گرفتن حالت‌های نامعتبر. |

---

### **مثال:**

```bash
#!/bin/bash
read -p "enter word > "

case $REPLY in
    [[:alpha:]]) echo "is a single alphabetic character." ;;
    [ABC][0-9]) echo "is A, B, or C followed by a digit." ;;
    ???) echo "is three characters long." ;;
    *.txt) echo "is a word ending in '.txt'" ;;
    *) echo "is something else." ;;
esac
```

---

## **ترکیب چند الگو با «|»**

می‌توان چند الگو را با `|` ترکیب کرد؛ یعنی «این یا آن».
این کار برای دریافت حرف‌های کوچک و بزرگ بسیار مفید است.

مثال زیر نسخهٔ دیگر منوی case با حروف به‌جای اعداد است:

```bash
#!/bin/bash

clear
echo "
Please Select:
A. Display System Information
B. Display Disk Space
C. Display Home Space Utilization
Q. Quit
"

read -p "Enter selection [A, B, C or Q] > "

case $REPLY in
    q|Q)
        echo "Program terminated."
        exit
        ;;

    a|A)
        echo "Hostname: $HOSTNAME"
        uptime
        ;;

    b|B)
        df -h
        ;;

    c|C)
        if [[ $(id -u) -eq 0 ]]; then
            echo "Home Space Utilization (All Users)"
            du -sh /home/*
        else
            echo "Home Space Utilization ($USER)"
            du -sh "$HOME"
        fi
        ;;

    *)
        echo "Invalid entry" >&2
        exit 1
        ;;
esac
```

در این نسخه، الگوها ورودی حروف بزرگ و کوچک را هر دو می‌پذیرند.

---

## **انجام چند عمل در یک case**

در نسخه‌های **قبل از Bash 4.0**، دستور `case` فقط اجازه می‌داد **یک** عمل برای هر تطبیق انجام شود. یعنی وقتی یک الگو match می‌شد، case بلافاصله خاتمه پیدا می‌کرد و نمی‌شد چندین الگو را بررسی کرد.

در مثال زیر اسکریپتی داریم که یک کاراکتر را تست می‌کند:

```bash
#!/bin/bash
# case4-1: test a character

read -n 1 -p "Type a character > "
echo

case $REPLY in
    [[:upper:]])    echo "'$REPLY' is upper case." ;;
    [[:lower:]])    echo "'$REPLY' is lower case." ;;
    [[:alpha:]])    echo "'$REPLY' is alphabetic." ;;
    [[:digit:]])    echo "'$REPLY' is a digit." ;;
    [[:graph:]])    echo "'$REPLY' is a visible character." ;;
    [[:punct:]])    echo "'$REPLY' is a punctuation symbol." ;;
    [[:space:]])    echo "'$REPLY' is a whitespace character." ;;
    [[:xdigit:]])   echo "'$REPLY' is a hexadecimal digit." ;;
esac
```

خروجی:

```
Type a character > a
'a' is lower case.
```

اسکریپت کار می‌کند، اما مشکل اینجاست که برخی کاراکترها متعلق به **چندین کلاس POSIX** هستند.
مثلاً:

* «a» هم **حرف کوچک** است
* هم **حرف الفبا**
* هم **هگزادسیمال**

در نسخه‌های قدیمی bash راهی نبود که case بتواند بیش از یک match انجام دهد؛ یعنی بعد از اولین match متوقف می‌شد.

---

## **راه‌حل در Bashهای جدید: استفاده از `;;&`**

نسخه‌های جدیدتر bash امکان استفاده از `;;&` را اضافه کرده‌اند تا case به‌جای توقف، **تست بعدی** را نیز ادامه دهد.

نسخهٔ جدید اسکریپت:

```bash
#!/bin/bash
# case4-2: test a character

read -n 1 -p "Type a character > "
echo

case $REPLY in
    [[:upper:]])    echo "'$REPLY' is upper case." ;;&
    [[:lower:]])    echo "'$REPLY' is lower case." ;;&
    [[:alpha:]])    echo "'$REPLY' is alphabetic." ;;&
    [[:digit:]])    echo "'$REPLY' is a digit." ;;&
    [[:graph:]])    echo "'$REPLY' is a visible character." ;;&
    [[:punct:]])    echo "'$REPLY' is a punctuation symbol." ;;&
    [[:space:]])    echo "'$REPLY' is a whitespace character." ;;&
    [[:xdigit:]])   echo "'$REPLY' is a hexadecimal digit." ;;&
esac
```

خروجی:

```
Type a character > a
'a' is lower case.
'a' is alphabetic.
'a' is a visible character.
'a' is a hexadecimal digit.
```

اضافه شدن `;;&` باعث می‌شود case **تست بعدی را هم اجرا کند**، نه اینکه با اولین match متوقف شود.

---

## **جمع‌بندی**

دستور **case** ابزاری بسیار مفید در کنترل جریان برنامه است.
در فصل بعد خواهیم دید که این دستور برای نوع خاصی از مسائل بهترین گزینه است.

---

## **برای مطالعهٔ بیشتر**

● فصل Conditional Constructs از Bash Reference Manual:
[http://tiswww.case.edu/php/chet/bash/bashref.html#SEC21](http://tiswww.case.edu/php/chet/bash/bashref.html#SEC21)

● مثال‌های بیشتر از case در Advanced Bash-Scripting Guide:
[http://tldp.org/LDP/abs/html/testbranch.html](http://tldp.org/LDP/abs/html/testbranch.html)
