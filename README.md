# ChestCounter UI Addon

نسخة من **ChestCounter** مع تعديلات واجهة على التقرير والـ overlay. الملف التنفيذي نفسه مبني من مصدر البرنامج الرسمي، والتعديلات مدمجة داخله — ما تحتاج تشغّل أي سكربت يدوي.

## تحميل النسخة المعدّلة

- أحدث نسخة: https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest
- تحميل مباشر: https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest/download/ChestCounter.exe

زر **Check for updates** داخل البرنامج يفحص هذا الريبو مباشرة؛ أي تعديل جديد ننشره كريليز برقم أعلى و asset اسمه `ChestCounter.exe` ويوصله الزر تلقائياً. بياناتك وإعداداتك محفوظة.

## وش فيه جديد على الأصلي

1. سطر `Last: <عدد> chests @ <وقت> | Team: <عدد>` جنب التوتال في `report.html` و `overlay.html`.
2. الجوايز تبقى في أقسام البرنامج الأصلية (`Your collection` / `Treasures found`) وما ينضاف لها جدول إضافي عشان الصفحة ما تطول.
4. التوتال المعروض هو العدد المؤكد من Fortnite في `cc-counts.json` ( treasure / rare / sprite )، مع سطر منفصل لعدد الريبلايز.
5. قسم `Last match — you & squad`: آخر مباراة، كم فتحت أنت، كم فتح الفريق، واسم كل صديق وعدّه بالضبط.
6. الـ overlay يعرض بس: التوتال + «You … · Team …» + أسماء الأصدقاء وعددهم. ما فيه جوائز ولا تكرار صفوف.
7. المراقب يعيد الحقن تلقائياً بعد كل مرة البرنامج يعيد كتابة `report.html` / `overlay.html`.

## العدد المؤكد من Fortnite

عدّل `cc-counts.json` في مجلد بيانات البرنامج `%APPDATA%\ChestCounter`:

```json
{ "treasure": 965, "rare": 71, "sprite": 32 }
```

التوتال المعروض = المجموع (1,068)، ويبقى سطر الريبلايز منفصل عشان تعرف الفرق.

## الجوائز اللي الريبلايز ما يقدر يشوفها

عدّل `cc-prize-manual.json` في مجلد بيانات البرنامج `%APPDATA%\ChestCounter`:

```json
[
  { "id": "w3-car", "by": "squad", "note": "teammate gave it to you" },
  "w2-jam"
]
```

- `id` هو معرّف الجائزة في `content.json` (مثل `w3-car`).
- `by` إما `you` أو `squad`.
- سطر نصي عادي (مثل `"w2-jam"`) يعني أنك جبتها بنفسك.

## المصدر الرسمي

https://github.com/LED-N/Fortnite-ChestCounter/releases/latest

## ملاحظات

- البيانات تُقرأ من `%APPDATA%\ChestCounter\data.json` و `content.json` و `config.json`.
- الملفات `cc-ui-inject.ps1` و `cc-prize-manual.json` تُستخرج تلقائياً في مجلد البيانات عند أول تشغيل.
- `enable-updates.reg` موجود للضرورة القديمة، لكن النسخة المبنية ما تحتاجه لأن رابط التحديث مدمج فيها.
