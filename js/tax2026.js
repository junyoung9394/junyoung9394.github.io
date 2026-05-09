// 2026년 한국 소득세 + 4대보험 계산 엔진
// 세율 기준: 소득세법 제55조 (2025년 개정 반영)
// 4대보험 요율: 2025년 확정 기준 (2026년 변경 시 하단 상수 수정)

const TAX = {
  // ── 국민연금 월 기준소득월액 상한 (2025년 기준, 2026년 고시 확인 필요)
  NP_CAP: 6_170_000,

  // ── 4대보험 요율 (근로자 부담분)
  RATES: {
    nationalPension:  0.045,   // 9% 중 근로자 4.5%
    healthInsurance:  0.03545, // 7.09% 중 근로자 3.545%
    longTermCare:     0.1295,  // 건강보험료의 12.95%
    employment:       0.009,   // 1.8% 중 근로자 0.9%
  },

  // ── 근로소득공제 (소득세법 제47조)
  earnedIncomeDeduction(annual) {
    if (annual <= 5_000_000)   return annual * 0.70;
    if (annual <= 15_000_000)  return 3_500_000  + (annual - 5_000_000)   * 0.40;
    if (annual <= 45_000_000)  return 7_500_000  + (annual - 15_000_000)  * 0.15;
    if (annual <= 100_000_000) return 12_000_000 + (annual - 45_000_000)  * 0.05;
    return 14_750_000;
  },

  // ── 종합소득세율 (소득세법 제55조, 2025 개정)
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

  // ── 최저임금 계산 (2026년 기준 — 2025년 고시 후 업데이트 필요)
  MINIMUM_WAGE_2026: 10_030, // 원/시간 (2025년 기준; 2026년 결정 후 수정)

  calcMinimumWage(hoursPerWeek = 40) {
    const hourly  = TAX.MINIMUM_WAGE_2026;
    const weekly  = hourly * hoursPerWeek;
    // 주휴수당: 주 15시간 이상 근무 시 발생
    const weeklyAllowance = hoursPerWeek >= 15 ? hourly * (hoursPerWeek / 40) * 8 : 0;
    const monthly = Math.round((weekly + weeklyAllowance) * (365 / 7 / 12));
    return { hourly, weekly: Math.round(weekly), weeklyAllowance: Math.round(weeklyAllowance), monthly };
  },
};
