// 한국 소득세 + 4대보험 계산 엔진 (연도별 기준)
// 연도별 요율은 YEARS에서 관리 — 새 연도 고시 시 항목만 추가하면 됨
//
// 2026: 국민연금 9.5%(근로자 4.75%), 건강보험 7.19%(3.595%), 장기요양 건보료의 13.14%,
//       고용보험 근로자 0.9%, 국민연금 기준소득월액 상한 659만원(2026.7~2027.6), 최저시급 10,320원
// 2027: 국민연금 10%(근로자 5%, 연금개혁 일정), 건강보험 7.19% 동결(2026.9 건정심),
//       최저시급 10,700원(고용노동부 고시 제2026-60호)
//       ※ 2027 장기요양보험료율은 미발표 — 발표 전까지 2026 비율(13.14%) 적용

const TAX_YEARS = {
  2026: {
    minimumWage: 10_320,
    prevMinimumWage: 10_030,
    npCap: 6_590_000,
    rates: {
      nationalPension: 0.0475,
      healthInsurance: 0.03595,
      longTermCare:    0.1314,
      employment:      0.009,
    },
    notes: [],
  },
  2027: {
    minimumWage: 10_700,
    prevMinimumWage: 10_320,
    npCap: 6_590_000,
    rates: {
      nationalPension: 0.05,
      healthInsurance: 0.03595,
      longTermCare:    0.1314,
      employment:      0.009,
    },
    notes: ['2027년 장기요양보험료율은 발표 전이라 2026년 비율(건보료의 13.14%)을 적용했습니다.'],
  },
};

const TAX = {
  YEARS: TAX_YEARS,
  // 1월 1일부터 자동으로 새 연도 기준이 기본값이 됨
  year: (() => {
    const y = new Date().getFullYear();
    const keys = Object.keys(TAX_YEARS).map(Number);
    return Math.min(Math.max(y, Math.min(...keys)), Math.max(...keys));
  })(),

  setYear(y) { if (TAX_YEARS[y]) TAX.year = Number(y); },
  get cfg()     { return TAX_YEARS[TAX.year]; },
  get RATES()   { return TAX.cfg.rates; },
  get NP_CAP()  { return TAX.cfg.npCap; },
  get MINIMUM_WAGE() { return TAX.cfg.minimumWage; },

  // ── 근로소득공제 (소득세법 제47조)
  earnedIncomeDeduction(annual) {
    if (annual <= 5_000_000)   return annual * 0.70;
    if (annual <= 15_000_000)  return 3_500_000  + (annual - 5_000_000)   * 0.40;
    if (annual <= 45_000_000)  return 7_500_000  + (annual - 15_000_000)  * 0.15;
    if (annual <= 100_000_000) return 12_000_000 + (annual - 45_000_000)  * 0.05;
    return 14_750_000;
  },

  // ── 종합소득세율 (소득세법 제55조)
  incomeTax(taxableIncome) {
    const brackets = [
      { limit: 14_000_000,    rate: 0.06, base: 0           },
      { limit: 50_000_000,    rate: 0.15, base: 840_000     },
      { limit: 88_000_000,    rate: 0.24, base: 6_240_000   },
      { limit: 150_000_000,   rate: 0.35, base: 15_360_000  },
      { limit: 300_000_000,   rate: 0.38, base: 37_060_000  },
      { limit: 500_000_000,   rate: 0.40, base: 94_060_000  },
      { limit: 1_000_000_000, rate: 0.42, base: 174_060_000 },
      { limit: Infinity,      rate: 0.45, base: 384_060_000 },
    ];
    for (let i = 0; i < brackets.length; i++) {
      if (taxableIncome <= brackets[i].limit) {
        const prevLimit = i > 0 ? brackets[i - 1].limit : 0;
        return brackets[i].base + (taxableIncome - prevLimit) * brackets[i].rate;
      }
    }
  },

  // ── 근로소득세액공제 (산출세액 기준)
  earnedIncomeTaxCredit(calculatedTax) {
    if (calculatedTax <= 1_300_000) return calculatedTax * 0.55;
    return 715_000 + (calculatedTax - 1_300_000) * 0.30;
  },

  // ── 4대보험 계산 (월 급여 기준, 10원 단위 절사)
  calcInsurance(monthly) {
    const r = TAX.RATES;
    const np  = Math.floor(Math.min(monthly, TAX.NP_CAP) * r.nationalPension / 10) * 10;
    const hi  = Math.floor(monthly * r.healthInsurance / 10) * 10;
    const ltc = Math.floor(hi * r.longTermCare / 10) * 10;
    const ei  = Math.floor(monthly * r.employment / 10) * 10;
    return { nationalPension: np, healthInsurance: hi, longTermCare: ltc, employment: ei,
             total: np + hi + ltc + ei };
  },

  // ── 메인 계산 함수
  // annualGross: 연봉 (원)
  calculate(annualGross) {
    const monthly = Math.round(annualGross / 12);
    const ins = TAX.calcInsurance(monthly);

    // 과세표준 산정
    const earnedDeduction  = TAX.earnedIncomeDeduction(annualGross);
    const personalDeduction = 1_500_000; // 기본공제 (본인)
    const pensionDeduction  = ins.nationalPension * 12;
    const taxableIncome = Math.max(0, annualGross - earnedDeduction - personalDeduction - pensionDeduction);

    // 산출세액 → 결정세액
    const calculated       = TAX.incomeTax(taxableIncome);
    const earnedCredit     = TAX.earnedIncomeTaxCredit(calculated);
    const standardCredit   = 130_000;
    const annualIncomeTax  = Math.max(0, Math.floor((calculated - earnedCredit - standardCredit) / 10) * 10);
    const annualLocalTax   = Math.floor(annualIncomeTax * 0.10 / 10) * 10;

    const monthlyIncomeTax = Math.round(annualIncomeTax / 12);
    const monthlyLocalTax  = Math.round(annualLocalTax / 12);
    const totalTax         = monthlyIncomeTax + monthlyLocalTax;
    const totalDeduction   = ins.total + totalTax;
    const netMonthly       = monthly - totalDeduction;

    return {
      annualGross,
      monthly,
      netMonthly,
      netAnnual: netMonthly * 12,
      insurance: { ...ins, annualTotal: ins.total * 12 },
      tax: {
        monthlyIncomeTax,
        monthlyLocalTax,
        total: totalTax,
        annualTotal: (monthlyIncomeTax + monthlyLocalTax) * 12,
      },
      totalDeduction,
      effectiveRate: ((totalDeduction / monthly) * 100).toFixed(1),
    };
  },

  // ── 퇴직금 계산 (근로기준법 제34조)
  // averageMonthly: 3개월 평균 월급여 (원), yearsWorked: 근속연수 (소수점 가능)
  calcSeverance(averageMonthly, yearsWorked) {
    if (yearsWorked < 1) return 0;
    return Math.floor(averageMonthly * yearsWorked);
  },
};

// ── 연도 선택 토글: <div class="year-toggle" data-year-toggle></div> 에 렌더링
function mountYearToggle(onChange) {
  document.querySelectorAll('[data-year-toggle]').forEach(el => {
    el.setAttribute('role', 'tablist');
    el.innerHTML = Object.keys(TAX_YEARS).map(y =>
      `<button type="button" role="tab" data-year="${y}">${y}년 기준</button>`
    ).join('');
    const sync = () => el.querySelectorAll('button').forEach(b =>
      b.setAttribute('aria-selected', String(Number(b.dataset.year) === TAX.year)));
    el.addEventListener('click', e => {
      const b = e.target.closest('button[data-year]');
      if (!b) return;
      TAX.setYear(b.dataset.year);
      document.querySelectorAll('[data-year-toggle]').forEach(t => t.dispatchEvent(new Event('sync')));
      onChange(TAX.year);
    });
    el.addEventListener('sync', sync);
    sync();
  });
  const fromUrl = new URLSearchParams(location.search).get('year');
  if (fromUrl && TAX_YEARS[fromUrl]) {
    TAX.setYear(fromUrl);
    document.querySelectorAll('[data-year-toggle]').forEach(t => t.dispatchEvent(new Event('sync')));
  }
}
