# PromptGenerator

[![pub package](https://img.shields.io/pub/v/prompt_generator.svg)](https://pub.dev/packages/prompt_generator)

🌐 **[English](https://github.com/abbos2101/prompt_generator/blob/main/README.md)** | **[O'zbekcha](https://github.com/abbos2101/prompt_generator/blob/main/README_UZ.md)**

**Jamoadoshlaringizdan kontekst so'rashni to'xtating. Notanish kod bazalaridan qo'rqishni bas qiling. AI sizning Flutter loyihangizni bir zumda tushunsin.**

Flutter loyihangiz kodini Claude, ChatGPT, DeepSeek, Grok va boshqa AI vositalari uchun aqlli tarzda yig'ib, formatlash orqali kod bazangiz va AI yordamchilari o'rtasidagi bo'shliqni to'ldiruvchi Flutter paketi.

## Nima uchun PromptGenerator?

Yangi loyihaga qo'shilib, o'zingizni yo'qotib qo'yganmisiz? Senior dasturchi vazifa bergan, lekin "oddiy" savollar berishdan uyalganmisiz? Jamoangizni bezovta qilmasdan arxitektura qarorlaringizni ekspert bilan muhokama qilishni xohlaganmisiz?

**PromptGenerator buni hal qiladi.** U loyihangizning tegishli kodini bitta AI-ga tayyor formatga chiqarib beradi, uni to'g'ridan-to'g'ri istalgan AI yordamchisiga joylashtirishingiz mumkin. Endi qo'lda fayl qidirish yo'q, to'liq bo'lmagan kontekst yo'q, uyalish yo'q.

## Nima Qiladi

- **Bir zumda AI Konteksti**: Kod bazangizning to'liq suratini soniyalarda yarating
- **Aqlli Tanlash**: Qaysi fayllar va papkalar muhimligini aniq sozlang
- **AI uchun Optimallashtirilgan**: AI yordamchilari mukammal tushunadigan formatda chiqaradi
- **Maxfiylik Birinchi**: Generatsiya qilingan fayllarni (.g.dart, .freezed.dart) va maxfiy ma'lumotlarni avtomatik o'tkazib yuboradi
- **Nol Sozlash**: Oddiy YAML konfiguratsiyasi, bitta buyruq bilan ishga tushirish
- **Kod Siqish**: Kod strukturasini saqlab, token sarfini 40-60% kamaytiradi

## Kimlar Uchun Ideal

- 🆕 **Notanish loyihalarga qo'shilish** - Jamoadoshlarni bezovta qilmasdan arxitekturani tushuning
- 🤖 **AI Yordamida Dasturlash** - O'zingizning kod bazangiz bo'yicha ekspert darajasidagi maslahat oling
- 📚 **Kod Sharhlari** - Tahlil uchun AI bilan kontekstga boy kod bo'laklarini ulashing
- 🏗️ **Arxitektura Muhokamasi** - To'liq loyiha konteksti bilan refaktoring strategiyalarini muhokama qiling
- 📖 **Hujjatlashtirish** - Kod bazasining keng qamrovli sharhlarini yarating
- 👥 **Jamoa Hamkorligi** - Yangi dasturchilar bilan loyiha strukturasini ulashing
- 🔍 **Kod Tahlili** - AI-ga pattern, muammolar yoki yaxshilash imkoniyatlarini aniqlashga ruxsat bering

## Boshlash

`prompt_generator`ni `pubspec.yaml`ga qo'shing:
```yaml
dev_dependencies:
  prompt_generator: ^latest_version
```

## Foydalanish

### 1. Konfiguratsiya Faylini Yarating

Loyihangiz ildizida `prompt_generator.yaml` faylini yarating:
```yaml
needYaml: true
copyToClipboard: false
savedFile: "app-code.txt" # Saqlashni o'tkazib yuborish uchun bo'sh qoldiring
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

### 2. Promptingizni Yarating

Loyihangiz papkasida bu buyruqni ishga tushiring:
```bash
dart run prompt_generator:generate
```

### 3. AI bilan Ulashing

Yaratilgan `app-code.txt` kontentini nusxalab, to'g'ridan-to'g'ri Claude, ChatGPT, DeepSeek, Grok yoki boshqa AI yordamchisiga joylashtiring. Endi siz:

- O'ZINGIZNING loyihangiz haqida arxitektura savollarini bering
- O'ZINGIZNING haqiqiy kodingiz asosida refaktoring takliflarini so'rang
- O'ZINGIZNING kontekstingizni tushunadigan implementatsiya yordamini oling
- To'liq loyiha xabardorligi bilan xatolarni tuzating

## Konfiguratsiya Parametrlari

| Parametr             | Turi    | Tavsifi                                                  |
|----------------------|---------|----------------------------------------------------------|
| `needYaml`           | boolean | Chiqishga YAML konfiguratsiya fayllarini qo'shish        |
| `copyToClipboard`    | boolean | Chiqishni avtomatik buferga nusxalash                    |
| `savedFile`          | string  | Chiqish fayl nomi (fayl yaratishni o'tkazib yuborish uchun bo'sh qoldiring) |
| `skipFiles`          | list    | Chiqarib tashlanadigan fayl patternlari (wildcardlarni qo'llab-quvvatlaydi) |
| `includePaths`       | list    | Chiqishga kiritiladigan papkalar                         |
| `compressService`    | boolean | Tokenlarni kamaytirish uchun kod siqishni yoqish (standart: false) |
| `doNotCompressPaths` | list    | Siqishdan chiqarib tashlanadigan fayl patternlari        |

### Konfiguratsiya Misollari

**Minimal Sozlash** - Faqat zaruriy narsalar:
```yaml
needYaml: false
copyToClipboard: true
savedFile: "my-project.txt"
skipFiles: ['.g.dart', '.freezed.dart']
includePaths: [lib/]
```

**Feature-ga Yo'naltirilgan** - Faqat ma'lum featurelar:
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

**To'liq Loyiha** - Keng qamrovli sharh:
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

**Siqish Bilan** - Katta loyihalar uchun token sarfini kamaytirish:
```yaml
needYaml: true
copyToClipboard: true
savedFile: "compressed-code.txt"
compressService: true
doNotCompressPaths: [
  '_model.dart',
  '_facade.dart',
  '_state.dart',
  '_event.dart',
]
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
]
```

## Kod Siqish

`compressService: true` bo'lganda, metod tanelari `/* impl */` bilan almashtiriladi va token sonini sezilarli kamaytiradi, shu bilan birga quyidagilarni saqlaydi:

- Klass va metod signaturelari
- Konstruktor ta'riflari
- Field deklaratsiyalari
- Import iboralari
- Kod strukturasi va arxitekturasi

**Siqishdan oldin:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthFacade _authFacade;

  AuthBloc(this._authFacade) : super(const AuthState.initial());

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: VarStatus.loading()));
    final result = await _authFacade.login(event.username, event.password);
    result.fold(
      (l) => emit(state.copyWith(loginStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(loginStatus: VarStatus.success())),
    );
  }
}
```

**Siqishdan keyin:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthFacade _authFacade;

  AuthBloc(this._authFacade) : super(const AuthState.initial());

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    /* impl */
  }
}
```

Muhim fayllarni siqmasdan saqlash uchun `doNotCompressPaths` dan foydalaning (modellar, facadelar, statelar, eventlar).

## Haqiqiy Hayotiy Stsenariylar

**Stsenariy 1: Jamoaga Yangi Qo'shilish**
> Murakkab state managementli loyihaga qo'shildingiz. Tech leadni bezovta qilish o'rniga, promptni yarating, Claude-ga joylashtiring va so'rang: "Bu loyihaning state management arxitekturasini tushuntiring va yangi feature qayerga qo'shishim kerak."

**Stsenariy 2: Vazifada Qotib Qolish**
> Senior dev sizga notanish moduldagi refaktoring vazifasini berdi. O'sha aniq yo'l uchun promptni yarating, AI-dan so'rang: "Buni clean architecture prinsiplariga muvofiq qanday refaktor qilishim kerak?"

**Stsenariy 3: Kod Sharhiga Tayyorgarlik**
> PR yuborishdan oldin, feature kodingizni yarating, AI-dan so'rang: "Bu implementatsiyani potensial muammolar, edge caselar va best practices buzilishlari uchun ko'rib chiqing."

**Stsenariy 4: Katta Kod Bazasi**
> Loyihangiz AI kontekst limitlari uchun juda katta. To'liq arxitektura ko'rinishini saqlab, tokenlarni 40-60% kamaytirish uchun `compressService: true`ni yoqing.

## Xususiyatlar

- Bitta buyruqli kod yig'ish
- Moslashuvchan yo'l konfiguratsiyasi
- Aqlli fayl filtrlash
- Ixtiyoriy bufer integratsiyasi
- Sozlanishi mumkin chiqish formati
- Qo'lda fayl nusxalash yo'q
- Barcha AI yordamchilari bilan ishlaydi
- Token optimizatsiyasi uchun kod siqish

## Eng Yaxshi Natijalar Uchun Maslahatlar

1. **Aniq Bo'ling**: Savolingiz uchun faqat tegishli papkalarni kiriting
2. **Avval Tozalang**: Shovqinni kamaytirish uchun generatsiya qilingan va test fayllarni o'tkazib yuboring
3. **Aniq So'rang**: AI-ga joylashtirganda, savolingizni kontekst bilan shakllantiring
4. **Takrorlang**: Turli savollar uchun turli yo'llar bilan qayta yarating
5. **Vositalarni Birlashtiring**: Maksimal foyda uchun AI yordamchingizning boshqa imkoniyatlari bilan birga foydalaning
6. **Siqishni Ishlating**: Katta loyihalar uchun, AI kontekstiga ko'proq kod sig'dirish uchun `compressService`ni yoqing

## Hissa Qo'shish

Hissa qo'shishlar qabul qilinadi! Muammolar va pull requestlar yuborishingiz mumkin.

---

**Ikkilanishni to'xtating. Yuborishni boshlang.** AI sizning senior dasturchingiz, arxitektoringiz va kod sharhlovchingiz bo'lsin - barchasi SIZNING loyihangizni to'liq bilib.