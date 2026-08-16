# Unlock Pattern Animation tushuntirish

Bu fayl [lib/exercises/ex14_unlock_pattern.dart](lib/exercises/ex14_unlock_pattern.dart) ichidagi `Unlock Pattern Animation` qanday ishlashini tushuntiradi.

Bu mashqda uchta narsa birga ishlaydi:

1. `GestureDetector` - barmoq harakatini ushlaydi.
2. `CustomPainter` - nuqtalar, chiziqlar va check belgisini chizadi.
3. `AnimationController` - success va error animatsiyalarini boshqaradi.

## Natija nima qiladi?

Ekranda 3x3 pattern grid bor:

```text
0   1   2

3   4   5

6   7   8
```

To'g'ri pattern:

```text
0 -> 1 -> 2 -> 5 -> 8
```

Ya'ni yuqori qatordagi 3 ta nuqta, keyin o'ng tomondan pastga.

Agar user shu patternni chizsa:

- chiziqlar yashil bo'ladi;
- status `Unlocked` bo'ladi;
- markazda check belgisi chizilib chiqadi.

Agar pattern xato bo'lsa:

- chiziqlar qizil bo'ladi;
- status `Xato pattern` bo'ladi;
- grid chap-o'ng shake qiladi;
- birozdan keyin reset bo'ladi.

## State ichidagi muhim o'zgaruvchilar

```dart
late final AnimationController _shakeController;
late final AnimationController _successController;

final List<int> _selected = [];
final List<int> _answer = const [0, 1, 2, 5, 8];

Offset? _dragPosition;
_PatternResult _result = _PatternResult.idle;
```

### `_shakeController`

Xato pattern chizilganda butun gridni chap-o'ng silkitadi.

### `_successController`

To'g'ri pattern chizilganda check belgisi va pulse effektini yurgizadi.

### `_selected`

User qaysi nuqtalarni tanlaganini saqlaydi.

Masalan user yuqoridan chizsa:

```dart
_selected = [0, 1, 2];
```

### `_answer`

To'g'ri javob patterni.

```dart
final List<int> _answer = const [0, 1, 2, 5, 8];
```

Shuni o'zgartirsang, to'g'ri pattern ham o'zgaradi.

### `_dragPosition`

Barmoq hozir qayerda turganini saqlaydi. Bu hali keyingi nuqtaga ulanmagan vaqtinchalik chiziqni chizish uchun kerak.

### `_result`

Pattern holatini bildiradi:

```dart
enum _PatternResult { idle, drawing, success, error }
```

- `idle` - hali hech narsa chizilmagan.
- `drawing` - user hozir barmoq bilan chizyapti.
- `success` - pattern to'g'ri.
- `error` - pattern xato.

## GestureDetector qanday ishlaydi?

Asosiy joy:

```dart
GestureDetector(
  onPanStart: _start,
  onPanUpdate: _update,
  onPanEnd: _end,
  onPanCancel: _reset,
  child: ...
)
```

### `onPanStart`

User barmog'ini gridga tekkizganda ishlaydi.

Bu paytda:

- eski animatsiyalar to'xtatiladi;
- `_selected` tozalanadi;
- result `drawing` bo'ladi;
- birinchi nuqta tekshiriladi.

```dart
void _start(DragStartDetails details) {
  _shakeController.stop();
  _successController.stop();
  _shakeController.value = 0;
  _successController.value = 0;

  setState(() {
    _selected.clear();
    _dragPosition = details.localPosition;
    _result = _PatternResult.drawing;
    _addPoint(details.localPosition, const Size(300, 300));
  });
}
```

`details.localPosition` - barmoq `CustomPaint` ichida qayerda turgani.

### `onPanUpdate`

User barmog'ini sudraganda har frame ishlaydi.

```dart
void _update(DragUpdateDetails details) {
  if (_result != _PatternResult.drawing) return;

  setState(() {
    _dragPosition = details.localPosition;
    _addPoint(details.localPosition, const Size(300, 300));
  });
}
```

Bu yerda ikkita ish bo'ladi:

1. `_dragPosition` yangilanadi.
2. Barmoq biror nuqtaga yaqinlashganmi, tekshiriladi.

### `onPanEnd`

User barmog'ini qo'yib yuborganda ishlaydi.

```dart
void _end(DragEndDetails details) {
  if (_selected.isEmpty) {
    _reset();
    return;
  }

  final isCorrect = _selected.length == _answer.length;
  final matches = isCorrect &&
      List.generate(_answer.length, (i) => _selected[i] == _answer[i])
          .every((match) => match);

  setState(() {
    _dragPosition = null;
    _result = matches ? _PatternResult.success : _PatternResult.error;
  });

  if (matches) {
    _successController.forward(from: 0);
  } else {
    _shakeController.forward(from: 0);
  }
}
```

Bu funksiya `_selected` bilan `_answer`ni solishtiradi.

Masalan:

```dart
_selected = [0, 1, 2, 5, 8];
_answer   = [0, 1, 2, 5, 8];
```

Ikkalasi bir xil bo'lsa success.

## Nuqtani tanlash qanday ishlaydi?

```dart
void _addPoint(Offset position, Size size) {
  final points = _PatternGrid.points(size);
  for (int i = 0; i < points.length; i++) {
    final distance = (position - points[i]).distance;
    if (distance < 34 && !_selected.contains(i)) {
      _selected.add(i);
    }
  }
}
```

Bu yerda har bir nuqtagacha masofa hisoblanadi.

```dart
final distance = (position - points[i]).distance;
```

Agar barmoq nuqtaga 34 pixeldan yaqin bo'lsa, nuqta tanlanadi:

```dart
if (distance < 34)
```

`!_selected.contains(i)` esa bir nuqta ikki marta qo'shilib ketmasligi uchun.

## 3x3 nuqtalar koordinatasi

Nuqtalarni `_PatternGrid.points` hisoblaydi:

```dart
class _PatternGrid {
  static List<Offset> points(Size size) {
    final gapX = size.width / 4;
    final gapY = size.height / 4;
    final points = <Offset>[];

    for (int row = 1; row <= 3; row++) {
      for (int col = 1; col <= 3; col++) {
        points.add(Offset(gapX * col, gapY * row));
      }
    }

    return points;
  }
}
```

Grid size `300x300` bo'lsa:

```text
gapX = 300 / 4 = 75
gapY = 300 / 4 = 75
```

Shunda nuqtalar taxminan shunday joylashadi:

```text
(75, 75)    (150, 75)    (225, 75)

(75, 150)   (150, 150)   (225, 150)

(75, 225)   (150, 225)   (225, 225)
```

Nega `/ 4`? Chunki 3 ta nuqta bor, lekin chap va o'ng chetda ham bo'sh joy qolishi kerak. Shuning uchun 4 ta intervalga bo'lyapmiz.

## CustomPainter nima chizadi?

`_PatternPainter` hamma vizual qismni chizadi:

- inactive nuqtalar;
- selected nuqtalar;
- selected nuqtalar orasidagi chiziq;
- barmoq bilan oxirgi nuqta orasidagi vaqtinchalik chiziq;
- success bo'lsa check belgisi.

### Paint obyektlari

```dart
final inactivePaint = Paint()
  ..color = const Color(0xFFE1E7EF)
  ..style = PaintingStyle.fill;

final ringPaint = Paint()
  ..color = activeColor.withValues(alpha: 0.18)
  ..style = PaintingStyle.fill;

final linePaint = Paint()
  ..color = activeColor
  ..strokeWidth = 8
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;
```

`Paint` - canvasga qanday chizishni aytadi:

- rang qanday;
- stroke qalinligi qancha;
- fill yoki stroke bo'ladimi.

### Tanlangan nuqtalar orasidagi chiziq

```dart
if (selected.length > 1) {
  final path = Path()
    ..moveTo(points[selected.first].dx, points[selected.first].dy);
  for (final index in selected.skip(1)) {
    path.lineTo(points[index].dx, points[index].dy);
  }
  canvas.drawPath(path, linePaint);
}
```

Bu yerda `Path` yasaladi:

1. Birinchi selected nuqtadan boshlaydi.
2. Keyingi selected nuqtalarga `lineTo` qiladi.
3. Canvasga chizadi.

### Vaqtinchalik drag chizig'i

```dart
if (selected.isNotEmpty &&
    dragPosition != null &&
    result == _PatternResult.drawing) {
  final last = points[selected.last];
  canvas.drawLine(last, dragPosition!, linePaint);
}
```

Bu barmoq hali keyingi nuqtaga yetmagan paytdagi chiziq.

Masalan selected oxirgi nuqta `2`, barmoq esa `5`ga qarab ketayotgan bo'lsa, `2`dan barmoqgacha chiziq chiziladi.

### Nuqtalarni chizish

```dart
for (int i = 0; i < points.length; i++) {
  final isSelected = selected.contains(i);
  final point = points[i];
  if (isSelected) {
    canvas.drawCircle(point, 30 + 16 * pulse, ringPaint);
    canvas.drawCircle(point, 14, Paint()..color = activeColor);
    canvas.drawCircle(point, 5, Paint()..color = Colors.white);
  } else {
    canvas.drawCircle(point, 16, inactivePaint);
    canvas.drawCircle(point, 6, Paint()..color = const Color(0xFF8FA1B3));
  }
}
```

Tanlangan nuqta:

- tashqarida katta shaffof ring;
- ichida active rangli circle;
- o'rtada oq kichkina circle.

Tanlanmagan nuqta:

- kulrang katta circle;
- o'rtada to'qroq kichik circle.

## Success animatsiya

Success bo'lganda `_successController` yuradi:

```dart
_successController.forward(from: 0);
```

Painter ichida shu qiymat ishlatiladi:

```dart
final progress = Curves.easeOutCubic.transform(successProgress);
```

Keyin check belgisi ikki qismda chiziladi:

```dart
final start = center + const Offset(-42, 18);
final middle = center + const Offset(-12, 48);
final end = center + const Offset(52, -36);
```

Check shakli:

```text
start -> middle -> end
```

Avval `start -> middle`, keyin `middle -> end` chiziladi.

```dart
if (progress < 0.45) {
  final t = progress / 0.45;
  path.lineTo(...);
} else {
  final t = (progress - 0.45) / 0.55;
  path
    ..lineTo(middle.dx, middle.dy)
    ..lineTo(...);
}
```

Bu usul bilan check birdan chiqmaydi, chizilayotgandek ko'rinadi.

## Error shake animatsiya

Error bo'lsa:

```dart
_shakeController.forward(from: 0)
```

Build ichida `AnimatedBuilder` shu controllerni tinglaydi:

```dart
AnimatedBuilder(
  animation: _shakeController,
  builder: (context, child) {
    final shake = math.sin(_shakeController.value * math.pi * 8);
    return Transform.translate(
      offset: Offset(shake * 12 * (1 - _shakeController.value), 0),
      child: child,
    );
  },
  child: GestureDetector(...),
)
```

Bu formula:

```dart
math.sin(_shakeController.value * math.pi * 8)
```

chap-o'ng tebranish yasaydi.

Bu qism:

```dart
12 * (1 - _shakeController.value)
```

shake oxiriga borib asta kamayishini beradi. Boshida kuchliroq, oxirida sekinroq.

## Ranglar qanday almashyapti?

Rang enum extension orqali olinadi:

```dart
extension _PatternResultColor on _PatternResult {
  Color get color {
    switch (this) {
      case _PatternResult.success:
        return Colors.green;
      case _PatternResult.error:
        return Colors.redAccent;
      case _PatternResult.drawing:
        return Colors.deepPurple;
      case _PatternResult.idle:
        return Colors.blueGrey;
    }
  }
}
```

Shuning uchun painter ham, text ham bitta manbadan rang oladi:

```dart
final color = _result.color;
```

Bu yaxshi usul, chunki `success` rangini o'zgartirmoqchi bo'lsang, bitta joydan o'zgartirasan.

## UI text animatsiyasi

Pastdagi status text `AnimatedDefaultTextStyle` bilan animatsiya bo'ladi:

```dart
AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 220),
  style: TextStyle(
    color: color,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
  child: Text(status),
)
```

`_result` o'zgarsa, text rangi ham silliq almashadi.

## Nega CustomPainter ishlatdik?

Buni oddiy `Container`, `Row`, `Column` bilan ham qisman qilish mumkin edi. Lekin pattern lock uchun `CustomPainter` qulayroq, chunki:

- chiziqlar nuqtadan nuqtaga erkin chiziladi;
- barmoqning real koordinatasiga chiziq tortish mumkin;
- check belgisini qo'lda chizish mumkin;
- bitta canvas ichida hammasi silliq ishlaydi.

## O'zgartirib ko'rish uchun mashqlar

### 1. To'g'ri patternni almashtir

Hozir:

```dart
final List<int> _answer = const [0, 1, 2, 5, 8];
```

Masalan buni qilib ko'r:

```dart
final List<int> _answer = const [6, 3, 0, 4, 8];
```

### 2. Nuqtaga yaqinlashish radiusini o'zgartir

Hozir:

```dart
if (distance < 34)
```

`34`ni kattalashtirsang nuqtani tanlash osonlashadi. Kichraytirsang aniqroq chizish kerak bo'ladi.

### 3. Shake kuchini o'zgartir

Hozir:

```dart
offset: Offset(shake * 12 * (1 - _shakeController.value), 0),
```

`12`ni `20` qilsang shake kuchliroq bo'ladi.

### 4. Grid o'lchamini kattalashtir

Hozir:

```dart
size: const Size(300, 300),
```

`340x340` qilib ko'r. Lekin `_addPoint` ichidagi `Size(300, 300)`ni ham moslashtirish kerak.

Yaxshiroq keyingi refactor: grid size uchun bitta constant ochish.

### 5. Successdan keyin avtomatik reset qo'sh

Hozir success holatda pattern ekranda qoladi. Xohlasang 1 soniyadan keyin reset qilish mumkin.

## Eng muhim tushuncha

Bu animatsiyada bitta katta sir bor:

```text
State -> Painter -> Animation
```

Gesture state'ni o'zgartiradi:

```text
user drag qiladi -> _selected yangilanadi
```

Painter shu state'ni chizadi:

```text
_selected -> chiziqlar va nuqtalar
```

AnimationController esa maxsus holatlarni jonlantiradi:

```text
success -> check chiziladi
error -> shake bo'ladi
```

Shuni tushunsang, keyingi murakkab gesture animatsiyalar ham osonlashadi.
