'use strict';

/* ═══════════════════════════════════════════════════════════════
   데이터 — 80+ 품목
═══════════════════════════════════════════════════════════════ */
const ITEMS = [
  /* ── 종이류 ───────────────────────────────────────────── */
  {
    name:'택배박스', aliases:['택배','상자','종이박스','박스','포장박스'],
    cat:'종이류', emoji:'📦', where:'종이류 수거함',
    steps:['테이프·스티커·송장 모두 제거','납작하게 접기','종이류 수거함에 배출'],
    tips:['송장은 개인정보 포함 — 떼거나 가위로 오려내기','소형 박스는 묶어서 배출 가능'],
    exc:'기름·음식물에 심하게 오염된 경우 일반쓰레기'
  },
  {
    name:'신문지·전단지', aliases:['신문','잡지','카탈로그','광고지','전단지'],
    cat:'종이류', emoji:'📰', where:'종이류 수거함',
    steps:['묶어서 종이류 수거함 배출'],
    tips:['비닐 포장지는 분리해 비닐류로'],
    exc:null
  },
  {
    name:'책(단행본)', aliases:['책','교과서','소설','만화책','참고서'],
    cat:'종이류', emoji:'📚', where:'종이류 수거함',
    steps:['스프링 있으면 분리(금속류)','나머지 종이류 배출'],
    tips:['표지 코팅이 두꺼운 경우도 종이류 OK'],
    exc:null
  },
  {
    name:'A4·복사지', aliases:['A4','복사지','프린터용지','인쇄용지','이면지'],
    cat:'종이류', emoji:'📄', where:'종이류 수거함',
    steps:['묶어서 종이류 배출'],
    tips:['이면지도 종이류 OK'],
    exc:null
  },
  {
    name:'종이컵', aliases:['일회용컵','커피컵','테이크아웃컵'],
    cat:'종이류', emoji:'🥤', where:'종이류 수거함 (지역에 따라 전용 수거함)',
    steps:['내용물 비우기','물로 간단히 헹구기','종이류 배출'],
    tips:['일부 카페·주민센터에 종이컵 전용 수거함 있음'],
    exc:'코팅이 두꺼운 방수 컵은 일반쓰레기'
  },
  {
    name:'우유팩·두유팩', aliases:['우유팩','두유팩','주스팩','종이팩','카톤'],
    cat:'종이류', emoji:'🥛', where:'종이팩 전용 수거함 (없으면 종이류)',
    steps:['깨끗이 씻기','가위로 잘라 펼치기','건조 후 전용 수거함에 배출'],
    tips:['세척·건조가 재활용 핵심','전용 수거함 없으면 종이류에 묶어 배출'],
    exc:null
  },
  {
    name:'종이봉투·쇼핑백(종이)', aliases:['종이봉투','종이쇼핑백','크래프트봉투'],
    cat:'종이류', emoji:'🛍️', where:'종이류 수거함',
    steps:['코팅·테이프 제거 후 종이류 배출'],
    tips:['손잡이 끈이 비닐이면 분리'],
    exc:null
  },
  {
    name:'달력·노트', aliases:['달력','노트','다이어리','메모지'],
    cat:'종이류', emoji:'📅', where:'종이류 수거함',
    steps:['스프링 분리(금속류)','종이류 배출'],
    tips:null,
    exc:null
  },
  {
    name:'영수증(감열지)', aliases:['영수증','카드영수증','감열지'],
    cat:'일반쓰레기', emoji:'🧾', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['열 인쇄 방식(감열지)은 BPA 코팅으로 재활용 불가'],
    exc:null
  },
  {
    name:'치킨박스·피자박스', aliases:['치킨박스','피자박스','기름박스'],
    cat:'종이류', emoji:'🍗', where:'상태에 따라 다름',
    steps:['기름 안 묻은 부분(뚜껑 안쪽 등) → 종이류','기름 묻은 부분 → 뜯어서 일반쓰레기'],
    tips:['반반 분리 배출 가능','아예 기름이 많으면 통째로 일반쓰레기'],
    exc:'기름·음식물 심하게 오염 시 일반쓰레기'
  },
  {
    name:'냅킨·키친타올', aliases:['냅킨','키친타올','페이퍼타올','화장지'],
    cat:'일반쓰레기', emoji:'🧻', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['이미 사용해 오염된 종이류는 재활용 불가'],
    exc:null
  },

  /* ── 플라스틱류 ─────────────────────────────────────── */
  {
    name:'페트병(투명)', aliases:['페트병','생수병','음료수병','콜라병','PET'],
    cat:'플라스틱류', emoji:'🍶', where:'투명 페트병 전용 수거함 우선',
    steps:['내용물 완전히 비우기','라벨 제거','찌그러뜨려 뚜껑 닫기','투명 페트 전용 수거함 또는 플라스틱류'],
    tips:['투명 페트병은 별도 분리 의무(2020년~)','색깔 있는 페트병은 일반 플라스틱류'],
    exc:null
  },
  {
    name:'배달 용기·반찬통', aliases:['배달용기','반찬통','플라스틱용기','테이크아웃','배달'],
    cat:'플라스틱류', emoji:'🍱', where:'플라스틱류 수거함',
    steps:['음식물 완전히 제거','물로 헹궈 기름기 제거','플라스틱류 배출'],
    tips:['뚜껑 재질이 다르면 따로 분리','검은 PP 용기도 플라스틱류 OK'],
    exc:'세척 불가 수준으로 오염 시 일반쓰레기'
  },
  {
    name:'샴푸·세제 용기', aliases:['샴푸','린스','바디워시','세제','주방세제','화장품통'],
    cat:'플라스틱류', emoji:'🧴', where:'플라스틱류 수거함',
    steps:['내용물 완전히 비우기','물로 헹구기','펌프·튜브 분리','플라스틱류 배출'],
    tips:['펌프 내 금속 스프링은 분리해 금속류로'],
    exc:null
  },
  {
    name:'요플레·요구르트컵', aliases:['요플레','요구르트','야쿠르트','플라스틱컵'],
    cat:'플라스틱류', emoji:'🧃', where:'플라스틱류 수거함',
    steps:['헹군 후 플라스틱류 배출'],
    tips:['알루미늄 포일 뚜껑은 금속류로 분리'],
    exc:null
  },
  {
    name:'일회용 수저·포크', aliases:['일회용수저','일회용포크','플라스틱수저','플라스틱포크'],
    cat:'플라스틱류', emoji:'🥄', where:'플라스틱류 수거함',
    steps:['음식물 닦아내기','플라스틱류 배출'],
    tips:['나무 수저는 일반쓰레기'],
    exc:null
  },
  {
    name:'계란 트레이(플라스틱)', aliases:['계란트레이','달걀트레이','플라스틱계란판'],
    cat:'플라스틱류', emoji:'🥚', where:'플라스틱류 수거함',
    steps:['이물질 제거 후 플라스틱류 배출'],
    tips:['종이 계란판은 종이류로'],
    exc:null
  },
  {
    name:'계란 트레이(종이)', aliases:['계란판','달걀판','종이계란판'],
    cat:'종이류', emoji:'🥚', where:'종이류 수거함',
    steps:['종이류 수거함 배출'],
    tips:null,
    exc:null
  },
  {
    name:'화장품 플라스틱 용기', aliases:['화장품','로션통','크림통','스킨병','에센스병'],
    cat:'플라스틱류', emoji:'💄', where:'플라스틱류 수거함 또는 공병함',
    steps:['내용물 완전히 비우기','헹구기','플라스틱류 또는 화장품 공병 수거함'],
    tips:['아모레·LG생활건강 매장 공병 수거함 이용 시 포인트 적립'],
    exc:null
  },
  {
    name:'플라스틱 옷걸이', aliases:['플라스틱옷걸이','옷걸이','행거'],
    cat:'플라스틱류', emoji:'🧥', where:'플라스틱류 수거함',
    steps:['플라스틱류 배출'],
    tips:['세탁소 철제 옷걸이는 금속류','대형 행거는 대형폐기물'],
    exc:null
  },
  {
    name:'약통·알약케이스', aliases:['약통','약병','알약통','비타민통'],
    cat:'플라스틱류', emoji:'💊', where:'플라스틱류 수거함',
    steps:['남은 약은 약국 폐의약품 수거함 배출','빈 통은 헹궈 플라스틱류'],
    tips:['약은 절대 싱크대·변기에 버리지 않기'],
    exc:null
  },
  {
    name:'빨대', aliases:['빨대','플라스틱빨대','종이빨대'],
    cat:'일반쓰레기', emoji:'🥤', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['너무 작아 선별 라인에서 걸러지지 않음'],
    exc:null
  },
  {
    name:'칫솔', aliases:['칫솔','일회용칫솔'],
    cat:'일반쓰레기', emoji:'🪥', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['전동칫솔은 배터리 분리 후 소형 가전 수거'],
    exc:null
  },
  {
    name:'면도기(일회용)', aliases:['면도기','일회용면도기'],
    cat:'일반쓰레기', emoji:'🪒', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['전기면도기는 소형 가전 수거'],
    exc:null
  },

  /* ── 유리류 ───────────────────────────────────────────── */
  {
    name:'소주병·맥주병', aliases:['소주병','맥주병','공병','빈병'],
    cat:'유리류', emoji:'🍶', where:'편의점·마트 공병 반환 우선',
    steps:['편의점·마트에 반환하면 보증금 환급','반환 불가 시 유리류 수거함 배출'],
    tips:['소주병 100원, 맥주병 130원 보증금','대형마트도 공병 반환기 있음'],
    exc:null
  },
  {
    name:'잼병·음료 유리병', aliases:['잼병','유리병','음료유리병','소스병'],
    cat:'유리류', emoji:'🫙', where:'유리류 수거함',
    steps:['내용물 비우기','뚜껑(금속) 따로 금속류','유리병 유리류 배출'],
    tips:['깨지지 않게 주의'],
    exc:'깨진 유리는 신문지 감싸 "유리 조심" 표기 후 일반쓰레기'
  },
  {
    name:'화장품 유리병·향수병', aliases:['향수병','화장품유리','유리화장품'],
    cat:'유리류', emoji:'🌸', where:'유리류 수거함',
    steps:['내용물 완전히 비우기','펌프·플라스틱 부품 분리(플라스틱류)','유리 몸체 유리류 배출'],
    tips:null,
    exc:null
  },
  {
    name:'거울·강화유리·내열유리', aliases:['거울','강화유리','내열유리','창문유리','파이렉스'],
    cat:'일반쓰레기', emoji:'🪞', where:'종량제 봉투 또는 대형폐기물',
    steps:['신문지 등으로 두껍게 감싸기','"유리 조심" 메모','종량제 봉투 또는 대형폐기물'],
    tips:['강화·내열·거울 유리는 일반 유리류와 성분이 달라 선별 불가'],
    exc:null
  },

  /* ── 금속류 ───────────────────────────────────────────── */
  {
    name:'음료·통조림 캔', aliases:['캔','음료캔','통조림','맥주캔','알루미늄캔','철캔'],
    cat:'금속류', emoji:'🥫', where:'금속류 수거함',
    steps:['내용물 완전히 비우기','물로 헹구기','찌그러뜨려 금속류 배출'],
    tips:['알루미늄·철 캔 모두 금속류 OK'],
    exc:null
  },
  {
    name:'부탄가스·스프레이 캔', aliases:['부탄가스','에어로졸','스프레이','캔','가스'],
    cat:'금속류', emoji:'🧯', where:'금속류 수거함 (구멍 필수)',
    steps:['내용물 반드시 다 소진','야외 통풍 장소에서 구멍 뚫기','금속류 배출'],
    tips:['불 근처 구멍 뚫기 절대 금지','내용물 남으면 폭발 위험'],
    exc:'내용물 남아있으면 배출 전 반드시 소진'
  },
  {
    name:'알루미늄 호일', aliases:['호일','알루미늄호일','은박지'],
    cat:'금속류', emoji:'✨', where:'금속류 수거함',
    steps:['음식물 닦아내기','구겨서 금속류 배출'],
    tips:['너무 얇고 오염이 심하면 일반쓰레기 가능'],
    exc:null
  },
  {
    name:'철제 옷걸이', aliases:['철옷걸이','와이어옷걸이','세탁소옷걸이'],
    cat:'금속류', emoji:'🪝', where:'금속류 수거함',
    steps:['금속류 수거함 배출'],
    tips:['플라스틱 옷걸이는 플라스틱류로'],
    exc:null
  },
  {
    name:'냄비·프라이팬', aliases:['냄비','프라이팬','솥','냄비뚜껑'],
    cat:'금속류', emoji:'🍳', where:'금속류 수거함 또는 대형폐기물',
    steps:['작은 것 → 금속류','큰 것 → 대형폐기물 신고'],
    tips:['테프론 코팅 프라이팬도 금속류 OK'],
    exc:null
  },
  {
    name:'가위·공구류', aliases:['가위','드라이버','렌치','공구'],
    cat:'금속류', emoji:'✂️', where:'금속류 수거함 또는 대형폐기물',
    steps:['작은 것 → 금속류','큰 것 → 대형폐기물'],
    tips:null,
    exc:null
  },

  /* ── 비닐류 ───────────────────────────────────────────── */
  {
    name:'비닐봉지·마트봉투', aliases:['비닐봉지','비닐','마트봉투','검은봉지','쇼핑봉투'],
    cat:'비닐류', emoji:'🛍️', where:'비닐류 수거함',
    steps:['내용물 제거','이물질 털어내기','비닐류 수거함 배출'],
    tips:['여러 장 겹쳐 배출 OK'],
    exc:'기름·음식물 오염 심하면 일반쓰레기'
  },
  {
    name:'랩·뽁뽁이(에어캡)', aliases:['랩','비닐랩','에어캡','뽁뽁이','버블랩','완충비닐'],
    cat:'비닐류', emoji:'📦', where:'비닐류 수거함',
    steps:['이물질 제거','비닐류 수거함 배출'],
    tips:['뽁뽁이는 공기 빼고 접어서'],
    exc:null
  },
  {
    name:'아이스팩', aliases:['아이스팩','얼음팩','냉매','보냉팩'],
    cat:'비닐류', emoji:'🧊', where:'종류에 따라 다름',
    steps:['물 타입 → 물은 싱크대, 비닐은 비닐류','젤 타입 → 뜯지 않고 통째로 일반쓰레기'],
    tips:['마트·쿠팡 반납 이용 시 재사용 가능','젤 타입은 고흡수성 수지 포함 → 일반쓰레기'],
    exc:'젤 타입은 통째로 일반쓰레기'
  },
  {
    name:'라면·과자 봉지', aliases:['라면봉지','과자봉지','스낵봉지','시리얼봉투'],
    cat:'비닐류', emoji:'🍜', where:'비닐류 수거함',
    steps:['내용물 완전히 비우기','비닐류 수거함 배출'],
    tips:['기름·소스 없으면 OK'],
    exc:null
  },
  {
    name:'냉동식품 봉지', aliases:['냉동식품','냉동봉지','냉동포장'],
    cat:'비닐류', emoji:'❄️', where:'비닐류 수거함',
    steps:['이물질 제거 후 비닐류 배출'],
    tips:null,
    exc:null
  },
  {
    name:'지퍼백·위생백', aliases:['지퍼백','지프락','위생백','비닐팩'],
    cat:'비닐류', emoji:'🤐', where:'비닐류 수거함',
    steps:['내용물 제거 후 비닐류 배출'],
    tips:null,
    exc:null
  },
  {
    name:'비닐장갑', aliases:['비닐장갑','일회용장갑','PE장갑'],
    cat:'비닐류', emoji:'🧤', where:'비닐류 수거함',
    steps:['이물질 없으면 비닐류 배출'],
    tips:['음식 만졌어도 오염 적으면 비닐류 OK'],
    exc:null
  },
  {
    name:'에어백 완충재(택배)', aliases:['에어백','공기주머니','완충에어백'],
    cat:'비닐류', emoji:'💨', where:'비닐류 수거함',
    steps:['공기 빼기','비닐류 배출'],
    tips:null,
    exc:null
  },

  /* ── 스티로폼 ─────────────────────────────────────────── */
  {
    name:'스티로폼 박스', aliases:['스티로폼','스티로폼박스','발포'],
    cat:'스티로폼', emoji:'📫', where:'스티로폼 수거함',
    steps:['테이프·라벨 제거','이물질 제거','스티로폼 수거함 배출'],
    tips:['오염 심하면 일반쓰레기','부서진 조각도 모아서 배출'],
    exc:'기름 오염 심하면 일반쓰레기'
  },
  {
    name:'컵라면 용기', aliases:['컵라면','컵용기','스티로폼컵'],
    cat:'스티로폼', emoji:'🍜', where:'스티로폼 수거함',
    steps:['내용물·국물 완전히 제거','물로 헹구기','스티로폼 수거함 배출'],
    tips:['라벨(종이) 제거 후 배출'],
    exc:null
  },
  {
    name:'완충재(흰 스티로폼)', aliases:['완충재','포장재','스티로폼완충','발포재'],
    cat:'스티로폼', emoji:'🏠', where:'스티로폼 수거함',
    steps:['테이프 제거','조각 모아서 스티로폼 수거함'],
    tips:['비닐봉지에 담아 배출해도 OK'],
    exc:null
  },
  {
    name:'생선·과일 포장 스티로폼', aliases:['생선스티로폼','과일스티로폼','마트스티로폼'],
    cat:'스티로폼', emoji:'🐟', where:'스티로폼 수거함',
    steps:['물기·이물질 제거','스티로폼 수거함 배출'],
    tips:['일부 마트에 자체 수거함 있음'],
    exc:'생선 비린내·혈흔 심하면 일반쓰레기'
  },

  /* ── 음식물 ───────────────────────────────────────────── */
  {
    name:'채소·과일 껍질', aliases:['채소껍질','과일껍질','야채','양파껍질','귤껍질','사과껍질'],
    cat:'음식물', emoji:'🥦', where:'음식물 쓰레기봉투',
    steps:['음식물 쓰레기봉투에 배출'],
    tips:['양파·마늘 등 대부분 음식물 OK'],
    exc:null
  },
  {
    name:'뼈다귀·조개껍데기', aliases:['뼈','갈비뼈','닭뼈','조개껍질','홍합껍질'],
    cat:'일반쓰레기', emoji:'🦴', where:'종량제 봉투',
    steps:['건조 후 종량제 봉투에 배출'],
    tips:['단단한 뼈·껍데기는 퇴비·분쇄 불가 → 일반쓰레기'],
    exc:null
  },
  {
    name:'달걀 껍데기', aliases:['달걀껍데기','계란껍데기'],
    cat:'일반쓰레기', emoji:'🥚', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['달걀 껍데기는 일반쓰레기 (음식물 아님)'],
    exc:null
  },
  {
    name:'커피 찌꺼기', aliases:['커피찌꺼기','커피가루','원두찌꺼기'],
    cat:'음식물', emoji:'☕', where:'음식물 쓰레기봉투',
    steps:['음식물 쓰레기봉투에 배출'],
    tips:['화분 비료·탈취·제습 재활용 가능'],
    exc:null
  },
  {
    name:'과일 씨앗(딱딱한 것)', aliases:['씨앗','복숭아씨','살구씨','망고씨','아보카도씨'],
    cat:'일반쓰레기', emoji:'🍑', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['딱딱한 씨앗은 일반쓰레기 (음식물 아님)'],
    exc:null
  },
  {
    name:'견과류 껍데기', aliases:['호두껍질','땅콩껍질','도토리껍질','밤껍질'],
    cat:'일반쓰레기', emoji:'🥜', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'티백', aliases:['티백','녹차티백','홍차','허브티'],
    cat:'음식물', emoji:'🍵', where:'음식물 쓰레기봉투 (내용물만)',
    steps:['티백 봉지(종이·비닐) 분리','내용물은 음식물','봉지는 재질에 따라 분리'],
    tips:['종이 봉지 → 종이류, 나일론 봉지 → 일반쓰레기'],
    exc:null
  },

  /* ── 일반쓰레기 ───────────────────────────────────────── */
  {
    name:'마스크(KF·일회용)', aliases:['마스크','KF94','덴탈마스크','일회용마스크'],
    cat:'일반쓰레기', emoji:'😷', where:'종량제 봉투',
    steps:['끈 묶거나 접어서 종량제 봉투에 배출'],
    tips:['재사용 금지, 일반쓰레기 처리'],
    exc:null
  },
  {
    name:'기저귀', aliases:['기저귀','일회용기저귀','팬티기저귀'],
    cat:'일반쓰레기', emoji:'👶', where:'종량제 봉투',
    steps:['내용물 처리 후 종량제 봉투'],
    tips:null,
    exc:null
  },
  {
    name:'생리대·팬티라이너', aliases:['생리대','패드','팬티라이너','위생용품'],
    cat:'일반쓰레기', emoji:'🌸', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'화장솜·면봉', aliases:['화장솜','면봉','코튼패드','화장패드'],
    cat:'일반쓰레기', emoji:'🧴', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'반창고·붕대', aliases:['반창고','밴드','붕대','거즈'],
    cat:'일반쓰레기', emoji:'🩹', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'볼펜·연필·샤프', aliases:['볼펜','연필','샤프','마커','형광펜'],
    cat:'일반쓰레기', emoji:'✏️', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'도자기·사기그릇', aliases:['도자기','사기그릇','그릇','컵','깨진그릇','뚝배기'],
    cat:'일반쓰레기', emoji:'🍽️', where:'종량제 봉투 또는 대형폐기물',
    steps:['신문지 등으로 감싸기','작은 것 → 종량제 봉투','큰 것 → 대형폐기물'],
    tips:['도자기·뚝배기는 유리류 선별 불가 → 일반쓰레기'],
    exc:null
  },
  {
    name:'고무·실리콘 제품', aliases:['고무','실리콘','고무장갑','실리콘용기','고무줄'],
    cat:'일반쓰레기', emoji:'🧤', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['실리콘·고무는 선별 분류 어려움'],
    exc:null
  },
  {
    name:'스티커·포스트잇', aliases:['스티커','포스트잇','라벨지','메모지'],
    cat:'일반쓰레기', emoji:'📌', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['접착제 때문에 종이류 재활용 불가'],
    exc:null
  },
  {
    name:'나무젓가락·이쑤시개', aliases:['나무젓가락','이쑤시개','나무수저'],
    cat:'일반쓰레기', emoji:'🥢', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:null,
    exc:null
  },
  {
    name:'담배꽁초', aliases:['담배꽁초','꽁초','담배'],
    cat:'일반쓰레기', emoji:'🚬', where:'종량제 봉투',
    steps:['완전히 끄기','종량제 봉투에 버리기'],
    tips:['유해물질 포함 → 일반쓰레기'],
    exc:null
  },
  {
    name:'CD·DVD', aliases:['CD','DVD','블루레이','디스크'],
    cat:'일반쓰레기', emoji:'💿', where:'종량제 봉투',
    steps:['종량제 봉투에 버리기'],
    tips:['케이스(플라스틱)는 플라스틱류로 분리'],
    exc:null
  },
  {
    name:'안경·선글라스', aliases:['안경','선글라스'],
    cat:'일반쓰레기', emoji:'👓', where:'종량제 봉투 또는 기증',
    steps:['종량제 봉투에 버리기','상태 좋으면 시력케어 기관에 기부'],
    tips:null,
    exc:null
  },

  /* ── 특수수거 ─────────────────────────────────────────── */
  {
    name:'건전지·충전지', aliases:['건전지','배터리','충전지','AA','AAA','리튬'],
    cat:'특수수거', emoji:'🔋', where:'건전지 전용 수거함 (마트·편의점·주민센터)',
    steps:['전용 수거함에 배출'],
    tips:['리튬 배터리 팽창 시 즉시 격리 후 소방서·구청 신고','양극 절연테이프 붙여 보관'],
    exc:null
  },
  {
    name:'형광등·전구', aliases:['형광등','전구','LED','할로겐','CFL'],
    cat:'특수수거', emoji:'💡', where:'형광등 전용 수거함 (주민센터·마트)',
    steps:['깨지지 않게 보관','전용 수거함에 배출'],
    tips:['깨진 형광등 → 비닐백에 담아 "파손 형광등" 표기 후 배출'],
    exc:null
  },
  {
    name:'스마트폰·태블릿·노트북', aliases:['스마트폰','핸드폰','태블릿','노트북','전자기기'],
    cat:'특수수거', emoji:'📱', where:'전자제품 수거함 또는 제조사 회수',
    steps:['개인정보 초기화 필수','배터리 분리 가능하면 분리','전자제품 수거함 또는 제조사 수거 신청'],
    tips:['삼성·애플·LG 공식 수거 프로그램 활용'],
    exc:null
  },
  {
    name:'헌옷·신발', aliases:['헌옷','중고옷','신발','의류','옷'],
    cat:'특수수거', emoji:'👕', where:'의류 수거함 (아파트 단지·동네)',
    steps:['세탁 후 비닐봉투에 담기','의류 수거함에 투입'],
    tips:['상태 좋으면 당근마켓·아름다운가게 기부','젖은 옷 수거함 투입 금지'],
    exc:'습기 있는 옷 투입 금지'
  },
  {
    name:'폐의약품', aliases:['약','폐의약품','알약','시럽','안약','연고'],
    cat:'특수수거', emoji:'💊', where:'약국 또는 보건소 폐의약품 수거함',
    steps:['약국·보건소 전용 수거함에 배출'],
    tips:['싱크대·변기 투기 금지 (수질 오염)','약 봉투째 투입 OK'],
    exc:null
  },
  {
    name:'폐식용유', aliases:['폐식용유','식용유','튀김기름','기름'],
    cat:'특수수거', emoji:'🫙', where:'폐식용유 수거함 (주민센터·아파트)',
    steps:['식힌 후 밀봉','전용 수거함 배출'],
    tips:['싱크대 버리면 하수도 막힘·수질오염','소량은 키친타올 흡수 후 일반쓰레기'],
    exc:null
  },
  {
    name:'우산', aliases:['우산','장우산','양산','접이식우산'],
    cat:'특수수거', emoji:'☂️', where:'우산 수거함 또는 대형폐기물',
    steps:['살(금속) 분리 → 금속류','천(비닐) → 비닐류','불가능하면 대형폐기물'],
    tips:['아파트 단지 우산 수거 캠페인 참여 가능'],
    exc:null
  },
  {
    name:'대형 가구·가전', aliases:['소파','냉장고','세탁기','TV','에어컨','가구','매트리스'],
    cat:'특수수거', emoji:'🛋️', where:'대형폐기물 스티커 부착 후 배출',
    steps:['주민센터 또는 지자체 앱에서 대형폐기물 신고','수수료 납부 후 스티커 받기','지정 장소에 배출'],
    tips:['지자체별로 신고 방법·요금 다름','무상 수거 서비스 있는 브랜드도 있음'],
    exc:null
  },
];

/* ═══════════════════════════════════════════════════════════════
   자주 찾는 품목 (탭 상단 빠른 접근)
═══════════════════════════════════════════════════════════════ */
const POPULAR = [
  '치킨박스','아이스팩','배달 용기','택배박스',
  '빨대','페트병','영수증','스티로폼 박스',
  '건전지','헌옷','기저귀','마스크',
];

/* ═══════════════════════════════════════════════════════════════
   유틸
═══════════════════════════════════════════════════════════════ */
const norm = s => s.replace(/\s/g,'').toLowerCase();

function score(item, q){
  if (!q) return 0;
  const n = norm(item.name), a = item.aliases.map(norm);
  if (n === q) return 100;
  if (n.startsWith(q)) return 80;
  if (n.includes(q)) return 60;
  if (a.some(x => x === q)) return 75;
  if (a.some(x => x.startsWith(q))) return 55;
  if (a.some(x => x.includes(q))) return 40;
  return 0;
}

function searchItems(query){
  const q = norm(query);
  if (!q) return [];
  return ITEMS
    .map(item => ({ item, s: score(item, q) }))
    .filter(({ s }) => s > 0)
    .sort((a, b) => b.s - a.s)
    .map(({ item }) => item);
}

/* ═══════════════════════════════════════════════════════════════
   최근 검색어
═══════════════════════════════════════════════════════════════ */
const RECENT_KEY = 'recycle_recent_v1';
const MAX_RECENT = 8;

function getRecent(){ try { return JSON.parse(localStorage.getItem(RECENT_KEY)) || []; } catch { return []; } }
function saveRecent(query){
  let list = getRecent().filter(r => r !== query);
  list.unshift(query);
  if (list.length > MAX_RECENT) list = list.slice(0, MAX_RECENT);
  localStorage.setItem(RECENT_KEY, JSON.stringify(list));
}
function clearRecent(){ localStorage.removeItem(RECENT_KEY); }

function renderRecent(){
  const list = getRecent();
  const section = document.getElementById('recentSection');
  const chips   = document.getElementById('recentChips');
  if (!list.length){ section.hidden = true; return; }
  section.hidden = false;
  chips.innerHTML = list.map(r =>
    `<button class="chip recent" data-query="${r}">🕐 ${r}</button>`
  ).join('');
}

/* ═══════════════════════════════════════════════════════════════
   렌더
═══════════════════════════════════════════════════════════════ */
function cardHTML(item, idx){
  return `
  <div class="item-card" data-idx="${idx}" tabindex="0" role="listitem"
       aria-label="${item.name} — ${item.cat}">
    <div class="item-emoji" aria-hidden="true">${item.emoji}</div>
    <div class="item-name">${item.name}</div>
    <span class="item-badge badge-${item.cat}">${item.cat}</span>
    <div class="item-where">${item.where.split('(')[0].trim()}</div>
  </div>`;
}

function renderGrid(items){
  const grid  = document.getElementById('itemGrid');
  const empty = document.getElementById('emptyMsg');
  const count = document.getElementById('resultCount');
  if (!items.length){
    grid.innerHTML = '';
    empty.hidden = false;
    count.hidden = true;
    return;
  }
  empty.hidden = true;
  grid.innerHTML = items.map((item, i) => cardHTML(item, ITEMS.indexOf(item))).join('');
  if (currentQuery){
    count.textContent = `검색 결과 ${items.length}개`;
    count.hidden = false;
  } else {
    count.hidden = true;
  }
}

/* ═══════════════════════════════════════════════════════════════
   모달
═══════════════════════════════════════════════════════════════ */
let currentModalItem = null;

function openModal(item){
  currentModalItem = item;
  const steps = item.steps.map(s => `<li>${s}</li>`).join('');
  const tips  = item.tips?.length
    ? `<div class="modal-section"><h3>꼭 알아두기</h3><ul class="modal-tips">${item.tips.map(t=>`<li>${t}</li>`).join('')}</ul></div>`
    : '';
  const exc = item.exc
    ? `<div class="modal-section"><div class="modal-exc">${item.exc}</div></div>`
    : '';
  document.getElementById('modalContent').innerHTML = `
    <span class="modal-emoji" aria-hidden="true">${item.emoji}</span>
    <div class="modal-name">${item.name}</div>
    <div class="modal-badge-wrap"><span class="item-badge badge-${item.cat}">${item.cat}</span></div>
    <div class="modal-section">
      <h3>버리는 곳</h3>
      <div class="modal-where">${item.where}</div>
    </div>
    <div class="modal-section">
      <h3>버리는 방법</h3>
      <ol class="modal-steps">${steps}</ol>
    </div>
    ${tips}${exc}`;
  document.getElementById('detailModal').showModal();
  document.getElementById('modalContent').focus();
}

/* ═══════════════════════════════════════════════════════════════
   공유
═══════════════════════════════════════════════════════════════ */
async function shareItem(item){
  const text = `♻️ ${item.name} → ${item.where}\n${item.steps.join(' → ')}\n\nhttps://junyoung9394.github.io/recycle/`;
  if (navigator.share){
    try { await navigator.share({ title: `분리수거: ${item.name}`, text }); return; } catch {}
  }
  try {
    await navigator.clipboard.writeText(text);
    alert('클립보드에 복사됐어요!');
  } catch {
    alert(text);
  }
}

/* ═══════════════════════════════════════════════════════════════
   PWA 설치
═══════════════════════════════════════════════════════════════ */
let deferredInstall = null;
window.addEventListener('beforeinstallprompt', e => {
  e.preventDefault();
  deferredInstall = e;
  document.getElementById('installBtn').hidden = false;
});
document.getElementById('installBtn').addEventListener('click', async () => {
  if (!deferredInstall) return;
  deferredInstall.prompt();
  await deferredInstall.userChoice;
  deferredInstall = null;
  document.getElementById('installBtn').hidden = true;
});

/* ═══════════════════════════════════════════════════════════════
   이벤트
═══════════════════════════════════════════════════════════════ */
const searchInput = document.getElementById('searchInput');
const clearBtn    = document.getElementById('clearBtn');
const catNav      = document.getElementById('catNav');
const grid        = document.getElementById('itemGrid');
const modal       = document.getElementById('detailModal');

let currentCat   = '전체';
let currentQuery = '';

function applySearch(query){
  currentQuery = query;
  clearBtn.hidden = !query;
  if (query){
    saveRecent(query);
    renderRecent();
    deactivateCats();
    renderGrid(searchItems(query));
  } else {
    renderGrid(currentCat === '전체' ? ITEMS : ITEMS.filter(i => i.cat === currentCat));
    activateCat(currentCat);
  }
}

function deactivateCats(){
  catNav.querySelectorAll('.cat').forEach(b => b.classList.remove('active'));
}
function activateCat(cat){
  catNav.querySelectorAll('.cat').forEach(b =>
    b.classList.toggle('active', b.dataset.cat === cat)
  );
}

let debounceTimer;
searchInput.addEventListener('input', () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => applySearch(searchInput.value.trim()), 120);
});
searchInput.addEventListener('search', () => applySearch(searchInput.value.trim()));

clearBtn.addEventListener('click', () => {
  searchInput.value = '';
  applySearch('');
  searchInput.focus();
});

catNav.addEventListener('click', e => {
  const btn = e.target.closest('.cat');
  if (!btn) return;
  searchInput.value = '';
  currentQuery = '';
  clearBtn.hidden = true;
  currentCat = btn.dataset.cat;
  activateCat(currentCat);
  renderGrid(currentCat === '전체' ? ITEMS : ITEMS.filter(i => i.cat === currentCat));
});

grid.addEventListener('click', e => {
  const card = e.target.closest('.item-card');
  if (card) openModal(ITEMS[+card.dataset.idx]);
});
grid.addEventListener('keydown', e => {
  if (e.key === 'Enter' || e.key === ' '){
    const card = e.target.closest('.item-card');
    if (card){ e.preventDefault(); openModal(ITEMS[+card.dataset.idx]); }
  }
});

document.getElementById('modalClose').addEventListener('click', () => modal.close());
modal.addEventListener('click', e => { if (e.target === modal) modal.close(); });
document.getElementById('shareBtn').addEventListener('click', () => {
  if (currentModalItem) shareItem(currentModalItem);
});

/* Popular chips */
document.getElementById('popularChips').innerHTML =
  POPULAR.map(name => `<button class="chip" data-query="${name}">${name}</button>`).join('');

document.getElementById('popularChips').addEventListener('click', e => {
  const chip = e.target.closest('.chip');
  if (!chip) return;
  searchInput.value = chip.dataset.query;
  applySearch(chip.dataset.query);
  window.scrollTo({ top: 0, behavior: 'smooth' });
});

/* Recent chips */
document.getElementById('recentChips').addEventListener('click', e => {
  const chip = e.target.closest('.chip');
  if (!chip) return;
  searchInput.value = chip.dataset.query;
  applySearch(chip.dataset.query);
  window.scrollTo({ top: 0, behavior: 'smooth' });
});
document.getElementById('clearRecentBtn').addEventListener('click', () => {
  clearRecent();
  renderRecent();
});

/* ═══════════════════════════════════════════════════════════════
   초기화
═══════════════════════════════════════════════════════════════ */
renderGrid(ITEMS);
renderRecent();

/* PWA */
if ('serviceWorker' in navigator){
  navigator.serviceWorker.register('sw.js').catch(() => {});
}
