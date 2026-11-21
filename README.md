# ChestCounter UI Addon

إضافة صغيرة على واجهة برنامج **ChestCounter** الأصلي. ما نعدّل ملف `ChestCounter.exe` أبداً؛ نضيف معلومات على ملفات التقرير اللي يولّدها البرنامج.

## تحميل البرنامج الأصلي

- أحدث إصدار (1.5.1): https://github.com/LED-N/Fortnite-ChestCounter/releases/latest
- تحميل مباشر للـ exe: https://github.com/LED-N/Fortnite-ChestCounter/releases/download/v1.5.1/ChestCounter.exe
- المصدر الرسمي: https://github.com/LED-N/Fortnite-ChestCounter

## وش تسوي الإضافة

1. تضيف سطر `Last: <عدد> chests @ <وقت> | Team: <عدد>` جنب التوتال في `report.html` و `overlay.html`.
2. تضيف جدول **All treasure prizes — every week** تحت كرت `Your chances` في `report.html`: كل جوائز الأسابيع الخمسة + Pirate Shop (26 جائزة) مع الصور والاحتمالات وحالة كل جائزة.
3. تحالة الجائزة تجي من ريبلايز اللاعب، أو من ريبلايز الفريق، أو من الملف اليدوي `cc-prize-manual.json`.
4. المراقب يعيد الحقن تلقائياً بعد كل مرة البرنامج يعيد كتابة `report.html` / `overlay.html`.

## التثبيت

1. حط الملفات `cc-ui-inject.ps1` و `cc-prize-manual.json` في نفس المجلد (مثلاً `C:\Users\<اسمك>\Tools`).
2. شغّل `install.ps1` مرة واحدة: يسوي اختصار في Startup ويشغّل المراقب.
3. افتح تقرير ChestCounter من البرنامج؛ الجدول يظهر تحته مباشرة.

## الجوائز اللي الريبلايز ما يقدر يشوفها

عدّل `cc-prize-manual.json`:

```json
[
  { "id": "w3-car", "by": "squad", "note": "teammate gave it to you" },
  "w2-jam"
]
```

- `id` هو معرّف الجائزة في `content.json` (مثل `w3-car`).
- `by` إما `you` أو `squad`.
- سطر نصي عادي (مثل `"w2-jam"`) يعني أنك جبتها بنفسك.

معرفات الجوائز: `w1-outfit`, `w1-pickaxe`, `w1-car`, `w1-jam`, `w1-loading`, `w2-outfit`, `w2-backbling`, `w2-car`, `w2-jam`, `w2-loading`, `w3-outfit`, `w3-backbling`, `w3-car`, `w3-jam`, `w3-loading`, `w4-*`, `w5-*`, `pirate-shop`.

## ملاحظات

- البيانات تُقرأ من `%APPDATA%\ChestCounter\data.json` و `content.json` و `config.json`.
- الإضافة تشتغل مع كل تحديث للبرنامج طالما أسماء الملفات/الحقول ما تغيّرت.
- أي تعديل جديد على واجهة ChestCounter يرفع هنا بنفس الريبو.
