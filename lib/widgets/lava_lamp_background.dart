// FILE: lib/widgets/lava_lamp_background.dart
import 'dart:math';
import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';

// Винесемо кольори, щоб легко їх змінювати або імпортувати з теми
// Ці кольори можна взяти з вашої теми або визначити тут
const Color lavaPrimaryColor = Color(0xFFED5D1A); // Основний помаранчевий
const Color lavaSecondaryColor = Color(0xFFFF8A65); // Світліший помаранчевий
const Color lavaAccentColor1 = Color(0xFFFFE0B2); // Дуже світлий, майже жовтий
const Color lavaAccentColor2 = Color(0xFFFFCC80); // Теплий жовто-помаранчевий

class LavaLampBackground extends StatefulWidget {
  const LavaLampBackground({super.key});

  @override
  State<LavaLampBackground> createState() => _LavaLampBackgroundState();
}

class _LavaLampBackgroundState extends State<LavaLampBackground>
    with TickerProviderStateMixin {
  late List<_Blob> _blobs;
  final int _blobCount = 4; // Кількість "крапель", 3-5 зазвичай добре виглядає
  final Random _random = Random();

  // Набір кольорів для блобів
  final List<List<Color>> _blobColorsSets = [
    [lavaPrimaryColor.withOpacity(0.7), lavaSecondaryColor.withOpacity(0.5)],
    [lavaSecondaryColor.withOpacity(0.6), lavaAccentColor1.withOpacity(0.4)],
    [lavaPrimaryColor.withOpacity(0.5), lavaAccentColor2.withOpacity(0.6)],
    [lavaAccentColor2.withOpacity(0.7), lavaAccentColor1.withOpacity(0.3)],
    [lavaSecondaryColor.withOpacity(0.8), lavaPrimaryColor.withOpacity(0.4)],
  ];

  @override
  void initState() {
    super.initState();
    _blobs = List.generate(_blobCount, (index) {
      final size = _random.nextDouble() * 180 + 120; // Розмір від 120 до 300
      final controller = AnimationController(
        // Тривалість анімації однієї "пульсації" або циклу руху
        duration: Duration(seconds: _random.nextInt(8) + 12), // 12-20 секунд
        vsync: this,
      )..repeat(reverse: true);

      final colors = _blobColorsSets[index % _blobColorsSets.length];

      return _Blob(
        controller: controller,
        initialSize: size,
        colors: colors,
        random: _random,
        screenSizeProvider: () => MediaQuery.of(context).size, // Передаємо context безпечно
      );
    });
  }

  @override
  void dispose() {
    for (var blob in _blobs) {
      blob.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Якщо _blobs ще не ініціалізовані з screenSize (наприклад, якщо context не був доступний в initState)
    // Це потрібно, якщо screenSize використовується для визначення початкових позицій в _Blob
    if (_blobs.any((b) => !b.isInitialized)) {
       final screenSize = MediaQuery.of(context).size;
      for (var blob in _blobs) {
        blob.initializePositions(screenSize);
      }
    }


    return Stack(
      fit: StackFit.expand,
      children: [
        // Базовий фоновий градієнт (може бути ледь помітним)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                lavaAccentColor1.withOpacity(0.1),
                lavaPrimaryColor.withOpacity(0.05),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Контейнер для блобів
        Stack(
          children: _blobs.map((blob) {
            return AnimatedBuilder(
              animation: blob.controller,
              builder: (context, child) {
                final screenSize = MediaQuery.of(context).size; // Отримуємо актуальний розмір
                if (!blob.isInitialized) blob.initializePositions(screenSize);

                // Плавна зміна позиції за допомогою Tween
                final AlignmentGeometry currentAlignment = blob.alignmentTween.evaluate(blob.controller);
                
                // Плавна зміна розміру
                final double sizeMultiplier = 0.8 + 0.4 * sin(blob.controller.value * 2 * pi * blob.sizeChangeFrequency);
                final double currentSize = blob.initialSize * sizeMultiplier;

                return Align(
                  alignment: currentAlignment,
                  child: Container(
                    width: currentSize,
                    height: currentSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: blob.colors,
                        center: Alignment.center,
                        radius: 0.75, // Робить градієнт більш концентрованим до центру
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        // BackdropFilter для ефекту "злиття"
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0), // Експериментуйте з значеннями
            child: Container(
              // Дуже важливо! Фільтр має накладатися на щось.
              // Прозорий контейнер дозволяє фільтру обробляти те, що під ним.
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob {
  final AnimationController controller;
  final double initialSize;
  final List<Color> colors;
  final Random random;
  final Size Function() screenSizeProvider; // Функція для отримання screenSize

  late AlignmentTween alignmentTween;
  late double sizeChangeFrequency;
  bool isInitialized = false;

  _Blob({
    required this.controller,
    required this.initialSize,
    required this.colors,
    required this.random,
    required this.screenSizeProvider,
  }) {
    sizeChangeFrequency = random.nextDouble() * 1.5 + 0.5; // Частота зміни розміру (0.5-2.0)
    // Початкова ініціалізація позицій буде в initializePositions
  }

  void initializePositions(Size screenSize) {
    if (isInitialized) return;

    // Генеруємо випадкові початкову та кінцеву точки для руху блоба
    // в межах екрану. Ми використовуємо Alignment, де (-1, -1) - верхній лівий кут, (1, 1) - нижній правий.
    Alignment begin = _getRandomAlignment();
    Alignment end = _getRandomAlignment();
    
    // Щоб уникнути занадто коротких рухів, можна перевірити відстань або просто генерувати нову кінцеву точку,
    // якщо вона занадто близька до початкової. Для простоти, поки що залишимо так.

    alignmentTween = AlignmentTween(begin: begin, end: end);
    isInitialized = true;
  }

  Alignment _getRandomAlignment() {
    // Генерує Alignment трохи за межами видимого екрану, щоб блоби "впливали" і "випливали"
    // наприклад, від -1.5 до 1.5 по кожній осі
    return Alignment(
      random.nextDouble() * 3.0 - 1.5, // X: від -1.5 до 1.5
      random.nextDouble() * 3.0 - 1.5, // Y: від -1.5 до 1.5
    );
  }
}