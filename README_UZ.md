# PromptGenerator

[![pub package](https://img.shields.io/pub/v/prompt_generator.svg)](https://pub.dev/packages/prompt_generator)

<br>
---
**[English](https://github.com/abbos2101/prompt_generator/blob/main/README.md)** | **[O'zbekcha](https://github.com/abbos2101/prompt_generator/blob/main/README_UZ.md)**

**Jamoadan kontekst so'rashni bas qiling. Notanish kod bazasidan qo'rqishni to'xtating. AIga butun Flutter proyektingizni bir zumda tushuntiring.**

Flutter proyektingiz kodlarini yig'ib, Claude, ChatGPT, DeepSeek, Grok va boshqa AI yordamchilarga tushunarli formatda taqdim etuvchi package.

## Nega PromptGenerator?

Yangi proyektga qo'shilganingizda yo'qolgan his qildingizmi? Katta dasturchidan vazifa olganingizda "oddiy" savollar berishdan uyaldingizmi? Arxitektura qarorlaringizni mutaxassis bilan muhokama qilmoqchi bo'lganingizda, lekin jamoangizni bezovta qilishni xohlamadingizmi?

**PromptGenerator buni hal qiladi.** U proyektingizning kerakli kodlarini AI uchun tayyor formatda chiqaradi va siz uni to'g'ridan-to'g'ri AI yordamchiga joylashtira olasiz. Endi qo'lda fayl qidirish, to'liq bo'lmagan kontekst va sharmanda bo'lish yo'q.

## Nima qiladi?

- **Bir zumda AI Konteksti**: Kod bazangizning to'liq ko'rinishini soniyalar ichida yarating
- **Aqlli Tanlov**: Qaysi fayllar va papkalar muhimligini aniq sozlang
- **AI uchun Optimallashtirilgan**: AI yordamchilar tushunadigan formatda chiqaradi
- **Maxfiylik Birinchi**: Generatsiya qilingan fayllarni (.g.dart, .freezed.dart) va maxfiy ma'lumotlarni avtomatik o'tkazib yuboradi
- **Nol Sozlash**: Oddiy YAML konfiguratsiyasi, bir buyruq bilan ishga tushiring

## Qaysi holatlarda ideal?

- 🆕 **Notanish proyektlarga onboarding** - Jamodoshlarni bezovta qilmasdan arxitekturani tushunish
- 🤖 **AI yordamida Dasturlash** - O'z kod bazangiz bo'yicha ekspert darajasida maslahat olish
- 📚 **Kod Ko'rib Chiqish** - AI bilan tahlil qilish uchun kontekstli kod ulashish
- 🏗️ **Arxitektura Muhokamasi** - To'liq proyekt konteksti bilan refaktoring strategiyalarini muhokama qilish
- 📖 **Hujjatlashtirish** - Kod bazasining to'liq ko'rinishini yaratish
- 👥 **Jamoa Hamkorligi** - Yangi dasturchilarga proyekt strukturasini ulashish
- 🔍 **Kod Tahlili** - AIga pattern'lar, muammolar yoki yaxshilash imkoniyatlarini topishga yordam berish

## Boshlash

`prompt_generator`ni `pubspec.yaml` faylingizga qo'shing:
```yaml
dev_dependencies:
  prompt_generator: ^latest_version
```

## Foydalanish

### 1. Konfiguratsiya Faylini Yarating

Proyekt ildizida `prompt_generator.yaml` fayl yarating:
```yaml
needYaml: true
copyToClipboard: false
savedFile: "app-code.txt" # Bo'sh qoldirish saqlamaslik uchun
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '.config.dart',
  '/.',
]
includePaths: [
  lib/presentation,
  lib/domain,
]
```

### 2. Promptni Generatsiya Qiling

Proyekt papkangizda ushbu buyruqni bajaring:
```bash
dart run prompt_generator:generate
```

### 3. AI bilan Ulashing

Yaratilgan `app-code.txt` faylining mazmunini nusxalab, Claude, ChatGPT, DeepSeek, Grok yoki istalgan AI yordamchiga to'g'ridan-to'g'ri joylang. Endi siz:

- O'Z proyektingiz bo'yicha arxitektura savollarini bera olasiz
- O'Z haqiqiy kodingizga asoslangan refaktoring takliflarini so'ray olasiz
- O'Z kontekstingizni tushunadigan implementatsiya yordamini oling
- To'liq proyekt bilan xabardorlik bilan muammolarni hal qiling

## Konfiguratsiya Parametrlari

| Parametr          | Turi    | Ta'rif                                                   |
|-------------------|---------|----------------------------------------------------------|
| `needYaml`        | boolean | YAML konfiguratsiya fayllarini chiqishga qo'shish        |
| `copyToClipboard` | boolean | Chiqishni avtomatik tarzda clipboardga nusxalash         |
| `savedFile`       | string  | Chiqish fayl nomi (bo'sh qoldirish fayl yaratmaslik uchun)|
| `skipFiles`       | list    | O'tkazib yuborish uchun fayl pattern'lari (wildcardlarni qo'llab-quvvatlaydi) |
| `includePaths`    | list    | Chiqishga qo'shiladigan papkalar                         |

### Konfiguratsiya Misollari

**Minimal Sozlama** - Faqat zarur narsa:
```yaml
needYaml: false
copyToClipboard: true
savedFile: "my-project.txt"
skipFiles: ['.g.dart', '.freezed.dart']
includePaths: [lib/]
```

**Feature'ga Qaratilgan** - Faqat ma'lum feature'lar:
```yaml
needYaml: true
copyToClipboard: false
savedFile: "feature-code.txt"
skipFiles: ['.freezed.dart', '.g.dart', '_test.dart']
includePaths: [
  lib/features/auth,
  lib/features/profile,
]
```

**To'liq Proyekt** - Keng qamrovli ko'rinish:
```yaml
needYaml: true
copyToClipboard: true
savedFile: "full-project.txt"
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '/.',
]
includePaths: [
  lib/presentation,
  lib/domain,
  lib/data,
  lib/core,
]
```

## Real Stsenariylar

**Stsenariy 1: Jamoaga Yangi Qo'shilganingizda**
> Murakkab state management'li proyektga qo'shilasiz. Tech lead'ni bezovta qilish o'rniga, promptni generatsiya qiling, Claude'ga joylang va so'rang: "Bu proyektning state management arxitekturasini tushuntir va yangi feature'ni qayerga qo'shish kerakligini ayting."

**Stsenariy 2: Vazifada Qotib Qolganingizda**
> Senior dasturchi sizga notanish moduldagi refaktoring vazifasini topshirdi. O'sha yo'l uchun promptni generatsiya qiling, AIga so'rang: "Buni clean architecture tamoyillariga rioya qilgan holda qanday refaktoring qilish kerak?"

**Stsenariy 3: Code Review Tayyorlash**
> PR yuborishdan oldin, feature'ingiz kodini generatsiya qiling, AIga so'rang: "Bu implementatsiyani potensial muammolar, edge case'lar va best practice'lar buzilishi uchun ko'rib chiq."

## Xususiyatlar

✅ Bir buyruqda kod yig'ish
✅ Moslashuvchan yo'l konfiguratsiyasi
✅ Aqlli fayl filtrlash
✅ Ixtiyoriy clipboard integratsiyasi
✅ Moslashtiriladigan chiqish formati
✅ Qo'lda fayl nusxalash yo'q
✅ Barcha AI yordamchilar bilan ishlaydi

## Eng Yaxshi Natijalar uchun Maslahatlar

1. **Aniq Bo'ling**: Savolingiz uchun faqat tegishli papkalarni qo'shing
2. **Avval Tozalang**: Shovqinni kamaytirish uchun generatsiya qilingan va test fayllarini o'tkazib yuboring
3. **Aniq So'rang**: AIga joylashtirganingizda, savolingizni kontekst bilan rasmiylashtiring
4. **Iteratsiya Qiling**: Turli savollar uchun turli yo'llar bilan qayta generatsiya qiling
5. **Vositalarni Birlashtiring**: Maksimal foyda uchun AI yordamchingizning boshqa imkoniyatlari bilan birga foydalaning

## Hissa Qo'shish

Hissalar xush kelibsiz! Muammolar va pull requestlar yuborishingiz mumkin.

---

**Ikkilanishni bas qiling. Ishlab chiqarishni boshlang.** AIni o'z senior dasturchingiz, arxitektoringiz va kod ko'rib chiquvchingiz qiling - barchasi SIZNING proyektingiz haqida to'liq ma'lumotga ega holda.