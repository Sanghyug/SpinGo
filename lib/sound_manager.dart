// lib/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart';

/// 게임 전역 사운드 매니저 (audioplayers ^6.x)
class SoundManager {
  static final AudioPlayer _bgm = AudioPlayer();
  static String? _currentBgm; // 현재 세팅된 BGM 파일명
  static bool _muted = false;

  static bool get isMuted => _muted;

  static Future<void> _initOnce() async {
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(_muted ? 0.0 : 1.0);
  }

  /// 내부 공통: 주어진 파일을 루프로 "확실히" 재생
  static Future<void> _startLoop(String file) async {
    await _initOnce();
    await _bgm.stop();
    if (_currentBgm != file) {
      // 루프 BGM은 존재한다고 가정(필요시 안전 체크 추가 가능)
      await _bgm.setSource(AssetSource('audio/$file'));
      _currentBgm = file;
    }
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(_muted ? 0.0 : 1.0);
    await _bgm.resume();
  }

  static Future<void> requestWelcomeLoop() => _startLoop('welcome.mp3');

  static Future<void> requestMainLoop() => _startLoop('main.mp3');

  static Future<void> stopBgm() async {
    await _bgm.stop();
  }

  static Future<void> toggleMute() async {
    _muted = !_muted;
    await _bgm.setVolume(_muted ? 0.0 : 1.0);
  }

  // ───────────────────────────────────────────────────────────
  //             🔒 안전한 효과음 재생 유틸
  // ───────────────────────────────────────────────────────────

  /// 에셋 존재 여부 확인 (assets/ 접두어 자동 부착)
  static Future<bool> _assetExists(String relPathFromAssets) async {
    try {
      await rootBundle.load('assets/$relPathFromAssets');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 효과음 1회 재생(안전): 파일이 없으면 조용히 무시(크래시 방지)
  static Future<void> playSfxSafe(String file, {double volume = 1.0}) async {
    final rel = 'audio/$file';
    final exists = await _assetExists(rel);
    if (!exists) {
      debugPrint('[SoundManager] SFX not found: assets/$rel (silenced)');
      return;
    }
    final p = AudioPlayer();
    await p.setReleaseMode(ReleaseMode.stop);
    await p.setVolume(_muted ? 0.0 : volume.clamp(0.0, 1.0));
    await p.play(AssetSource(rel));
  }

  /// 효과음 1회 재생(폴백): primary 없으면 fallback 시도, 그것도 없으면 무음
  static Future<void> playSfxWithFallback(String primary, {
    String? fallback,
    double volume = 1.0,
  }) async {
    final relPrimary = 'audio/$primary';
    if (await _assetExists(relPrimary)) {
      return playSfxSafe(primary, volume: volume);
    }
    if (fallback != null) {
      final relFallback = 'audio/$fallback';
      if (await _assetExists(relFallback)) {
        return playSfxSafe(fallback, volume: volume);
      }
    }
    debugPrint('[SoundManager] SFX not found: $primary'
        '${fallback != null ? ' (and fallback: $fallback)' : ''}. Silenced.');
  }

  /// (기존 간단 버전) 효과음 1회 재생 — 파일 없으면 예외 날 수 있음
  /// 가능하면 playSfxSafe / playSfxWithFallback 사용 권장
  static Future<void> playSfx(String file, {double volume = 1.0}) async {
    final p = AudioPlayer();
    await p.setReleaseMode(ReleaseMode.stop);
    await p.setVolume(_muted ? 0.0 : volume.clamp(0.0, 1.0));
    await p.play(AssetSource('audio/$file'));
  }
}

class SoundLifecycleObserver with WidgetsBindingObserver {
  SoundLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      SoundManager.stopBgm(); // 앱 백그라운드 시 즉시 정지
    } else if (state == AppLifecycleState.resumed) {
      // 복귀 시 재개하지 않음 (심사 요구사항)
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
