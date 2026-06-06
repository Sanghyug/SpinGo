import 'dart:async';
import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'language_manager.dart';
import 'l10n.dart';
import '../widgets/age_rating_banner.dart';

class IntroPage extends StatefulWidget {
  // ⭐ 모드 번호를 전달할 수 있도록 콜백 함수 수정 (0: 일반, 1: 신나는, 2: 어르신)
  final Function(int) onStartGame;

  const IntroPage({super.key, required this.onStartGame});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _index = 0;
  String _typedText = "";
  Timer? _typingTimer;
  bool _showModeSelection = false; // ⭐ 모드 선택창 표시 여부

  List<Map<String, String>> get _slides =>
      [
        {"image": "assets/images/intro1.png", "text": L10n.tr('intro1')},
        {"image": "assets/images/intro2.png", "text": L10n.tr('intro2')},
        {"image": "assets/images/intro3.png", "text": L10n.tr('intro3')},
        {"image": "assets/images/intro4.png", "text": L10n.tr('intro4')},
        {"image": "assets/images/intro5.png", "text": L10n.tr('intro5')},
      ];

  @override
  void initState() {
    super.initState();
    SoundManager.requestWelcomeLoop();
    _startTyping();
  }

  void _startTyping() {
    _typingTimer?.cancel();
    setState(() => _typedText = "");
    final fullText = _slides[_index]["text"]!;
    int charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (charIndex < fullText.length) {
        setState(() {
          _typedText += fullText[charIndex];
        });
        charIndex++;
      } else {
        t.cancel();
      }
    });
  }

  void _nextSlide() {
    if (_index < _slides.length - 1) {
      setState(() {
        _index++;
      });
      _startTyping();
    } else {
      // ⭐ 마지막 슬라이드 이후 선택창을 보여줍니다.
      setState(() => _showModeSelection = true);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                final next = LanguageManager.current.value == AppLang.ko
                    ? AppLang.en
                    : AppLang.ko;

                await LanguageManager.set(next);

                if (!mounted) return;
                setState(() {
                  _typedText = "";
                });
                _startTyping();
              },
              child: Text(
                LanguageManager.current.value == AppLang.ko ? 'EN' : 'KR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // 배경 이미지
          Positioned.fill(
              child: Image.asset(slide["image"]!, fit: BoxFit.cover)),

          // 텍스트 영역 (모드 선택창이 아닐 때만 표시)
          if (!_showModeSelection)
            Positioned(
              left: MediaQuery
                  .of(context)
                  .size
                  .width * 0.25,
              bottom: 120,
              right: 30,
              child: Text(_typedText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ),

          // 다음 화살표 (모드 선택창이 아닐 때만 표시)
          if (!_showModeSelection)
            Positioned(
              right: 70,
              top: MediaQuery
                  .of(context)
                  .size
                  .height / 2 - 40,
              child: GestureDetector(
                onTap: _nextSlide,
                child: const Text('>',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 5.0,
                              color: Colors.black54),
                        ])),
              ),
            ),

          // ⭐ 모드 선택 오버레이
          if (_showModeSelection)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      context,
                      title: 'Beginner',
                      desc: '0단계부터 하나씩',
                      mode: 0,
                    ),
                    const SizedBox(height: 24),
                    _buildModeButton(
                      context,
                      title: 'Expert',
                      desc: '기록을 위한 도전',
                      mode: 1,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 24),
                    _buildModeButton(
                      context,
                      title: 'Brain Booster',
                      desc: '뇌 자극 모드',
                      mode: 2,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),

          // 하단 건너뛰기 버튼 (슬라이드 중에만 표시)
          if (!_showModeSelection)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: () => setState(() => _showModeSelection = true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14)),
                  child: Text(L10n.tr('skip'),
                      style:
                      const TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 모드 선택 버튼 위젯
  Widget _buildModeButton(BuildContext context,
      {required String title,
        required String desc,
        required int mode,
        Color color = Colors.amberAccent}) {
    return InkWell(
      onTap: () => widget.onStartGame(mode),
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Colors.black87,
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 26, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc,
                style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}