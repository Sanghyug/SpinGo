// lib/plate_game.dart
import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'components/pole.dart';
import 'components/plate.dart';
import 'components/bowl.dart';
import 'components/big_plate.dart';
import 'levels.dart';
import 'sound_manager.dart';
import 'score_manager.dart';
import 'language_manager.dart';
import 'l10n.dart';
import 'package:flame/text.dart';
import 'dart:ui' as ui;

late final TextPaint koreanText;

Future<void> initFonts() async {
  try {
    final fontData = await rootBundle.load(
        'assets/fonts/NotoSansKR-Regular.ttf');
    final loader = FontLoader('NotoSansKR')
      ..addFont(Future.value(fontData));
    await loader.load();
    koreanText = TextPaint(
      style: const TextStyle(
          fontFamily: 'NotoSansKR', color: ui.Color(0xFFFFFFFF), fontSize: 28),
    );
  } catch (e) {
    debugPrint('[SpinGo] ⚠️ Font load failed: $e');
  }
}

typedef TrayPlate = BigPlate;

class MathOverlay extends StatelessWidget {
  static const id = 'MathOverlay';
  final PlateSpinGame game;

  const MathOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: game.problemNotifier,
      builder: (context, problem, _) {
        if (problem.isEmpty) return const SizedBox.shrink();
        return Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    // ✅ Deprecated 해결
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amberAccent, width: 2),
                  ),
                  child: Text(problem, style: const TextStyle(fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                ),
                const SizedBox(height: 5),
                ValueListenableBuilder<double>(
                  valueListenable: game.timerNotifier,
                  builder: (context, timerVal, _) {
                    return SizedBox(width: 200,
                        child: LinearProgressIndicator(
                            value: timerVal, minHeight: 5));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 리더보드
// ──────────────────────────────────────────────────────────────
class LeaderboardOverlay extends StatelessWidget {
  static const id = 'LeaderboardOverlay';
  final PlateSpinGame game;

  const LeaderboardOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScoreEntry>>(
      future: ScoreManager.load(),
      builder: (context, snap) {
        final entries = (snap.data ?? const <ScoreEntry>[]);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(L10n.tr('leaderboard_title'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    if (!snap.hasData)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      )
                    else
                      ...List.generate(entries.length, (i) {
                        final e = entries[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 32, child: Text('${i + 1}.')),
                              Expanded(
                                  child: Text(e.name,
                                      overflow: TextOverflow.ellipsis)),
                              Text('${e.score}'),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          game.overlays.remove(LeaderboardOverlay.id);
                          game.overlays.add(GameOverOverlay.id);
                          game.pauseEngine();
                        },
                        child: Text(L10n.tr('confirm')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 이름 입력
// ──────────────────────────────────────────────────────────────
class NameEntryOverlay extends StatefulWidget {
  static const id = 'NameEntryOverlay';
  final PlateSpinGame game;

  const NameEntryOverlay({super.key, required this.game});

  @override
  State<NameEntryOverlay> createState() => _NameEntryOverlayState();
}

class _NameEntryOverlayState extends State<NameEntryOverlay> {
  final _controller = TextEditingController(text: 'me');
  String? _error;

  bool _valid(String s) {
    final runes = s.runes.toList();
    final isKorean = runes.any((cp) => (cp >= 0xAC00 && cp <= 0xD7A3));
    if (isKorean) return runes.length <= 5;
    final ascii = RegExp(r'^[A-Za-z0-9 ]{1,12}$');
    return ascii.hasMatch(s);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(L10n.tr('congrats'),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(L10n.tr('enter_name_hint'))),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = _controller.text.trim();
                      if (name.isEmpty || !_valid(name)) {
                        setState(() =>
                        _error = L10n.tr('ai_tip_invalid_name'));
                        return;
                      }
                      await ScoreManager.addIfTop7(
                          ScoreEntry(name, game.currentScore));
                      game.overlays.remove(NameEntryOverlay.id);
                      game.overlays.add(LeaderboardOverlay.id);
                    },
                    child: Text(L10n.tr('register')),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!,
                      style: const TextStyle(color: Colors.redAccent)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// HUD (음소거, 언어)
// ──────────────────────────────────────────────────────────────
class HudOverlay extends StatefulWidget {
  static const id = 'HudOverlay';
  final PlateSpinGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  bool _muted = SoundManager.isMuted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 50, right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black54,
                    minimumSize: const Size(48, 40)),
                onPressed: () async {
                  await SoundManager.toggleMute();
                  setState(() => _muted = SoundManager.isMuted);
                },
                child: Text(
                    _muted ? '🔇' : '🔊', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black54,
                    minimumSize: const Size(48, 36)),
                onPressed: () async {
                  final selected = await showDialog<AppLang>(
                    context: context,
                    builder: (ctx) =>
                        AlertDialog(
                          backgroundColor: Colors.black87,
                          title: Text(L10n.tr('lang')),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<AppLang>(
                                value: AppLang.ko,
                                groupValue: LanguageManager.current.value,
                                onChanged: (v) => Navigator.pop(ctx, v),
                                title: const Text('한국어'),
                              ),
                              RadioListTile<AppLang>(
                                value: AppLang.en,
                                groupValue: LanguageManager.current.value,
                                onChanged: (v) => Navigator.pop(ctx, v),
                                title: const Text('English'),
                              ),
                            ],
                          ),
                        ),
                  );
                  if (selected != null) {
                    await LanguageManager.set(selected);
                    if (mounted) setState(() {});
                  }
                },
                child: Text(L10n.tr('lang')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// GameOverOverlay
// ──────────────────────────────────────────────────────────────
class GameOverOverlay extends StatelessWidget {
  static const id = 'GameOverOverlay';
  final PlateSpinGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: IgnorePointer(
                child: Container(color: Colors.black.withValues(alpha:0.35)))),
        Positioned.fill(
          child: Center(
            child: Image.asset('assets/images/game_over.png',
                fit: BoxFit.fitHeight, alignment: Alignment.center),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 180,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      game.overlays.remove(GameOverOverlay.id);
                      game.onExit?.call();
                    },
                    child: Text(L10n.tr('retry')),
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      game.overlays.remove(GameOverOverlay.id);
                      SystemNavigator.pop();
                    },
                    child: Text(L10n.tr('exit')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ⚙️ PlateSpinGame 본체 (최종 완성본)
// ──────────────────────────────────────────────────────────────
class PlateSpinGame extends FlameGame with PanDetector {
  final int startMode;
  final VoidCallback? onExit;
  final problemNotifier = ValueNotifier<String>("");
  final timerNotifier = ValueNotifier<double>(0);
  final SpeechToText _speech = SpeechToText();

  PlateSpinGame({this.onExit, this.startMode = 0});

  List<Level> get _currentLevelList {
    if (startMode == 1) return expertLevels;
    if (startMode == 2) return brainBoosterLevels;
    return beginnerLevels;
  }

  async.Timer? _levelTimer;
  int _levelIndex = 0;
  int remainingSeconds = 0;
  SpriteComponent? _bg;
  final List<Component> _decor = [];
  final List<Plate> _plates = [];
  final List<Pole> _poles = [];
  int _attemptsLeft = 3;
  SpriteComponent? _lifeIcon;
  TextComponent? _lifeText;
  bool _isGameOver = false;
  bool _isRespawning = false;
  bool _inCutscene = false;
  double _cutsceneLeft = 0.0;
  double _respawnCooldown = 0.0;
  TextComponent? _levelMsg;
  int _score = 0;

  int get currentScore => _score;
  double _levelTime = 0.0;
  double _tickAccum = 0.0;
  TextComponent? _scoreText;
  double _swipeAccum = 0.0;
  final double _swipeUnit = 120.0;
  bool _lastFailWasFly = false;
  TextComponent? _tipText;

  bool _isSilverMode = false;
  int? _currentAnswer;
  double _missionTimer = 0;
  final double _baseLimit = 7.0;
  int _consecutiveCorrect = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAll([
      'backimage1.png',
      'backimage2.png',
      'backimage3.png',
      'backimage4.png',
      'game_over.png',
      'guide.png',
      'plate.png',
      'components/plate_blue.png',
      'components/plate_red.png',
      'components/plate_yellow.png',
      'components/plate_green.png',
      'components/plate_orange.png',
      'components/bowl.png',
      'components/bigPlate1.png',
      'components/bigPlate2.png',
      'components/pole.png',
    ]);
    await SoundManager.requestMainLoop();
    await initFonts();

    if (startMode == 1 || startMode == 2) {
      _levelIndex = 0;
      if (startMode == 2) {
        _isSilverMode = true;
        overlays.add(MathOverlay.id);
        async.Timer(const Duration(seconds: 2), _generateMathProblem);
      }
    }
    _applyLevel(_currentLevelList[_levelIndex]);
    _initLivesUI();
    _initScoreUI();
    overlays.add(HudOverlay.id);
  }

  void _startListening() async {
    try {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            String voice = result.recognizedWords;
            if (_currentAnswer != null &&
                voice.contains(_currentAnswer.toString())) {
              _onMathSuccess();
            }
          },
          // ✅ 'options' 매개변수 대신 직접 listenMode를 지원하는 버전이거나,
          // 지원하지 않는 구버전일 수 있으므로 가장 안전한 기본 호출 방식으로 변경합니다.
          listenFor: const Duration(seconds: 5),
          localeId: "ko_KR",
        );
      }
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
    }
  }

  void _generateMathProblem() {
    if (!_isSilverMode || _isGameOver) return;
    final random = Random();
    int a = random.nextInt(8) + 2;
    int b = random.nextInt(9) + 1;
    _currentAnswer = a * b;
    problemNotifier.value = "$a × $b = ?";
    _missionTimer = _baseLimit - (_consecutiveCorrect * 0.2).clamp(0, 4.0);
    _startListening();
  }

  void _onMathSuccess() {
    _score += 200;
    _scoreText?.text = "Score: $_score";
    problemNotifier.value = "O";
    _currentAnswer = null;
    async.Timer(const Duration(seconds: 1), _generateMathProblem);
  }

  void _onMathFail() {
    problemNotifier.value = "X";
    _currentAnswer = null;
    async.Timer(const Duration(seconds: 1), _generateMathProblem);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) return;
    if (_isSilverMode && _currentAnswer != null) {
      _missionTimer -= dt;
      timerNotifier.value = (_missionTimer / _baseLimit).clamp(0, 1);
      if (_missionTimer <= 0) _onMathFail();
    }
    if (_inCutscene) {
      _cutsceneLeft -= dt;
      if (_cutsceneLeft <= 0) {
        _inCutscene = false;
        _levelMsg?.removeFromParent();
        _levelMsg = null;
        _setupPlates(_currentLevelList[_levelIndex]);
        _respawnCooldown = 0.2;
      }
      return;
    }
    if (_respawnCooldown > 0) {
      _respawnCooldown -= dt;
      return;
    }
    if (_plates.isEmpty) {
      _failAndRespawnOrGameOver();
      return;
    }
    _levelTime += dt;
    _tickAccum += dt;
    while (_tickAccum >= 0.1) {
      _addScore(1);
      _tickAccum -= 0.1;
    }
    for (final p in _plates) {
      if (p.gameOver) {
        _lastFailWasFly = p.flyingAway;
        _failAndRespawnOrGameOver();
        return;
      }
      _updateBackgroundHeat();
    }
  }

  void _nextLevel() {
    _cancelTimer();
    _addScore(_levelTime <= 60 ? 500 : (_levelTime <= 120 ? 300 : 100));
    _levelTime = 0.0;
    _levelIndex++;
    if (_levelIndex >= _currentLevelList.length) {
      gameOver();
    } else {
      _applyLevel(_currentLevelList[_levelIndex]);
    }
  }

  void _failAndRespawnOrGameOver() {
    if (_isGameOver || _isRespawning) return;
    _isRespawning = true;
    _attemptsLeft--;
    _updateLifeUI();
    SoundManager.playSfxSafe("crowd.wav");
    if (_attemptsLeft > 0) {
      _showTipFor(const Duration(seconds: 3));
      _respawnCooldown = 3.0;
      async.Timer(const Duration(seconds: 3), () {
        _tipText?.removeFromParent();
        _tipText = null;
        _applyLevel(_currentLevelList[_levelIndex]);
        _respawnCooldown = 0.35;
        _isRespawning = false;
        SoundManager.requestMainLoop();
      });
    } else {
      gameOver();
    }
  }

  void gameOver() {
    if (_isGameOver) return;
    _isGameOver = true;
    _cancelTimer();
    SoundManager.stopBgm();
    pauseEngine();
    ScoreManager.qualifies(_score).then((ok) =>
        overlays.add(ok ? NameEntryOverlay.id : LeaderboardOverlay.id));
  }

  void _addScore(int amount) {
    _score += amount;
    _scoreText?.text = "Score: $_score";
  }

  void _updateLifeUI() {
    _lifeText?.text = "×${(_attemptsLeft - 1).clamp(0, 99)}";
  }

  void _cancelTimer() {
    _levelTimer?.cancel();
    _levelTimer = null;
  }

  void _clearDecor() {
    for (final c in _decor)
      c.removeFromParent();
    _decor.clear();
  }

  void _clearPlates() {
    for (final p in _plates)
      p.removeFromParent();
    _plates.clear();
  }

  void _applyLevel(Level level) {
    _cancelTimer();
    _clearDecor();
    _clearPlates();
    _poles.clear();
    _bg?.removeFromParent();
    _bg = SpriteComponent(sprite: Sprite(images.fromCache(level.background)),
        size: size,
        priority: -1);
    add(_bg!);

    if (startMode == 0) {
      _inCutscene = true;
      _cutsceneLeft = 2.0;
      _levelMsg?.removeFromParent();
      _levelMsg = TextComponent(text: L10n.tr(level.messageKey),
          anchor: Anchor.center,
          position: Vector2(size.x / 2, size.y / 4),
          textRenderer: koreanText);
      add(_levelMsg!);
    } else {
      _inCutscene = false;
      _setupPlates(level);
    }

    remainingSeconds = level.duration.inSeconds;
    if (remainingSeconds < 1000000) {
      _levelTimer = async.Timer.periodic(const Duration(seconds: 1), (t) {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          t.cancel();
          _levelTimer = null;
          _nextLevel();
        }
      });
    }
  }

  void _setupPlates(Level level) {
    _clearDecor();
    _clearPlates();
    _poles.clear();

    final count = level.sets.length;

    // ✅ [수정] 막대기 위치 후보들을 미리 만듭니다.
    final List<double> xPositions = [];
    final spacing = size.x / (count + 1);
    for (int i = 0; i < count; i++) {
      xPositions.add(spacing * (i + 1));
    }

    // ✅ [핵심 1] 막대기 위치를 랜덤으로 섞습니다.
    xPositions.shuffle();

    final plateImages = [
      'components/plate_blue.png',
      'components/plate_yellow.png',
      'components/plate_red.png',
      'components/plate_green.png',
      'components/plate_orange.png'
    ];

    for (int i = 0; i < count; i++) {
      final x = xPositions[i]; // 섞인 위치 사용
      final pivotY = size.y / 2.2;

      final pole = Pole(
          position: Vector2(x, size.y), targetHeight: (size.y - pivotY).abs())
        ..priority = 0;
      add(pole);
      _decor.add(pole);
      _poles.add(pole);

      final type = level.sets[i].type;
      Plate plate;

      if (type == PlateType.tray) {
        // ✅ [핵심 2] 큰 접시 이미지도 1, 2 중 랜덤 선택
        final trayImg = (Random().nextBool())
            ? 'bigPlate1.png'
            : 'bigPlate2.png';
        plate = BigPlate(
            center: Vector2(x, pivotY), imagePath: 'components/$trayImg');
      } else if (type == PlateType.bowl) {
        plate = BowlPlate(center: Vector2(x, pivotY))
          ..omega = 30;
      } else {
        // ✅ [핵심 3] 일반 접시 색상(이미지)을 랜덤하게 선택
        final randomImg = plateImages[Random().nextInt(plateImages.length)];
        plate = Plate(center: Vector2(x, pivotY), imagePath: randomImg);
      }

      plate.priority = 1;
      add(plate);
      _plates.add(plate);
    }
    _respawnCooldown = 0.35;
    _isRespawning = false;
  }

  void _initLivesUI() {
    _lifeIcon?.removeFromParent();
    _lifeText?.removeFromParent();
    _lifeIcon = SpriteComponent(sprite: Sprite(images.fromCache('plate.png')),
        size: Vector2(40, 40),
        position: Vector2(20, size.y - 60),
        anchor: Anchor.topLeft,
        priority: 3000);
    add(_lifeIcon!);
    _lifeText = TextComponent(text: "×${(_attemptsLeft - 1).clamp(0, 99)}",
        anchor: Anchor.topLeft,
        position: Vector2(70, size.y - 55),
        textRenderer: koreanText,
        priority: 3001);
    add(_lifeText!);
  }

  void _initScoreUI() {
    _scoreText?.removeFromParent();
    _scoreText = TextComponent(text: "Score: 0",
        anchor: Anchor.topRight,
        position: Vector2(size.x - 100, 20),
        textRenderer: koreanText,
        priority: 3002);
    add(_scoreText!);
  }

  void _showTipFor(Duration dur) {
    final tipList = _lastFailWasFly ? [
      L10n.tr('tip_fly_1'),
      L10n.tr('tip_fly_2')
    ] : [L10n.tr('tip_fall_1'), L10n.tr('tip_fall_2')];
    final tip = (tipList..shuffle()).first;
    _tipText?.removeFromParent();
    _tipText = TextComponent(text: tip,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y * 0.25),
        textRenderer: koreanText,
        priority: 4000);
    add(_tipText!);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_isGameOver || _inCutscene || _isRespawning) return;
    final pos = info.eventPosition.global;
    Plate? nearestPlate;
    Pole? nearestPole;
    double minDist = double.infinity;

    for (int i = 0; i < _plates.length; i++) {
      final p = _plates[i];
      final d = p.position.distanceTo(pos);
      if (d < minDist) {
        minDist = d;
        nearestPlate = p;
        nearestPole = _poles[i];
      }
    }

    if (nearestPlate != null && nearestPole != null) {
      final input = info.delta.global.length.clamp(0, 60).toDouble();
      if (input <= 0) return;
      nearestPlate.boost(input);
      if (nearestPole.children
          .whereType<RotateEffect>()
          .isEmpty) {
        nearestPole.add(
            RotateEffect.by(0.005, SineEffectController(period: 0.1)));
      }
      nearestPole.add(
          RotateEffect.by(0.01, SineEffectController(period: 0.08)));
      _swipeAccum += input;
      if (_swipeAccum >= _swipeUnit) {
        _addScore(10 * (_swipeAccum ~/ _swipeUnit));
        _swipeAccum %= _swipeUnit;
      }
    }
  }

  void _updateBackgroundHeat() {
    // 기존 heat 로직 필요 시 추가
  }
}
