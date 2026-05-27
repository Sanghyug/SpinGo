// lib/components/pole.dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Pole extends SpriteComponent with HasGameReference<FlameGame> {
  final double targetHeight;

  Pole({
    required Vector2 position,
    required this.targetHeight,
  }) : super(
    position: position,
    size: Vector2(25, targetHeight), // 생성 시 두께 설정
    anchor: Anchor.bottomCenter,
    priority: 5,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('components/pole.png');

    // ✅ 가로 두께를 45px로 확실히 넓혔습니다.
    size = Vector2(45, targetHeight);
  }
}