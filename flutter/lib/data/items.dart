import '../models/item.dart';

const List<String> kCategories = [
  '전체', '종이류', '플라스틱류', '유리류', '금속류',
  '비닐류', '스티로폼', '음식물', '일반쓰레기', '특수수거',
];

const List<String> kPopular = [
  '치킨박스', '아이스팩', '배달 용기', '택배박스',
  '빨대', '페트병', '영수증', '스티로폼 박스',
  '건전지', '헌옷', '기저귀', '마스크',
];

const List<RecycleItem> kItems = [
  /* ── 종이류 ───────────────────────────────── */
  RecycleItem(
    name: '택배박스', aliases: ['택배', '상자', '종이박스', '박스'],
    category: '종이류', emoji: '📦', where: '종이류 수거함',
    steps: ['테이프·스티커·송장 모두 제거', '납작하게 접기', '종이류 수거함에 배출'],
    tips: ['송장은 개인정보 포함 — 반드시 제거', '소형 박스는 묶어서 배출 가능'],
    exception: '기름·음식물에 심하게 오염된 경우 일반쓰레기',
  ),
  RecycleItem(
    name: '신문지·잡지', aliases: ['신문', '잡지', '전단지', '광고지', '카탈로그'],
    category: '종이류', emoji: '📰', where: '종이류 수거함',
    steps: ['묶어서 종이류 수거함 배출'],
    tips: ['비닐 포장지는 분리해 비닐류로'],
  ),
  RecycleItem(
    name: 'A4·복사지', aliases: ['A4', '복사지', '프린터용지', '인쇄지', '이면지'],
    category: '종이류', emoji: '📄', where: '종이류 수거함',
    steps: ['묶어서 종이류 배출'],
  ),
  RecycleItem(
    name: '종이컵', aliases: ['일회용컵', '커피컵', '테이크아웃컵'],
    category: '종이류', emoji: '🥤', where: '종이류 수거함 (지역에 따라 전용 수거함)',
    steps: ['내용물 비우기', '물로 간단히 헹구기', '종이류 배출'],
    tips: ['일부 카페·주민센터에 종이컵 전용 수거함 있음'],
    exception: '코팅이 두꺼운 방수 컵은 일반쓰레기',
  ),
  RecycleItem(
    name: '우유팩·두유팩', aliases: ['우유팩', '두유팩', '주스팩', '종이팩'],
    category: '종이류', emoji: '🥛', where: '종이팩 전용 수거함 (없으면 종이류)',
    steps: ['깨끗이 씻기', '가위로 잘라 펼치기', '건조 후 전용 수거함 배출'],
    tips: ['세척·건조가 재활용 핵심'],
  ),
  RecycleItem(
    name: '영수증', aliases: ['영수증', '카드영수증', '감열지'],
    category: '일반쓰레기', emoji: '🧾', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['감열지는 BPA 코팅으로 재활용 불가'],
  ),
  RecycleItem(
    name: '치킨박스·피자박스', aliases: ['치킨박스', '피자박스', '기름박스'],
    category: '종이류', emoji: '🍗', where: '상태에 따라 다름',
    steps: ['기름 안 묻은 부분 → 종이류', '기름 묻은 부분 → 뜯어서 일반쓰레기'],
    tips: ['반반 분리 배출 가능'],
    exception: '기름·음식물 심하게 오염 시 일반쓰레기',
  ),
  RecycleItem(
    name: '냅킨·키친타올', aliases: ['냅킨', '키친타올', '페이퍼타올', '화장지'],
    category: '일반쓰레기', emoji: '🧻', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['사용한 종이류는 재활용 불가'],
  ),

  /* ── 플라스틱류 ────────────────────────────── */
  RecycleItem(
    name: '페트병(투명)', aliases: ['페트병', '생수병', '음료수병', 'PET', '콜라병'],
    category: '플라스틱류', emoji: '🍶', where: '투명 페트병 전용 수거함 우선',
    steps: ['내용물 완전히 비우기', '라벨 제거', '찌그러뜨려 뚜껑 닫기', '투명 페트 전용 수거함 또는 플라스틱류'],
    tips: ['투명 페트병은 별도 분리 의무(2020년~)', '색깔 있는 페트병은 일반 플라스틱류'],
  ),
  RecycleItem(
    name: '배달 용기·반찬통', aliases: ['배달용기', '반찬통', '플라스틱용기', '배달'],
    category: '플라스틱류', emoji: '🍱', where: '플라스틱류 수거함',
    steps: ['음식물 완전히 제거', '물로 헹궈 기름기 제거', '플라스틱류 배출'],
    tips: ['뚜껑 재질이 다르면 따로 분리', '검은 PP 용기도 플라스틱류 OK'],
    exception: '세척 불가 수준으로 오염 시 일반쓰레기',
  ),
  RecycleItem(
    name: '샴푸·세제 용기', aliases: ['샴푸', '린스', '바디워시', '세제', '화장품통'],
    category: '플라스틱류', emoji: '🧴', where: '플라스틱류 수거함',
    steps: ['내용물 완전히 비우기', '물로 헹구기', '펌프·튜브 분리', '플라스틱류 배출'],
    tips: ['펌프 내 금속 스프링은 분리해 금속류'],
  ),
  RecycleItem(
    name: '일회용 수저·포크', aliases: ['일회용수저', '일회용포크', '플라스틱수저'],
    category: '플라스틱류', emoji: '🥄', where: '플라스틱류 수거함',
    steps: ['음식물 닦아내기', '플라스틱류 배출'],
    tips: ['나무 수저는 일반쓰레기'],
  ),
  RecycleItem(
    name: '계란 트레이(플라스틱)', aliases: ['계란트레이', '달걀트레이'],
    category: '플라스틱류', emoji: '🥚', where: '플라스틱류 수거함',
    steps: ['이물질 제거 후 플라스틱류 배출'],
    tips: ['종이 계란판은 종이류로'],
  ),
  RecycleItem(
    name: '화장품 용기', aliases: ['화장품', '로션통', '크림통', '에센스병'],
    category: '플라스틱류', emoji: '💄', where: '플라스틱류 수거함 또는 공병함',
    steps: ['내용물 완전히 비우기', '헹구기', '플라스틱류 또는 공병 수거함'],
    tips: ['아모레·LG 매장 공병 수거 시 포인트 적립'],
  ),
  RecycleItem(
    name: '빨대', aliases: ['빨대', '플라스틱빨대'],
    category: '일반쓰레기', emoji: '🥤', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['너무 작아 선별 라인에서 걸러지지 않음'],
  ),
  RecycleItem(
    name: '칫솔', aliases: ['칫솔', '일회용칫솔'],
    category: '일반쓰레기', emoji: '🪥', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['전동칫솔은 배터리 분리 후 소형 가전 수거'],
  ),

  /* ── 유리류 ───────────────────────────────── */
  RecycleItem(
    name: '소주병·맥주병', aliases: ['소주병', '맥주병', '공병'],
    category: '유리류', emoji: '🍶', where: '편의점·마트 공병 반환 우선',
    steps: ['편의점·마트에 반환하면 보증금 환급', '반환 불가 시 유리류 수거함'],
    tips: ['소주병 100원, 맥주병 130원 보증금'],
  ),
  RecycleItem(
    name: '잼병·유리병', aliases: ['잼병', '유리병', '음료유리병', '소스병'],
    category: '유리류', emoji: '🫙', where: '유리류 수거함',
    steps: ['내용물 비우기', '뚜껑(금속) 따로 금속류', '유리병 유리류 배출'],
    exception: '깨진 유리는 신문지 감싸 "유리 조심" 표기 후 일반쓰레기',
  ),
  RecycleItem(
    name: '거울·강화유리', aliases: ['거울', '강화유리', '내열유리', '창문유리'],
    category: '일반쓰레기', emoji: '🪞', where: '종량제 봉투 또는 대형폐기물',
    steps: ['신문지 등으로 두껍게 감싸기', '"유리 조심" 메모', '종량제 봉투 또는 대형폐기물'],
    tips: ['강화·내열·거울 유리는 선별 불가'],
  ),

  /* ── 금속류 ───────────────────────────────── */
  RecycleItem(
    name: '음료·통조림 캔', aliases: ['캔', '음료캔', '통조림', '맥주캔', '알루미늄캔'],
    category: '금속류', emoji: '🥫', where: '금속류 수거함',
    steps: ['내용물 완전히 비우기', '물로 헹구기', '찌그러뜨려 금속류 배출'],
    tips: ['알루미늄·철 캔 모두 금속류 OK'],
  ),
  RecycleItem(
    name: '부탄가스·스프레이 캔', aliases: ['부탄가스', '에어로졸', '스프레이캔', '가스'],
    category: '금속류', emoji: '🧯', where: '금속류 수거함 (구멍 필수)',
    steps: ['내용물 반드시 다 소진', '야외 통풍 장소에서 구멍 뚫기', '금속류 배출'],
    tips: ['불 근처 구멍 뚫기 절대 금지'],
    exception: '내용물 남아있으면 배출 전 반드시 소진',
  ),
  RecycleItem(
    name: '알루미늄 호일', aliases: ['호일', '알루미늄호일', '은박지'],
    category: '금속류', emoji: '✨', where: '금속류 수거함',
    steps: ['음식물 닦아내기', '구겨서 금속류 배출'],
  ),
  RecycleItem(
    name: '냄비·프라이팬', aliases: ['냄비', '프라이팬', '솥'],
    category: '금속류', emoji: '🍳', where: '금속류 수거함 또는 대형폐기물',
    steps: ['작은 것 → 금속류', '큰 것 → 대형폐기물 신고'],
  ),

  /* ── 비닐류 ───────────────────────────────── */
  RecycleItem(
    name: '비닐봉지·마트봉투', aliases: ['비닐봉지', '비닐', '마트봉투', '검은봉지'],
    category: '비닐류', emoji: '🛍️', where: '비닐류 수거함',
    steps: ['내용물 제거', '이물질 털어내기', '비닐류 수거함 배출'],
    exception: '기름·음식물 오염 심하면 일반쓰레기',
  ),
  RecycleItem(
    name: '랩·뽁뽁이', aliases: ['랩', '비닐랩', '에어캡', '뽁뽁이', '버블랩'],
    category: '비닐류', emoji: '📦', where: '비닐류 수거함',
    steps: ['이물질 제거', '비닐류 수거함 배출'],
    tips: ['뽁뽁이는 공기 빼고 접어서'],
  ),
  RecycleItem(
    name: '아이스팩', aliases: ['아이스팩', '얼음팩', '냉매', '보냉팩'],
    category: '비닐류', emoji: '🧊', where: '종류에 따라 다름',
    steps: ['물 타입 → 물은 싱크대, 비닐은 비닐류', '젤 타입 → 뜯지 않고 통째로 일반쓰레기'],
    tips: ['마트·쿠팡 반납 이용 시 재사용 가능'],
    exception: '젤 타입은 통째로 일반쓰레기',
  ),
  RecycleItem(
    name: '라면·과자 봉지', aliases: ['라면봉지', '과자봉지', '스낵봉지'],
    category: '비닐류', emoji: '🍜', where: '비닐류 수거함',
    steps: ['내용물 완전히 비우기', '비닐류 수거함 배출'],
  ),
  RecycleItem(
    name: '냉동식품 봉지', aliases: ['냉동식품', '냉동봉지'],
    category: '비닐류', emoji: '❄️', where: '비닐류 수거함',
    steps: ['이물질 제거 후 비닐류 배출'],
  ),
  RecycleItem(
    name: '지퍼백·위생백', aliases: ['지퍼백', '지프락', '위생백', '비닐팩'],
    category: '비닐류', emoji: '🤐', where: '비닐류 수거함',
    steps: ['내용물 제거 후 비닐류 배출'],
  ),
  RecycleItem(
    name: '비닐장갑', aliases: ['비닐장갑', '일회용장갑', 'PE장갑'],
    category: '비닐류', emoji: '🧤', where: '비닐류 수거함',
    steps: ['이물질 없으면 비닐류 배출'],
  ),

  /* ── 스티로폼 ──────────────────────────────── */
  RecycleItem(
    name: '스티로폼 박스', aliases: ['스티로폼', '스티로폼박스', '발포'],
    category: '스티로폼', emoji: '📫', where: '스티로폼 수거함',
    steps: ['테이프·라벨 제거', '이물질 제거', '스티로폼 수거함 배출'],
    exception: '기름 오염 심하면 일반쓰레기',
  ),
  RecycleItem(
    name: '컵라면 용기', aliases: ['컵라면', '컵용기', '스티로폼컵'],
    category: '스티로폼', emoji: '🍜', where: '스티로폼 수거함',
    steps: ['내용물·국물 완전히 제거', '물로 헹구기', '스티로폼 수거함 배출'],
    tips: ['라벨(종이) 제거 후 배출'],
  ),
  RecycleItem(
    name: '완충재(흰 스티로폼)', aliases: ['완충재', '포장재', '스티로폼완충'],
    category: '스티로폼', emoji: '🏠', where: '스티로폼 수거함',
    steps: ['테이프 제거', '조각 모아서 스티로폼 수거함'],
  ),

  /* ── 음식물 ───────────────────────────────── */
  RecycleItem(
    name: '채소·과일 껍질', aliases: ['채소껍질', '과일껍질', '양파껍질', '귤껍질'],
    category: '음식물', emoji: '🥦', where: '음식물 쓰레기봉투',
    steps: ['음식물 쓰레기봉투에 배출'],
  ),
  RecycleItem(
    name: '뼈다귀·조개껍데기', aliases: ['뼈', '갈비뼈', '닭뼈', '조개껍질'],
    category: '일반쓰레기', emoji: '🦴', where: '종량제 봉투',
    steps: ['건조 후 종량제 봉투에 배출'],
    tips: ['단단한 뼈·껍데기는 분쇄 불가 → 일반쓰레기'],
  ),
  RecycleItem(
    name: '달걀 껍데기', aliases: ['달걀껍데기', '계란껍데기'],
    category: '일반쓰레기', emoji: '🥚', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['달걀 껍데기는 일반쓰레기 (음식물 아님)'],
  ),
  RecycleItem(
    name: '커피 찌꺼기', aliases: ['커피찌꺼기', '원두찌꺼기'],
    category: '음식물', emoji: '☕', where: '음식물 쓰레기봉투',
    steps: ['음식물 쓰레기봉투에 배출'],
    tips: ['화분 비료·탈취 재활용 가능'],
  ),
  RecycleItem(
    name: '과일 씨앗', aliases: ['씨앗', '복숭아씨', '망고씨', '아보카도씨'],
    category: '일반쓰레기', emoji: '🍑', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['딱딱한 씨앗은 일반쓰레기 (음식물 아님)'],
  ),

  /* ── 일반쓰레기 ────────────────────────────── */
  RecycleItem(
    name: '마스크', aliases: ['마스크', 'KF94', '덴탈마스크', '일회용마스크'],
    category: '일반쓰레기', emoji: '😷', where: '종량제 봉투',
    steps: ['끈 묶거나 접어서 종량제 봉투'],
  ),
  RecycleItem(
    name: '기저귀', aliases: ['기저귀', '일회용기저귀'],
    category: '일반쓰레기', emoji: '👶', where: '종량제 봉투',
    steps: ['내용물 처리 후 종량제 봉투'],
  ),
  RecycleItem(
    name: '생리대·팬티라이너', aliases: ['생리대', '패드', '팬티라이너'],
    category: '일반쓰레기', emoji: '🌸', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
  ),
  RecycleItem(
    name: '화장솜·면봉', aliases: ['화장솜', '면봉', '코튼패드'],
    category: '일반쓰레기', emoji: '🧴', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
  ),
  RecycleItem(
    name: '도자기·사기그릇', aliases: ['도자기', '사기그릇', '그릇', '컵', '뚝배기'],
    category: '일반쓰레기', emoji: '🍽️', where: '종량제 봉투 또는 대형폐기물',
    steps: ['신문지 등으로 감싸기', '작은 것 → 종량제 봉투', '큰 것 → 대형폐기물'],
    tips: ['도자기는 유리류 선별 불가'],
  ),
  RecycleItem(
    name: 'CD·DVD', aliases: ['CD', 'DVD', '블루레이', '디스크'],
    category: '일반쓰레기', emoji: '💿', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['케이스(플라스틱)는 플라스틱류로 분리'],
  ),
  RecycleItem(
    name: '볼펜·연필', aliases: ['볼펜', '연필', '샤프', '마커', '형광펜'],
    category: '일반쓰레기', emoji: '✏️', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
  ),
  RecycleItem(
    name: '스티커·포스트잇', aliases: ['스티커', '포스트잇', '라벨지'],
    category: '일반쓰레기', emoji: '📌', where: '종량제 봉투',
    steps: ['종량제 봉투에 버리기'],
    tips: ['접착제 때문에 종이류 재활용 불가'],
  ),

  /* ── 특수수거 ──────────────────────────────── */
  RecycleItem(
    name: '건전지·충전지', aliases: ['건전지', '배터리', 'AA', 'AAA', '리튬'],
    category: '특수수거', emoji: '🔋', where: '건전지 전용 수거함 (마트·편의점·주민센터)',
    steps: ['전용 수거함에 배출'],
    tips: ['리튬 배터리 팽창 시 즉시 격리 후 소방서 신고'],
  ),
  RecycleItem(
    name: '형광등·전구', aliases: ['형광등', '전구', 'LED', '할로겐'],
    category: '특수수거', emoji: '💡', where: '형광등 전용 수거함 (주민센터·마트)',
    steps: ['깨지지 않게 보관', '전용 수거함에 배출'],
    tips: ['깨진 형광등은 비닐백에 담아 "파손 형광등" 표기 후 배출'],
  ),
  RecycleItem(
    name: '스마트폰·노트북', aliases: ['스마트폰', '핸드폰', '태블릿', '노트북'],
    category: '특수수거', emoji: '📱', where: '전자제품 수거함 또는 제조사 회수',
    steps: ['개인정보 초기화 필수', '배터리 분리 가능하면 분리', '전자제품 수거함 또는 제조사 수거 신청'],
  ),
  RecycleItem(
    name: '헌옷·신발', aliases: ['헌옷', '중고옷', '신발', '의류'],
    category: '특수수거', emoji: '👕', where: '의류 수거함 (아파트 단지·동네)',
    steps: ['세탁 후 비닐봉투에 담기', '의류 수거함에 투입'],
    tips: ['상태 좋으면 당근마켓·아름다운가게 기부', '젖은 옷 투입 금지'],
    exception: '습기 있는 옷 투입 금지',
  ),
  RecycleItem(
    name: '폐의약품', aliases: ['약', '알약', '시럽', '안약', '연고'],
    category: '특수수거', emoji: '💊', where: '약국 또는 보건소 폐의약품 수거함',
    steps: ['약국·보건소 전용 수거함에 배출'],
    tips: ['싱크대·변기 투기 금지 (수질 오염)'],
  ),
  RecycleItem(
    name: '폐식용유', aliases: ['폐식용유', '식용유', '튀김기름'],
    category: '특수수거', emoji: '🫙', where: '폐식용유 수거함 (주민센터·아파트)',
    steps: ['식힌 후 밀봉', '전용 수거함 배출'],
    tips: ['싱크대 버리면 하수도 막힘·수질오염'],
  ),
  RecycleItem(
    name: '대형 가구·가전', aliases: ['소파', '냉장고', '세탁기', 'TV', '가구', '매트리스'],
    category: '특수수거', emoji: '🛋️', where: '대형폐기물 스티커 부착 후 배출',
    steps: ['주민센터 또는 지자체 앱에서 신고', '수수료 납부 후 스티커 받기', '지정 장소에 배출'],
    tips: ['지자체별로 신고 방법·요금 다름'],
  ),
];
