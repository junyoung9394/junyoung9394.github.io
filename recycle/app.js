/* ── 분리수거 데이터 ──────────────────────────────────────────── */
const ITEMS = [
  /* 종이류 */
  {
    name:"택배박스", aliases:["택배","상자","종이박스","박스"],
    cat:"종이류", emoji:"📦", where:"종이류 수거함",
    steps:["테이프·스티커·송장 모두 제거","납작하게 눌러 접기","종이류 수거함에 배출"],
    tips:["송장 스티커에 개인정보가 있으니 제거 필수","아주 작은 박스(30cm 이하)는 끈으로 묶어서"],
    exc:"기름·음식물에 심하게 오염된 경우 일반쓰레기"
  },
  {
    name:"신문·잡지", aliases:["신문","잡지","책","카탈로그","전단지","광고지"],
    cat:"종이류", emoji:"📰", where:"종이류 수거함",
    steps:["여러 장 묶어서 종이류 배출"],
    tips:["스프링 제본 잡지는 스프링만 분리해 금속류로"],
    exc:null
  },
  {
    name:"종이컵", aliases:["일회용컵","커피컵","테이크아웃컵"],
    cat:"종이류", emoji:"🥤", where:"종이류 수거함",
    steps:["내용물 비우기","물로 간단히 헹구기","종이류 배출 (일부 지역 별도 수거함)"],
    tips:["일부 주민센터·카페에 종이컵 전용 수거함 있음"],
    exc:"코팅이 많이 된 방수 종이컵은 일반쓰레기"
  },
  {
    name:"우유팩·두유팩", aliases:["우유팩","두유팩","쥬스팩","종이팩"],
    cat:"종이류", emoji:"🥛", where:"종이팩 전용 수거함 (없으면 종이류)",
    steps:["깨끗이 씻기","가위로 잘라 펼치기","건조 후 종이팩 전용 수거함에"],
    tips:["세척·건조 잘 해야 재활용 가능","전용 수거함 없으면 묶어서 종이류에"],
    exc:null
  },
  {
    name:"영수증", aliases:["영수증","감열지","카드영수증"],
    cat:"일반쓰레기", emoji:"🧾", where:"종량제 봉투 (일반쓰레기)",
    steps:["종량제 봉투에 버리기"],
    tips:["감열지(열 인쇄 영수증)는 BPA 코팅으로 재활용 불가"],
    exc:null
  },
  {
    name:"치킨박스", aliases:["치킨박스","피자박스","기름박스"],
    cat:"종이류", emoji:"🍗", where:"상태에 따라 다름",
    steps:["기름 없는 부분(뚜껑 안쪽 등)은 종이류","기름 묻은 부분은 뜯어서 일반쓰레기"],
    tips:["반반으로 나눠 분리 가능","아예 기름이 많으면 통째로 일반쓰레기"],
    exc:"기름·음식물 심하게 오염 시 일반쓰레기"
  },

  /* 플라스틱류 */
  {
    name:"페트병(음료)", aliases:["페트병","생수병","콜라병","음료병","플라스틱병","PET"],
    cat:"플라스틱류", emoji:"🍶", where:"투명 페트병 전용 수거함 (없으면 플라스틱류)",
    steps:["내용물 완전히 비우기","라벨 제거","찌그러뜨려 뚜껑 닫기","투명 페트 전용 수거함 또는 플라스틱류"],
    tips:["투명 페트병은 별도 분리 필수 (2020년 의무화)","색깔 있는 페트병은 일반 플라스틱류"],
    exc:null
  },
  {
    name:"배달 용기·반찬통", aliases:["배달용기","반찬통","플라스틱용기","배달","테이크아웃"],
    cat:"플라스틱류", emoji:"🍱", where:"플라스틱류 수거함",
    steps:["음식물 완전히 제거","물로 헹궈 기름기 제거","뚜껑·용기 따로 플라스틱류 배출"],
    tips:["뚜껑 재질이 다른 경우 재질별로 분리","검은 플라스틱(PP·PS 표시)도 플라스틱류 OK"],
    exc:"심하게 오염되어 세척 불가 시 일반쓰레기"
  },
  {
    name:"요구르트병·플라스틱 뚜껑", aliases:["요구르트병","야쿠르트","플라스틱뚜껑","뚜껑"],
    cat:"플라스틱류", emoji:"🧃", where:"플라스틱류 수거함",
    steps:["헹군 후 플라스틱류 배출"],
    tips:["작은 뚜껑류도 모아서 함께 배출 가능"],
    exc:null
  },
  {
    name:"샴푸·세제통", aliases:["샴푸","린스","바디워시","세제통","주방세제","화장품통"],
    cat:"플라스틱류", emoji:"🧴", where:"플라스틱류 수거함",
    steps:["내용물 완전히 비우기","물로 헹구기","펌프·뚜껑 분리","플라스틱류 배출"],
    tips:["펌프 내부 스프링 있으면 금속류로 분리"],
    exc:null
  },
  {
    name:"빨대", aliases:["빨대","플라스틱빨대"],
    cat:"일반쓰레기", emoji:"🥤", where:"종량제 봉투 (일반쓰레기)",
    steps:["종량제 봉투에 버리기"],
    tips:["너무 작아 선별라인에서 선별 불가","종이빨대도 혹시 코팅 있으면 일반쓰레기"],
    exc:null
  },
  {
    name:"플라스틱 장난감", aliases:["장난감","플라스틱장난감","레고","피규어"],
    cat:"일반쓰레기", emoji:"🧸", where:"종량제 봉투 또는 대형폐기물",
    steps:["작은 것은 종량제 봉투","큰 것은 대형폐기물 신고"],
    tips:["배터리 있으면 분리해 특수수거"],
    exc:null
  },

  /* 유리류 */
  {
    name:"소주병·맥주병", aliases:["소주병","맥주병","공병","유리병"],
    cat:"유리류", emoji:"🍶", where:"빈용기 보증금 반환 또는 유리류",
    steps:["편의점·마트에 공병 반환하면 보증금 돌려받음","반환 불가 시 유리류 수거함"],
    tips:["소주병 100원, 맥주병 130원 보증금","깨진 병은 신문지에 싸서 '유리 조심'표시 후 일반쓰레기"],
    exc:null
  },
  {
    name:"음료 유리병·잼병", aliases:["잼병","유리병","음료유리병"],
    cat:"유리류", emoji:"🫙", where:"유리류 수거함",
    steps:["내용물 비우기","뚜껑(금속) 따로 분리해 금속류","유리병만 유리류 배출"],
    tips:["깨지지 않도록 조심","깨진 유리는 신문지 감싸서 일반쓰레기"],
    exc:null
  },
  {
    name:"거울·판유리·강화유리", aliases:["거울","창문유리","강화유리","깨진유리"],
    cat:"일반쓰레기", emoji:"🪞", where:"종량제 봉투 또는 대형폐기물",
    steps:["신문지 등으로 감싸기","'유리 조심' 메모 후 종량제 봉투 또는 대형폐기물"],
    tips:["강화유리·내열유리는 유리류 선별 불가 → 일반쓰레기"],
    exc:null
  },

  /* 금속류 */
  {
    name:"캔(음료·통조림)", aliases:["캔","음료캔","통조림","철캔","알루미늄캔","맥주캔"],
    cat:"금속류", emoji:"🥫", where:"금속류 수거함",
    steps:["내용물 완전히 비우기","물로 헹구기","찌그러뜨려 금속류 배출"],
    tips:["알루미늄·철 캔 모두 금속류 OK","뚜껑을 캔 안에 눌러 넣어 배출하면 안전"],
    exc:null
  },
  {
    name:"부탄가스·스프레이 캔", aliases:["부탄가스","에어로졸","스프레이","캔"],
    cat:"금속류", emoji:"🧯", where:"금속류 수거함 (반드시 구멍 뚫기)",
    steps:["내용물 다 쓰기","야외 통풍 장소에서 송곳·캔따개로 구멍 뚫기","금속류 배출"],
    tips:["불 근처에서 구멍 뚫기 절대 금지","내용물 남은 상태로 버리면 폭발 위험"],
    exc:"내용물 남아있으면 배출 전 반드시 소진"
  },
  {
    name:"알루미늄 호일", aliases:["호일","알루미늄호일","은박지","은박"],
    cat:"금속류", emoji:"✨", where:"금속류 수거함",
    steps:["음식물 닦아내기","구겨서 금속류 배출"],
    tips:["너무 얇고 더러우면 일반쓰레기도 무방"],
    exc:null
  },
  {
    name:"냄비·프라이팬", aliases:["냄비","프라이팬","철솥","냄비뚜껑"],
    cat:"금속류", emoji:"🍳", where:"금속류 수거함 또는 대형폐기물",
    steps:["작은 것은 금속류 수거함","큰 것은 대형폐기물 신고"],
    tips:["테프론 코팅 프라이팬도 금속류 OK"],
    exc:null
  },

  /* 비닐류 */
  {
    name:"비닐봉지·쇼핑백", aliases:["비닐봉지","비닐","쇼핑백","마트봉투","검정봉지"],
    cat:"비닐류", emoji:"🛍️", where:"비닐류 수거함",
    steps:["내용물 제거","이물질 털어내기","비닐류 수거함"],
    tips:["오염 심하면 일반쓰레기","여러 장 겹쳐 배출 가능"],
    exc:"기름·음식물 오염 심하면 일반쓰레기"
  },
  {
    name:"랩·뽁뽁이(에어캡)", aliases:["랩","비닐랩","에어캡","뽁뽁이","버블랩","완충재"],
    cat:"비닐류", emoji:"📦", where:"비닐류 수거함",
    steps:["이물질 제거","비닐류 수거함"],
    tips:["뽁뽁이 공기 빼고 접어서 배출"],
    exc:null
  },
  {
    name:"아이스팩", aliases:["아이스팩","얼음팩","보냉팩","냉매"],
    cat:"비닐류", emoji:"🧊", where:"젤 타입·물 타입 구분",
    steps:["물 타입: 물 싱크대에 버리고 비닐 비닐류","젤 타입: 뜯지 않고 통째로 일반쓰레기"],
    tips:["젤은 환경부 규정상 일반쓰레기 (미세플라스틱 우려)","일부 마트·쿠팡에 반납하면 재사용"],
    exc:"젤 타입은 통째로 일반쓰레기"
  },
  {
    name:"라면·과자 봉지", aliases:["라면봉지","과자봉지","스낵봉지","봉지"],
    cat:"비닐류", emoji:"🍜", where:"비닐류 수거함",
    steps:["내용물 완전히 비우기","비닐류 수거함"],
    tips:["기름·소스 오염 없으면 OK"],
    exc:null
  },
  {
    name:"지퍼백·도시락 포장 비닐", aliases:["지퍼백","지프락","비닐팩","포장비닐"],
    cat:"비닐류", emoji:"🤐", where:"비닐류 수거함",
    steps:["내용물 제거","헹군 뒤 비닐류 배출"],
    tips:["지퍼 부분 함께 배출 OK"],
    exc:null
  },

  /* 스티로폼 */
  {
    name:"스티로폼 박스", aliases:["스티로폼","스티로폼박스","발포"],
    cat:"스티로폼", emoji:"📫", where:"스티로폼 수거함",
    steps:["테이프·라벨 제거","이물질 제거","스티로폼 수거함"],
    tips:["오염 심하면 일반쓰레기","부서진 조각도 모아서 배출"],
    exc:"기름 오염 심하면 일반쓰레기"
  },
  {
    name:"컵라면 용기", aliases:["컵라면","컵용기","스티로폼컵"],
    cat:"스티로폼", emoji:"🍜", where:"스티로폼 수거함",
    steps:["내용물·국물 완전히 제거","물로 헹구기","스티로폼 수거함"],
    tips:["용기 라벨(종이) 제거 후 배출"],
    exc:null
  },
  {
    name:"완충재(흰 스티로폼)", aliases:["완충재","포장재","스티로폼완충"],
    cat:"스티로폼", emoji:"🏠", where:"스티로폼 수거함",
    steps:["테이프 제거","조각 모아서 스티로폼 수거함"],
    tips:["부서진 조각은 비닐봉지에 담아 배출해도 OK"],
    exc:null
  },

  /* 음식물 */
  {
    name:"채소·과일 껍질", aliases:["채소껍질","과일껍질","야채","양파껍질","귤껍질"],
    cat:"음식물", emoji:"🥦", where:"음식물 쓰레기통",
    steps:["음식물 쓰레기봉투에 배출"],
    tips:["파뿌리·대파잎 등 대부분 음식물 OK"],
    exc:null
  },
  {
    name:"뼈다귀·조개껍데기", aliases:["뼈","갈비뼈","조개껍질","홍합껍질","조개"],
    cat:"일반쓰레기", emoji:"🦴", where:"종량제 봉투 (일반쓰레기)",
    steps:["건조 후 종량제 봉투"],
    tips:["딱딱한 뼈·껍데기류는 분쇄·퇴비 불가로 일반쓰레기"],
    exc:null
  },
  {
    name:"달걀 껍데기", aliases:["달걀껍데기","계란껍데기"],
    cat:"일반쓰레기", emoji:"🥚", where:"종량제 봉투 (일반쓰레기)",
    steps:["종량제 봉투에 버리기"],
    tips:["달걀 껍데기는 음식물이 아닌 일반쓰레기"],
    exc:null
  },
  {
    name:"커피 찌꺼기", aliases:["커피찌꺼기","커피가루","원두찌꺼기"],
    cat:"음식물", emoji:"☕", where:"음식물 쓰레기통",
    steps:["음식물 쓰레기봉투에 배출"],
    tips:["탈취·제습제로 재활용 가능"],
    exc:null
  },
  {
    name:"과일 씨앗·복숭아씨", aliases:["씨앗","복숭아씨","살구씨","망고씨","아보카도씨"],
    cat:"일반쓰레기", emoji:"🍑", where:"종량제 봉투",
    steps:["종량제 봉투에 버리기"],
    tips:["딱딱한 씨앗류는 음식물이 아닌 일반쓰레기"],
    exc:null
  },

  /* 일반쓰레기 */
  {
    name:"마스크(KF·일회용)", aliases:["마스크","덴탈마스크","KF94","일회용마스크"],
    cat:"일반쓰레기", emoji:"😷", where:"종량제 봉투",
    steps:["끈 묶거나 접어서 종량제 봉투"],
    tips:["의료폐기물 우려로 일반쓰레기 처리"],
    exc:null
  },
  {
    name:"CD·DVD·블루레이", aliases:["CD","DVD","블루레이","디스크"],
    cat:"일반쓰레기", emoji:"💿", where:"종량제 봉투",
    steps:["종량제 봉투에 버리기"],
    tips:["케이스(플라스틱)는 플라스틱류로 분리"],
    exc:null
  },
  {
    name:"고무·실리콘", aliases:["고무","실리콘","고무장갑","실리콘용기"],
    cat:"일반쓰레기", emoji:"🧤", where:"종량제 봉투",
    steps:["종량제 봉투에 버리기"],
    tips:["실리콘 용기·고무 제품은 재활용 분류 어려움 → 일반쓰레기"],
    exc:null
  },
  {
    name:"도자기·사기그릇", aliases:["도자기","사기","그릇","깨진그릇","컵"],
    cat:"일반쓰레기", emoji:"🍽️", where:"종량제 봉투 또는 대형폐기물",
    steps:["신문지 등으로 감싸기","종량제 봉투에 배출 (작은 것)","큰 것은 대형폐기물 신고"],
    tips:["도자기는 유리류 선별 불가 → 일반쓰레기"],
    exc:null
  },
  {
    name:"스티커·포스트잇", aliases:["스티커","포스트잇","라벨지"],
    cat:"일반쓰레기", emoji:"📌", where:"종량제 봉투",
    steps:["종량제 봉투에 버리기"],
    tips:["접착제가 있어 종이류 재활용 불가"],
    exc:null
  },
  {
    name:"나무젓가락·이쑤시개", aliases:["나무젓가락","이쑤시개","나무수저"],
    cat:"일반쓰레기", emoji:"🥢", where:"종량제 봉투",
    steps:["종량제 봉투에 버리기"],
    tips:["소량은 일반쓰레기 OK"],
    exc:null
  },
  {
    name:"담배꽁초", aliases:["담배꽁초","담배","꽁초"],
    cat:"일반쓰레기", emoji:"🚬", where:"종량제 봉투",
    steps:["물에 확실히 끄기","종량제 봉투에 버리기"],
    tips:["꽁초는 유해물질 포함 → 일반쓰레기"],
    exc:null
  },

  /* 특수수거 */
  {
    name:"건전지·충전지", aliases:["건전지","배터리","충전지","AA배터리","리튬배터리"],
    cat:"특수수거", emoji:"🔋", where:"건전지 전용 수거함 (마트·주민센터·편의점)",
    steps:["사용 완료 후 전용 수거함에 배출","편의점·마트·주민센터 수거함 이용"],
    tips:["리튬 배터리(노트북·스마트폰) 팽창 시 즉시 격리·신고","양극 절연테이프 붙여 보관"],
    exc:null
  },
  {
    name:"형광등·전구", aliases:["형광등","전구","LED","할로겐","CFL"],
    cat:"특수수거", emoji:"💡", where:"형광등 전용 수거함 (주민센터·마트)",
    steps:["깨지지 않게 보관","전용 수거함에 배출"],
    tips:["깨진 형광등은 비닐백에 담아 '파손 형광등' 표기 후 배출","LED 전구도 전용 수거함 이용"],
    exc:null
  },
  {
    name:"소형 전자기기(스마트폰·태블릿)", aliases:["스마트폰","핸드폰","태블릿","노트북","전자기기"],
    cat:"특수수거", emoji:"📱", where:"전자제품 수거함 (주민센터·대형마트) 또는 제조사 회수",
    steps:["개인정보 초기화 필수","배터리 분리 가능하면 분리","전자제품 수거함 또는 제조사 반납"],
    tips:["삼성·LG·애플 등 제조사 자체 수거 프로그램 활용","공인 수리점에서도 수거 가능"],
    exc:null
  },
  {
    name:"헌옷·신발", aliases:["헌옷","중고옷","신발","의류","옷"],
    cat:"특수수거", emoji:"👕", where:"의류 수거함 (아파트 단지·동네 헌옷 수거함)",
    steps:["깨끗이 세탁 후 비닐봉투에 담기","의류 수거함에 투입"],
    tips:["젖거나 심하게 오염된 옷은 일반쓰레기","중고 상태 좋으면 당근마켓·아름다운가게 기부"],
    exc:"습기 있는 옷 수거함 투입 금지"
  },
  {
    name:"폐의약품", aliases:["약","폐의약품","알약","시럽","안약"],
    cat:"특수수거", emoji:"💊", where:"약국 또는 보건소 폐의약품 수거함",
    steps:["약국·보건소에 가져가기","전용 수거함에 배출"],
    tips:["변기·싱크대에 버리면 수질 오염","약 봉투째 투입 OK"],
    exc:null
  },
  {
    name:"식용유·폐식용유", aliases:["폐식용유","식용유","튀김기름","기름"],
    cat:"특수수거", emoji:"🫙", where:"폐식용유 수거함 (주민센터·아파트)",
    steps:["식힌 후 밀봉","폐식용유 전용 수거함에 배출"],
    tips:["싱크대 버리면 하수도 막힘·수질 오염","소량은 종이에 흡수시켜 일반쓰레기"],
    exc:null
  },
  {
    name:"페인트통·시너", aliases:["페인트","시너","래커","스프레이페인트"],
    cat:"특수수거", emoji:"🪣", where:"대형폐기물 또는 지자체 지정 배출",
    steps:["내용물 완전히 사용하거나 응고","지자체 지정 수거 방법 확인"],
    tips:["하수도·쓰레기통 투기 금지","가정용 소량은 뚜껑 열어 완전 건조 후 일반쓰레기"],
    exc:null
  },
  {
    name:"우산", aliases:["우산","우비","양우산","장우산"],
    cat:"특수수거", emoji:"☂️", where:"우산 수거함 또는 대형폐기물",
    steps:["살 분리 가능하면 금속류","나머지 플라스틱·비닐 분리","불가능하면 대형폐기물"],
    tips:["우산 수거 캠페인 참여 시 기부 가능"],
    exc:null
  },
];

/* ── 검색 헬퍼 ──────────────────────────────────────────────── */
function normalize(s){ return s.replace(/\s/g,'').toLowerCase(); }

function search(query){
  const q = normalize(query);
  if (!q) return [];
  return ITEMS.filter(it =>
    normalize(it.name).includes(q) ||
    it.aliases.some(a => normalize(a).includes(q))
  );
}

/* ── 카드 렌더 ──────────────────────────────────────────────── */
function cardHTML(item){
  return `
    <div class="item-card" data-id="${ITEMS.indexOf(item)}" tabindex="0" role="button" aria-label="${item.name} 버리는 법">
      <div class="item-emoji">${item.emoji}</div>
      <div class="item-name">${item.name}</div>
      <span class="item-badge badge-${item.cat}">${item.cat}</span>
      <div class="item-where">${item.where.split('(')[0].trim()}</div>
    </div>`;
}

function renderGrid(items){
  const grid = document.getElementById('itemGrid');
  const empty = document.getElementById('emptyMsg');
  if (!items.length){ grid.innerHTML=''; empty.hidden=false; return; }
  empty.hidden=true;
  grid.innerHTML = items.map(cardHTML).join('');
}

/* ── 모달 ───────────────────────────────────────────────────── */
function openModal(item){
  const stepsHTML = item.steps.map(s=>`<li>${s}</li>`).join('');
  const tipsHTML = item.tips.length
    ? `<div class="modal-section"><h3>알아두면 좋은 팁</h3><ul class="modal-tips">${item.tips.map(t=>`<li>${t}</li>`).join('')}</ul></div>`
    : '';
  const excHTML = item.exc
    ? `<div class="modal-section"><div class="modal-exc">${item.exc}</div></div>`
    : '';
  document.getElementById('modalContent').innerHTML = `
    <span class="modal-emoji">${item.emoji}</span>
    <div class="modal-name">${item.name}</div>
    <div class="modal-badge"><span class="item-badge badge-${item.cat}">${item.cat}</span></div>
    <div class="modal-section">
      <h3>버리는 곳</h3>
      <div class="modal-where">${item.where}</div>
    </div>
    <div class="modal-section">
      <h3>버리는 방법</h3>
      <ol class="modal-steps">${stepsHTML}</ol>
    </div>
    ${tipsHTML}${excHTML}`;
  document.getElementById('detailModal').showModal();
}

/* ── 이벤트 연결 ────────────────────────────────────────────── */
const searchInput = document.getElementById('searchInput');
const clearBtn    = document.getElementById('clearBtn');
const catNav      = document.getElementById('catNav');
const modal       = document.getElementById('detailModal');
const grid        = document.getElementById('itemGrid');

let currentCat = '전체';

function showByCat(cat){
  const items = cat === '전체' ? ITEMS : ITEMS.filter(i=>i.cat===cat);
  renderGrid(items);
}

searchInput.addEventListener('input', ()=>{
  const q = searchInput.value.trim();
  clearBtn.hidden = !q;
  if (q){
    catNav.querySelectorAll('.cat').forEach(b=>b.classList.remove('active'));
    renderGrid(search(q));
  } else {
    catNav.querySelector(`[data-cat="${currentCat}"]`).classList.add('active');
    showByCat(currentCat);
  }
});

clearBtn.addEventListener('click', ()=>{
  searchInput.value = '';
  clearBtn.hidden = true;
  searchInput.focus();
  showByCat(currentCat);
  catNav.querySelector(`[data-cat="${currentCat}"]`).classList.add('active');
});

catNav.addEventListener('click', e=>{
  const btn = e.target.closest('.cat');
  if (!btn) return;
  catNav.querySelectorAll('.cat').forEach(b=>b.classList.remove('active'));
  btn.classList.add('active');
  currentCat = btn.dataset.cat;
  searchInput.value = '';
  clearBtn.hidden = true;
  showByCat(currentCat);
});

grid.addEventListener('click', e=>{
  const card = e.target.closest('.item-card');
  if (!card) return;
  openModal(ITEMS[+card.dataset.id]);
});
grid.addEventListener('keydown', e=>{
  if (e.key==='Enter'||e.key===' '){
    const card = e.target.closest('.item-card');
    if (card){ e.preventDefault(); openModal(ITEMS[+card.dataset.id]); }
  }
});

document.getElementById('modalClose').addEventListener('click', ()=>modal.close());
modal.addEventListener('click', e=>{ if (e.target===modal) modal.close(); });

/* ── 초기 렌더 ──────────────────────────────────────────────── */
showByCat('전체');

/* ── PWA 서비스워커 등록 ─────────────────────────────────────── */
if ('serviceWorker' in navigator){
  navigator.serviceWorker.register('sw.js').catch(()=>{});
}
