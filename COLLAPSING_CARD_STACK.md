# Collapsing Card Stack — Apple Weather uslubidagi scroll effekti

`lib/widgets/collapsing_card_stack.dart`

Bu ekran Apple Weather ilovasidagi "stick & fade" scroll effektini takrorlaydi.
Kartalar scroll paytida tepaga yopishadi, siqiladi va keyingi karta ustiga
chiqqanda opacity bilan yo'qoladi — hech qachon bir-birining ustiga
to'planib qolmaydi.

---

## 1. Asosiy g'oya

Flutter'da bunday effektni `SliverPersistentHeader(pinned: true)` bilan ham
qilish mumkin, **lekin muhim muammo bor**: sliverlar ro'yxatida keyingi sliver
oldingisining **ustiga** chiziladi. Natijada 2-karta 1-kartaga "opacity bilan
kirib ketgandek" ko'rinadi.

Shuning uchun bu yerda boshqa yo'l tanlangan:

> **Scroll fizikasi va vizual qatlam ajratilgan.**
> Scroll `SingleChildScrollView` ichida ketadi, kartalar esa uning ustida
> `Stack` + `Positioned` bilan **qo'lda** joylashtiriladi.

Bu bizga to'liq nazorat beradi: qaysi karta ustida turishi, qanday
balandlikda bo'lishi, qachon yo'qolishi — hammasini o'zimiz hisoblaymiz.

---

## 2. Widget tuzilishi

```
Scaffold
└── SafeArea
    └── LayoutBuilder            ← viewport balandligini oladi
        └── Stack
            ├── SizedBox.expand
            │   └── SingleChildScrollView   ← 1-qatlam: SCROLL FIZIKASI
            │       └── SizedBox(height: totalHeight + viewH)
            │              (bo'sh! faqat scroll masofasini beradi)
            │
            └── Positioned.fill
                └── IgnorePointer            ← 2-qatlam: VIZUAL KARTALAR
                    └── Stack
                        ├── _buildItem(0)
                        ├── _buildItem(1)
                        └── ...
```

### Nima uchun `IgnorePointer`?

Kartalar scroll'ning **ustida** turadi. Agar `IgnorePointer` bo'lmasa,
kartalar barmoq harakatini "yutib yuboradi" va scroll ishlamaydi.
`IgnorePointer` barcha touch eventlarni pastdagi `SingleChildScrollView`
ga o'tkazib yuboradi.

### Nima uchun `SingleChildScrollView` ichi bo'sh?

Unga hech qanday kontent kerak emas — u faqat **scroll offsetini** ishlab
chiqaradi. Balandligi `totalHeight + viewH` qilib berilgan, ya'ni oxirgi
karta ham tepaga pinlanib bo'lguncha yetadigan masofa.

### Nima uchun `for (int i = 0; i < length; i++)`?

Stack'da **oxirgi bola eng ustida** chiziladi. Ro'yxatni to'g'ri tartibda
aylanib chiqsak, `i+1` karta `i` kartaning ustida bo'ladi — bu bizga kerak,
chunki yuqoriga ko'tarilayotgan karta oldingisini **berkitishi** kerak
(orqasi ko'rinmasligi uchun).

---

## 3. Scroll pozitsiyasini kuzatish

```dart
final _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(() => setState(() {}));
}

double get _offset =>
    _scrollController.hasClients ? _scrollController.offset : 0.0;
```

Har bir scroll frameda `setState` chaqiriladi → kartalar qayta hisoblanadi.
`hasClients` tekshiruvi birinchi framedagi crashdan saqlaydi (controller hali
scroll view'ga ulanmagan bo'ladi).

---

## 4. Matematika — eng muhim qism

Har bir karta uchun 4 ta qiymat hisoblanadi.

### 4.1. Tabiiy pozitsiya

Karta scroll bo'lmaganda qayerda turishi kerak edi:

```dart
double _naturalY(int i) {
  double y = 24.0;                    // tepadagi bo'shliq
  for (int j = 0; j < i; j++) {
    y += _items[j].height + _cardSpacing;
  }
  return y;
}
```

### 4.2. Pinlash (sticky)

```dart
final natY = _naturalY(i) - _offset;   // scroll bilan siljigan pozitsiya
final y = math.max(0.0, natY);         // Y=0 dan pastga tushmaydi
```

`math.max(0, ...)` — butun sirning kaliti. Karta ekran tepasiga yetganda
manfiy Y ga o'tmaydi, **0 da qotib qoladi**.

### 4.3. Siqilish — keyingi karta qancha joy qoldirgan?

```dart
double space = itemH;
if (i < _items.length - 1) {
  final nextY = math.max(0.0, _naturalY(i + 1) - _offset);
  space = nextY - y - _cardSpacing;
}

final currentH    = space.clamp(_minHeight, itemH);
final contentShift = itemH - currentH;
```

Bu formulani tushunish muhim:

| Holat | `y` | `nextY` | `space` | Natija |
|---|---|---|---|---|
| Erkin scroll | 200 | 540 | 320 | To'liq balandlik, siqilmaydi |
| Pinlangan, keyingisi yaqinlashmoqda | 0 | 180 | 160 | Yarim siqilgan |
| Keyingisi juda yaqin | 0 | 84 | 64 | To'liq siqilgan (minHeight) |
| Keyingisi ustiga chiqdi | 0 | 20 | 0 | Yo'qoladi |

**Nima uchun `space` orqali?** Avvalgi versiyada balandlik alohida
`progress` formula bilan hisoblanardi va keyingi karta pozitsiyasi bilan
sinxron emas edi — natijada karta keyingi kartaning ustiga chiqib ketardi.
`space` bevosita keyingi kartaga qadar bo'lgan masofa bo'lgani uchun,
karta **hech qachon** o'ziga ajratilgan joydan katta bo'lolmaydi.

### 4.4. Fade out

```dart
final displayOpacity =
    space < _minHeight ? (space / _minHeight).clamp(0.0, 1.0) : 1.0;
```

Karta `minHeight` (64px) gacha siqilgach, undan keyin **shaffoflashadi**.
`space` 0 ga yetganda `opacity == 0` — karta butunlay yo'qoladi, demak
kartalar ustma-ust to'planib qolmaydi.

### 4.5. Optimizatsiya

```dart
if (y > viewH || displayOpacity <= 0.0) return const SizedBox.shrink();
```

Ekrandan tashqaridagi va ko'rinmas kartalar umuman qurilmaydi.

---

## 5. Kontent sirg'alishi — "clip emas, slide"

Bu effektning eng nozik detali. Karta siqilganda kontent **pastdan
kesilmaydi** — u karta ichida **yuqoriga sirg'aladi**, sarlavha esa
joyida qotib turadi.

```dart
Container(
  clipBehavior: Clip.antiAlias,       // tashqariga chiqqan qism kesiladi
  child: Stack(
    children: [
      // 1. Kontent — yuqoriga sirg'aladi
      Positioned(
        top: -contentShift,           // ← manfiy Y = yuqoriga siljish
        left: 0, right: 0,
        height: fullH,                // ← DOIM to'liq balandlik
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: _CardBody(data: data),
        ),
      ),

      // 2. Sarlavha — qotib turadi, kontent USTIDA
      Positioned(
        top: 0, left: 0, right: 0,
        child: Container(
          color: const Color(0xFF2C2C2E),   // ← opaque! kontentni berkitadi
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: _TitleRow(data: data),
        ),
      ),
    ],
  ),
)
```

Uchta detal muhim:

1. **`top: -contentShift`** — kontent yuqoriga suriladi, sarlavha ostiga
   kirib ketadi.
2. **`height: fullH`** — kontent har doim to'liq balandlikda quriladi,
   aks holda `Column` layouti siqilish paytida "sakraydi".
3. **Sarlavha `Container` rangi opaque** — aks holda ostidan sirg'alib
   o'tayotgan kontent ko'rinib qoladi.

Agar buni oddiy `ClipRect` bilan pastdan kesish orqali qilinsa — noto'g'ri
bo'ladi: kontent joyida qolib, faqat pastki qismi yo'qoladi. Bu Apple
Weather effekti emas.

---

## 6. Karta turlari

Ro'yxat `_Item` obyektlaridan iborat. Ikki xil bo'ladi:

```dart
class _Item {
  final _CardData left;
  final _CardData? right;      // null bo'lsa — bitta karta
  final double height;
  bool get isPair => right != null;

  _Item.single(this.left, {required this.height}) : right = null;
  _Item.pair(this.left, _CardData r, {required this.height}) : right = r;
}
```

### 6.1. Single card (320px)

Bitta keng karta: sarlavha + katta raqam + progress bar.

### 6.2. Pair card (200px)

Ikkita kichik karta yonma-yon. Muhim: ular **bitta umumiy container ichida
emas**, balki ikkita **alohida** karta:

```dart
Row(
  children: [
    Expanded(child: _buildMiniCard(item.left,  fullH, contentShift)),
    const SizedBox(width: 12),                    // ← ko'rinadigan bo'shliq
    Expanded(child: _buildMiniCard(item.right!, fullH, contentShift)),
  ],
)
```

Har biri o'zining `borderRadius`, `boxShadow` va `clipBehavior` iga ega.
Ikkalasi bir xil `contentShift` qiymatini oladi, shuning uchun **birga**
siqiladi va **birga** yo'qoladi — lekin vizual jihatdan alohida qoladi.

> Boshida ular bitta container ichiga solingan edi va o'rtasiga divider
> chizilgan edi — natijada "qo'shilib ketgandek" ko'rinardi. Alohida
> containerlarga ajratilgandan keyin muammo hal bo'ldi.

---

## 7. Dizayn qiymatlari

| Element | Qiymat |
|---|---|
| Fon | `#1C1C1E` (iOS dark) |
| Karta foni | `#2C2C2E` |
| Border radius | `20` |
| Soya | `black @ 30%`, blur `16`, offset `(0, 6)` |
| Yon padding | `16` (ekran chetidan) |
| Kartalar orasi | `20` (`_cardSpacing`) |
| Juftlik orasi | `12` |
| Minimal balandlik | `64` (`_minHeight`) |
| Katta raqam | `56px / w800` |
| Kichik raqam | `36px / w700` |
| Sarlavha | `13px / w600 / uppercase / letterSpacing 0.5` |
| Scroll fizikasi | `BouncingScrollPhysics` (iOS uslubi) |

---

## 8. Yangi karta qo'shish

`_items` ro'yxatiga qator qo'shish yetarli:

```dart
// Bitta keng karta
_Item.single(
  _CardData('Protein', '85 g', Color(0xFFAF52DE), Icons.egg),
  height: 320,
),

// Ikkita yonma-yon karta
_Item.pair(
  _CardData('Fiber',  '22 g', Color(0xFFFF9F0A), Icons.grass),
  _CardData('Sodium', '1.2 g', Color(0xFF5AC8FA), Icons.science),
  height: 200,
),
```

Balandlik ixtiyoriy — `_naturalY()` va `_totalHeight` avtomatik moslashadi.

---

## 9. Yo'l davomida uchragan xatolar

| Muammo | Sabab | Yechim |
|---|---|---|
| Kartalar bir-biriga "opacity bilan kirib ketardi" | `SliverPersistentHeader` da keyingi sliver oldingisining ustiga chiziladi | Sliverlardan voz kechib, `Stack` + `Positioned` bilan qo'lda joylashtirish |
| Ekran bo'm-bo'sh (faqat fon) | `Stack` ichidagi `SingleChildScrollView` ga aniq o'lcham berilmagandi | `LayoutBuilder` + `SizedBox.expand` |
| Scroll ishlamasdi | Kartalar touch eventlarni yutib yuborardi | Kartalar qatlamini `IgnorePointer` ga o'rash |
| Butun karta birdan yo'q bo'lardi | Siqilish bosqichi yo'q edi, faqat opacity ishlardi | Avval balandlikni kamaytirish, keyin fade |
| Ustidagi kartaning orqasi ko'rinardi | Chizish tartibi teskari edi (`length-1 → 0`) | Tartibni `0 → length` ga o'zgartirish |
| Juftlik kartalar qo'shilib ketgandek | Bitta umumiy container + divider chizig'i | Ikkita alohida container, orasida 12px |
| Oddiy karta juftlik kartaning ustiga chiqardi | Balandlik keyingi karta pozitsiyasi bilan sinxron emas edi | `space = nextY - y - spacing` formulasiga o'tish |

---

## 10. Ishlatilgan Flutter tushunchalari

- `ScrollController` + `addListener` — scroll offsetini kuzatish
- `LayoutBuilder` — viewport o'lchamini olish
- `Stack` / `Positioned` — qo'lda pozitsiyalash
- `IgnorePointer` — touch eventlarni o'tkazib yuborish
- `Clip.antiAlias` — karta ichidagi kontentni kesish
- `Opacity` — fade out
- `clamp()` — qiymatni chegaralash
- `math.max()` — sticky pinlash
- `FractionallySizedBox` — progress bar
- `BouncingScrollPhysics` — iOS scroll hissi
