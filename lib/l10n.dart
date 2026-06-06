import 'language_manager.dart';

class L10n {
  static final _ko = <String, String>{
    'game_title': 'SpinGo',
    'start': '시작하기',
    'confirm': '확인',
    'register': '등록',
    'retry': '다시 도전',
    'exit': '나가기',
    'leaderboard_title': '기록판 (Top 7)',
    'enter_name_hint': '이름을 입력하세요 (한글 ≤5자, 영문/숫자 ≤12자)',
    'congrats': '축하해! 기록을 세웠어 🎉',
    'ai_tip_invalid_name': '형식이 맞지 않아요.',
    'lang': 'Language',

    // 인트로 슬라이드
    'intro1': '재미없는 일상에 지친 노총각 박봉식(41세) 과장은',
    'intro2': '첫사랑을 닮은 그녀를 보며 문득 깨달았다.',
    'intro3': '아직 해보지 못한 일이 많다는 것을...',
    'intro4': '\'서커스를 배우고 싶습니다.\'        \'쉽지 않을 텐데...\'',
    'intro5': '\'뭐야, 저 녀석은?\'',

    // 레벨 메시지
    'lv1_msg': '나무를 비비면 접시가 돌아간다네.',
    'lv1v_msg': '쟁반은 크지만 가벼워.',
    'lv2_msg': '아슬아슬 할수록 관객들이 좋아 하지.',
    'lv2t_msg': '여유를 가지면 시야가 넓어 진다네.',
    'lv2v_msg': '사발은 작고 무거워!',
    'lv2b_msg': '잘 돌지만 속도가 줄면 급격히 흔들리지.',
    'lv3_msg': '조금만 능숙해지면 무대에 설 수도 있겠어.',
    'lv3v_msg': '재능이 있구만. 거의 다 왔으니 힘 내라구.',
    'lv4_msg': '이젠 실전이야. 무대에선 별일이 다 일어나지.',
    'lv4v_msg': '좋았어. 이제부터는 기록 싸움이야.',

    'q_lv1': '기록에 도전해 보자!',
    'q_lv2': '큰 접시는 마찰력이 크다는 걸 기억해.',
    'q_lv3': '이제 두 개의 큰 접시를 동시에 버텨야 한다.',
    'q_lv4': '사발까지 등장했어. 집중해!',
    'q_lv5': '마지막 무대야. 버티는 만큼 기록이 된다.',

    's_lv1': '접시를 돌리며 구구단 정답을 말해 보세요.',
    's_lv2': '접시도, 문제도 놓치지 마세요.',
    's_lv3': '손과 머리를 함께 쓰면 뇌가 자극 됩니다.',

    // 실패 메시지
    'tip_fly_1': '너무 빨리 돌리면 날아간다고!',
    'tip_fly_2': '욕심부리지 마!',
    'tip_fly_3': '진정해, 한꺼번에 너무 많이 돌리지 마.',
    'tip_fly_4': '접시는 헬리곱터가 아니야!',

    'tip_fall_1': '한눈 팔지 말라구!',
    'tip_fall_2': '대체 어디다 정신을 두고 있는 거야?',
    'tip_fall_3': '생각보다 안 떨어진다고 방심하지 마!',
    'tip_fall_4': '접시에 파리가 앉겠다!',
  };

  static final _en = <String, String>{
    'game_title': 'SpinGo',
    'start': 'Start',
    'confirm': 'OK',
    'register': 'Submit',
    'retry': 'Retry',
    'exit': 'Exit',
    'leaderboard_title': 'Leaderboard (Top 7)',
    'enter_name_hint': 'Enter your name (Korean ≤5 chars, Eng/Num ≤12)',
    'congrats': 'Congrats! New record 🎉',
    'ai_tip_invalid_name': 'Invalid format.',
    'lang': 'Language',

    // Intro slides
    'intro1': 'Bong-sik Park was tired of his boring life...',
    'intro2': 'Then he met someone like his first love.',
    'intro3': 'And realized he still had dreams to chase...',
    'intro4': '"I want to join the circus."   \n"It won\'t be easy..."',
    'intro5': '"Who is that guy?"',

    // Level messages
    'lv1_msg': 'Rub the stick, and the plate will spin.',
    'lv1v_msg': 'Trays are large but light.',
    'lv2_msg': 'The riskier it gets, the louder the cheers.',
    'lv2t_msg': 'Take your time — you’ll see the bigger picture.',
    'lv2v_msg': 'Bowls are small and heavy!',
    'lv2b_msg': 'They spin well but shake hard when slowing down.',
    'lv3_msg': 'A little more skill and you’ll stand on stage.',
    'lv3v_msg': 'You’ve got talent — almost there!',
    'lv4_msg': 'Now it’s real — anything can happen on stage.',
    'lv4v_msg': 'Good! From here, it’s all about records.',

    'q_lv1': 'Let’s go for a new record!',
    'q_lv2': 'Remember: large plates have stronger friction.',
    'q_lv3': 'Now you must keep two large plates spinning at once.',
    'q_lv4': 'Bowls have joined the show. Stay focused!',
    'q_lv5': 'Final stage. Your record depends on how long you survive.',

    's_lv1': 'Spin the plates and say the correct multiplication answer.',
    's_lv2': 'Do not lose track of either the plates or the questions.',
    's_lv3': 'Using your hands and mind together stimulates your brain.',

    // Failure messages
    'tip_fly_1': 'Spin too fast and it’ll fly away!',
    'tip_fly_2': 'Don’t get greedy!',
    'tip_fly_3': 'Easy—don’t swipe too much at once.',
    'tip_fly_4': 'A plate is not a helicopter!',

    'tip_fall_1': 'Eyes on the plate!',
    'tip_fall_2': 'Where’s your focus?',
    'tip_fall_3': 'Don’t relax—plates fall when you least expect.',
    'tip_fall_4': 'Move it, before a fly lands on it!',
  };

  static String tr(String key) {
    final lang = LanguageManager.current.value;
    final map = lang == AppLang.en ? _en : _ko;
    return map[key] ?? _ko[key] ?? key;
  }
}
