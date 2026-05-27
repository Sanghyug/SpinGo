import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../sound_manager.dart';

class Plate extends SpriteComponent with HasGameReference<FlameGame> {
  double omega;
  double angleRad = 0;
  double tilt = 0;
  double phase = 0;
  double currentAmp = 0,
      targetAmp = 0;

  // 🔥 오류 해결 1: final 변수는 선언 시 혹은 이니셜라이저에서 초기화해야 합니다.
  final double phaseOffset = Random().nextDouble() * 2 * pi;

  double flatTimer = 0.0;
  bool gameOver = false;
  bool flyingAway = false;
  bool falling = false;
  double heat = 0.0;

  // 물성치
  double friction;
  double omegaMax;
  double maxTilt;
  double fallSpeed;

  // 🔥 오류 해결 2 & 3: 기본값을 직접 할당하여 초기화 누락 방지
  double omegaMin = 0.5;
  double flySpeedY = -300;
  double flySpeedX = 150;

  final String imagePath;

  Plate({
    required Vector2 center,
    required this.imagePath,
    double initialOmega = 15,
    this.friction = 1.0,
    this.omegaMax = 30,
    this.maxTilt = 0.8,
    this.fallSpeed = 600,
    Vector2? plateSize,
  })
      : omega = initialOmega,
        super(
        size: plateSize ?? Vector2(160, 160),
        anchor: Anchor.center,
        position: center,
        priority: 10,
      );


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(imagePath);
  }

  @override
  void onMount() {
    super.onMount();
    phase = phaseOffset;
  }

  void boost(double input) {
    if (gameOver || flyingAway || falling) return;
    // 부스트 시에도 omegaMax를 넘으면 즉시 비행 준비
    omega += input * 0.02;
    // 너무 무한정 올라가는 것만 방지 (예: 최대 50)
    if (omega > 50) omega = 50;
  }


  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    // --- 비행 상태 연출 ---
    if (flyingAway) {
      position.y += flySpeedY * dt;
      position.x += flySpeedX * dt;
      angle += dt * 10;
      if (position.y + size.y < 0) gameOver = true;
      return;
    }

    // 1. 회전력 감쇠
    omega -= friction * dt;

    // 2. 🔥 [추락 판정] 3.0 이하 시 즉시 추락 상태로 전환
    if (!falling && !flyingAway && omega <= 3.0) {
      falling = true;
      SoundManager.playSfxSafe("crash.wav"); // 추락 사운드
    }

    // --- 추락 상태 연출 ---
    if (falling) {
      position.y += (fallSpeed + 900) * dt;
      angle = ui.lerpDouble(angle, (tilt >= 0 ? 1.57 : -1.57), dt * 25)!;
      if (position.y > game.size.y + 100) gameOver = true;
      return;
    }

    // 3. ✅ [가장 중요] 수평 회전각 계산 (이 코드가 빠져서 안 돌았던 것입니다!)
    // 회전 속도(omega)에 시간을 곱해 각도를 누적합니다.
    angleRad = (angleRad + omega * dt) % (pi * 2);

    // 4. 흔들림 진폭 계산 (3~12 구간)
    targetAmp = (1 - (omega - 3.0) / (12.0 - 3.0)).clamp(0, 1) * maxTilt;
    currentAmp = ui.lerpDouble(currentAmp, targetAmp, dt * 2.0)!;

    // 흔들림 주기 적용 (sin 그래프를 그려 실제 기울기 생성)
    final freq = 0.5 + (omega * 0.3);
    phase += freq * dt;
    tilt = sin(phase) * currentAmp;

    // 시각적 기울기 반영
    angle = tilt;

    // 5. 🔥 [수정] 비행 조건 완화
    // omega가 omegaMax 근처(예: 0.5 차이)만 가도 타이머가 돌게 합니다.
    if (omega >= (omegaMax - 0.5)) {
      // 수평 조건(tilt)을 조금 더 너그럽게(0.05 -> 0.1) 조정합니다.
      if (tilt.abs() < 0.1) {
        flatTimer += dt;
        // 1초 유지 시 비행
        if (flatTimer >= 1.0) {
          flyingAway = true;
          SoundManager.playSfxSafe("fly.wav"); // 비행 사운드 추가 추천
        }
      } else {
        flatTimer = 0; // 기울어지면 타이머 리셋
      }
    } else {
      flatTimer = 0;
    }

    // 6. 과열 시각화 (25 이상부터)
    final targetHeat = ((omega - 25.0) / (omegaMax - 25.0)).clamp(0.0, 1.0);
    heat = ui.lerpDouble(heat, targetHeat, dt * 3.0)!;
  }

  @override
  void render(ui. Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // 휘청거리는 기울기 적용
    canvas.rotate(tilt);

    // ✅ 일반 접시의 기본 납작도 (0.35)
    // BowlPlate는 bowl.dart에서 0.6으로 직접 덮어쓰도록 유도합니다.
    canvas.scale(1.0, 0.35);

    // 수평 회전
    canvas.rotate(angleRad);

    sprite?.render(canvas, size: size, anchor: Anchor.center);

    // 과열 효과
    if (heat > 0.05) {
      final overlay = Paint()
        ..color = Colors.red.withValues(alpha: heat * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * heat);
      canvas.drawCircle(Offset.zero, size.x / 2, overlay);
    }
    canvas.restore();
  }
}