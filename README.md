# ChestCounter — UI Addon Build

[![Latest release](https://img.shields.io/github/v/release/pawnking172/ChestCounter-UI-Inject?color=gold&label=latest)](https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/pawnking172/ChestCounter-UI-Inject/total?color=3fd1c5)](https://github.com/pawnking172/ChestCounter-UI-Inject/releases)

**ChestCounter** counts the chests you open in Fortnite, match after match, straight from your replay files — with an in-game overlay and a detailed HTML report. This repository publishes a **modified Windows build** with extra UI features already compiled in: you only download one `.exe`, no scripts to install.

This is an independent build based on the original open-source project by **LED-N**: [LED-N/Fortnite-ChestCounter](https://github.com/LED-N/Fortnite-ChestCounter). All credit for the original counter goes there.

## Download and run

- **Releases page (all versions):** https://github.com/pawnking172/ChestCounter-UI-Inject/releases
- **Latest version:** https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest
- **Direct EXE download:** https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest/download/ChestCounter.exe

1. Download `ChestCounter.exe` and run it.
2. If Windows says *"Windows protected your PC"*, click **More info → Run anyway** (the exe is not code-signed).
3. Enable ** recorded replays** in Fortnite; the counter reads them and updates the total.
4. Give the app a few seconds; the report and overlay open automatically.

Your data, settings and counted chests are kept between updates.

## Updates: automatic, no work on every release

The counter checks a single file in this repository, [`latest.json`](latest.json), which always names the newest build, its direct download URL, size, SHA-256 checksum and release notes. Every time a release is published, that file is rewritten automatically by the publish script and a GitHub Action — so a new version reaches users without you touching their PC.

- **Check for updates** reads `latest.json` first and falls back to the GitHub API.
- The default setting, **Installed automatically**, downloads and starts the new build by itself. The app re-checks every 5 minutes while it is open — no restart needed.
- **Settings → Updates** lets you choose *Installed automatically*, *Offered* or *Off*, shows the installed version and has a **Download the latest build** button.
- Older installed builds still find new releases through the GitHub releases API.

## What is different from the original build

- A `Last: <count> chests @ <time> | Team: <count>` line next to the total in `report.html` and `overlay.html`.
- An **All treasure prizes** table at the end of the report: every week plus the Pirate Shop, with images, odds and `Got it ×count (date)` markers. Prizes you confirmed yourself can be added to `cc-prize-manual.json`.
- A **Last match — you & squad** section with exact per-player counts. A teammate outside replay range (~150 m) is shown as `not in range`, never `0`.
- A **Map** tab using the current island image with verified spawn points and 9 vaults (4 rare chests + 1 rare sprite chest each), with zoom, pan, fullscreen and filters.
- Live Treasure Hour and Captain's Day banners plus an **Events** tab with token facts, countdowns, next times and source links. **Your token progress** shows your chance at Epic's base odds (1 in 137,500) from your verified chest count.
- A momentum chart, tab icons, appearance settings (theme and accent), live-counting controls, and a fast overlay that updates without flicker.
- The embedded injector re-applies the report/overlay changes after the program rewrites those pages, and only writes a file when its bytes actually change.

## Counts stay honest

The displayed total starts from the confirmed Fortnite baseline in `cc-counts.json`:

```json
{ "treasure": 965, "rare": 71, "sprite": 32 }
```

That is **1,068** chests, then it grows with each new match. teamp totals come from replay events; ammo boxes and pirate cannon shots are not counted. Replays only record players near you (~150 m), so missing far-away teammates are reported as `not in range`, not zero.

See [`RELEASE_NOTES.md`](RELEASE_NOTES.md) for the full changelog of the current build.

---

## العربية

نسخة من **ChestCounter** مع تعديلات واجهة على التقرير والـ overlay. الملف التنفيذي نفسه مبني من مصدر البرنامج الرسمي، والتعديلات مدمجة داخله — ما تحتاج تشغّل أي سكربت يدوي.

### تحميل النسخة المعدّلة

- **الصفحة الرئيسية في GitHub** (كل النسخ تنزل فيها): https://github.com/pawnking172/ChestCounter-UI-Inject/releases — ومنها `latest.json` اللي يقرأه البرنامج.
- أحدث نسخة: https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest
- تحميل مباشر: https://github.com/pawnking172/ChestCounter-UI-Inject/releases/latest/download/ChestCounter.exe

زر **Check for updates** يقرأ ملف الريبو الرئيسي `latest.json` أول شيء (فيه رقم أحدث نسخة ورابط التحميل والحجم والـ SHA256 والملاحظات)، ثم يرجع لـ GitHub API كاحتياط. أي ريليز جديد ينشر، سكربت النشر و GitHub Actions يحدّثون `latest.json` لحالهم، فالبرنامج يوصل لأحدث نسخة مهما كان رقم اللي عندك. الإعداد الافتراضي **Installed automatically** ينزّلها ويشغّلها لحاله وهو شغال، والفحص يتكرر كل 5 دقائق بدون ما تفتح البرنامج من جديد. بياناتك وإعداداتك محفوظة. لو ما طلع تحديث، الرسالة تعرض رقمك ورقم أحدث إصدار على GitHub عشان تعرف الحالة بالضبط. من **Settings → Updates** تشوف رقم النسخة المثبتة وزر **Download the latest build** للتحميل اليدوي.

لصديقك: حمّل `ChestCounter.exe` من الرابط المباشر، شغّله (لو طلع SmartScreen: More info → Run anyway)، وبعدين زر **Check for updates** يوصله أي تحديث جديد. `enable-updates.reg` ما يحتاجه لأن الرابط مدمج في النسخة المبنية.

### وش فيه جديد على الأصلي

1. سطر `Last: <عدد> chests @ <وقت> | Team: <عدد>` جنب التوتال في `report.html` و `overlay.html`.
2. قسم مستقل `All treasure prizes — every week` في آخر `report.html` يعرض كل جوائز الأسابيع + Pirate Shop، واللي حصلت عليها أنت أو الفريق موسوم بـ `Got it` مع العدد والتاريخ (وتقدر تضيف جوائز أكدتها بنفسك عبر `cc-prize-manual.json`). الجوايز تبقى كمان في أقسام البرنامج الأصلية.
3. التوتال المعروض هو العدد المؤكد من Fortnite في `cc-counts.json` ( treasure / rare / sprite )، مع سطر منفصل لعدد الريبلايز.
4. قسم `Last match — you & squad`: آخر مباراة، كم فتحت أنت، كم فتح الفريق، واسم كل صديق وعدّه بالضبط. إذا الريبلاي ما سجّل أي صندوق لصديق (لأنه كان بعيد عنك أكثر من ~150 م) نعرض `not in range` مو `0` — يعني «ما نعرف» مو «فتح صفر».
4b. تبويب الخريطة يستعمل نفس صورة الخريطة الحالية مع إحداثيات مضبوطة من ملفات اللعبة (Fortnite 43.10 عبر fortnite-api)؛ علامات الخزنات والبقع ثابتة وما فيها علامات لصناديق مفتوحة.تم التحقق مرتين: مطابقة بكسل بين صورة المصدر 2048 والصورة المدمجة 1560×918 (الانحراف أقل من 4 بكسل)، ومطابقة صناديق من ريبلايز حقيقية مع نقاطSpawn (انحراف ~1 بكسل). مواقع الـ9 خزنات الكبيرة مضبوطة حسب مصدر Polygon (كل خزنة فيها 4 صناديق نادرة + صندوق سبرايت نادر)، بدل الـ8 نقاط القديمة اللي كانت بعيدة عن أماكن الخزنات الفعلية.
4c. عدّ الفريق يجي من نفس أحداث الريبلاي: كل بحث يُنسب للاعب اللي كان يملك الـ pawn في تلك الثانية بالضبط (آمن بعد الـ respawn). أمثلة مفحوصة: 4zwz = 12 / 11 / 2 / 4 حسب المباراة، bd2ni- = 7 صناديق في مباراة 23:53 (منها 2 مكسورة) + 2 مدفع قراصنة ما يُحسبان صندوق. علب الذخيرة كمان ما تُحسب. ما فيه رقم من localStorage ولا تقدير. الريبلاي يسجّل بس اللي ضمن ~150 م منك؛ اللي تشوفه بالـ spectator وهو بعيد عنك ما يظهر في ريبلايك.
5. الـ overlay يعرض بس: التوتال + «You … · Team …» + أسماء الأصدقاء وعددهم. ما فيه جوائز ولا تكرار صفوف.
5b. الوقت والعدّاد الحيّ للـ Treasure Hour تحت قسم `Your chances` (البانر المبني في البرنامج، ما ينحقن جنب التوتال). البانر يعرض الوقت الحلي/القادم، عدّاد ينقص كل ثانية، والمضاعف مع الفرق بالاحتمال (`7,813 → 781` للسيارة ×10). وجدول الجوائز فيه عمود `Treasure Hour` يعرض نفس الفرق لكل جائزة. الأوقات كل سبت 19:00–21:00 UTC والأحد 02:00–04:00 UTC (المواعيد القادمة متوقعة مو مؤكدة رسمياً).
5c. الـ overlay (نافذة اللعبة وصفحة OBS) فيه بس مجموع صناديقك + مجموع التيم وأسماء الأصدقاء، بدون أي سطر وقت أو عدّاد.
5d. منع الـ flick: الحقن ما يكتب أي قيمة متغيّرة بالثانية داخل الـ HTML؛ الملف يتكتب بس لو البايتات تغيّرت فعلاً، فما فيه ريفرش متكرر.
5e. المجموع الكلي يبدأ من 1,068 (965 treasure + 71 rare + 32 sprite) ويزيد لحاله مع كل صندوق جديد — لك وللتيم — في الـ home والـ overlay داخل اللعبة وOBS والتقرير. الأساس محفوظ في `ChestBaselines` داخل `data.json` كـ "العدد المؤكد + عدد الريplays وقت التأكيد"، فما فيه رقم سالب ولا تعديل يدوي مخفي، والعدّاد يتحرك حتى أثناء المبارة لما البرنامج يقرأ الريبلاي الحي. `cc-counts.json` بس يشرح الأساس 965/71/32.
6. المراقب يعيد الحقن تلقائياً بعد كل مرة البرنامج يعيد كتابة `report.html` / `overlay.html`، بس يكتب الملف فعلياً لما المحتوى يتغير فعلاً — ما فيه إعادة كتابة كل ثانيتين، فما فيه وميض/ريفرش مزعج داخل البرنامج. وكمان ينام لما ما فيه أي تغيير بالملفات، فما يستهلك CPU ولا يقرأ `data.json` إلا عند الحاجة.
7. تبويب **Map** فوق: صورة الماب الحالي اللي اخترتها أنت (مدمجة ومضبوطة على نفس إحداثيات الخريطة) مع كل أماكن الخزنات المعروفة (925 عادي، 40 نادر، 69 مدفون، 9 خزنات ضخمة) مرسومة على الخريطة. كل نوع له لونه وشكله الخاص (دائرة، معين، مثلث، مربع، صليب، نجمة…) مع حدود داكنة وبيضاء، فلتر بالنوع واختيار منطقة، وعند تمرير الماوس يطلع النوع والمنطقة والإحداثيات. الصورة والبيانات مدمجة، ما فيه أي تحميل أثناء الاستخدام. وتقدر تكبّر/تصغّر الماب بالماوس أو بأزرار +/−، وتسحب للتنقل، وزر الإعادة يرجّعك للماب الكامل. كمان تقدر تختار منطقة من القائمة فينقل الماب ويتقرب عليها، نسبة الزوم و إحداثيات الماوس ظاهرين على الماب، والكيبورد: +/− زوم، 0 إعادة، أسهم للتحريك، دبل كليك زوم (Alt + دبل كليك تصغير). وزر ⛶ يفتح الماب بملء الشاشة (أو Escape للرجوع) بنفس النسب بدون تشويه. و فيه أزرار `Show all / Hide all` لكل الأنواع مرة واحدة، ومنزلق `Marker size` يكبّر/يصغّر النقاط ويحفظ اختيارك.
8. الإعدادات فيه قسم **Live counting** للتحكم بالعدّ الحي أثناء المباراة (تشغيل/إيقاف وكل كم ثانية يعيد قراءة الريبلاي، من 10 ثواني لدقيقتين) — مفيد لو الجهاز يبطي، والعدّ بعد المباراة ما يتأثر.
9. في أعلى البرنامج band ثابت يتابع **Captain's Day** (يوم الكابتن): أثناء الحدث (24 ساعة من الأحد 2 م UTC / 9 ص ET حسب Polygon) يطلع «Captain's Day active: Oscar Arrives · ends in 6h 27m»، وباقي الأسبوع يوريك اليوم القادم والعدّ التنازلي. اسم الكابتن يجي من أسابيع `content.json` فيتحدث مع كل سبوع بدون تحديث البرنامج، والوقت يتبع إعداداتك (محلي/UTC و12/24).
9b. كمان في أعلى البرنامج band يتابع **Treasure Hour**: لما تكون شغالة يطلع بلون برتقالي «Treasure Hour live now، حتى كذا · تنتهي بعد كذا»، وفي غيرها يوريك موعد القادمة والعدّ التنازلي يتحدث كل ثانية ويتبدل لحاله أول ما تبدأ/تنتهي الساعة. يتبع إعدادات الوقت عندك (محلي/UTC و12/24 ساعة). العدّ والتقرير ما تغيّروا.
10. كل تبويب صار له أيقونة، وتبويب **Home** يبدأ ببانر يعرض اسم الماب الحالي واسم حسابك. تبويب **Home** فيه كرت `Momentum` جديد: رسم بياني لآخر 30 مباراة (كل عمود فيه تاريخ وعدد الصناديق لما تمرر الماوس)، مع الرقم القياسي ومتوسط آخر 5 مباريات والسلسلة الحالية والاتجاه. الإعدادات فيه قسم **Appearance** جديد: ثيم داكن/فاتر/زي Windows وست ألوان (Gold, Ocean, Emerald, Violet, Rose, Ember) — التغيير فوري ومحفوظ، ويخص نافذة البرنامج بس مو الـ overlay ولا OBS.
11. تبويب **Events** جديد: قائمة بكل الأحداث المهمة (دليل التوكن، Treasure Hour، Captain's Day، إعادة الجوائز الأسبوعية). كل كرت فيه: وش الحدث، وش يعطيك، وكيف يأثر على التوكن — مع الحالة (شغال الآن/يبدأ بعد)، العدّ التنازلي، المواعيد القادمة، ورابط المصدر. الحقيقة واضحة: Treasure Hour هو الوحيد اللي يرفع احتمال التوكن (1/137,500 → 1/91,667 ×1.5 أو 1/68,750 ×2)، أما Captain's Day ما يغير الاحتمال بس يبدّل جوائز الأسبوع. النصوص من `content.json` فتتحدث بدون تحديث البرنامج. وفوق القائمة كرت **Your token progress** يحسب احتمال التوكن من عدد صناديقك المؤكد (1/137,500) وكم صندوق تحتاج لـ50%، وزر **Events** صار موجود كمان في Home.

### العدد المؤكد من Fortnite

عدّل `cc-counts.json` في مجلد بيانات البرنامج `%APPDATA%\ChestCounter`:

```json
{ "treasure": 965, "rare": 71, "sprite": 32 }
```

التوتال المعروض = المجموع (1,068)، ويبقى سطر الريبلايز منفصل عشان تعرف الفرق.

### الجوائز اللي الريبلايز ما يقدر يشوفها

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

### المصدر الرسمي

https://github.com/LED-N/Fortnite-ChestCounter/releases/latest

### ملاحظات

- البيانات تُقرأ من `%APPDATA%\ChestCounter\data.json` و `content.json` و `config.json`.
- الملفات `cc-ui-inject.ps1` و `cc-prize-manual.json` و `cc-counts.json` تُستخرج تلقائياً في مجلد البيانات عند أول تشغيل.
- `enable-updates.reg` موجود للضرورة القديمة، لكن النسخة المبنية ما تحتاجه لأن رابط التحديث مدمج فيها.
