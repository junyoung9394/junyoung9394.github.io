
// Front-end for mom: big UI, KST/LA times, Korean team names.
// Uses config.json.apiBase (Cloudflare Worker) to fetch data.
let deferredPrompt;
const installBtn = document.getElementById('installBtn');
const refreshBtn = document.getElementById('refreshBtn');
const fontBtn = document.getElementById('fontBtn');
const tabs = document.querySelectorAll('.tab');
const panels = document.querySelectorAll('.tabpanel');

const TEAM_KR = {
  "Los Angeles FC":"LAFC",
  "New England Revolution":"뉴잉글랜드 레벌루션",
  "FC Dallas":"댈러스",
  "San Diego FC":"샌디에이고 FC",
  "San Jose Earthquakes":"산호세 어스퀘이크스",
  "Real Salt Lake":"리얼 솔트레이크",
  "St. Louis CITY SC":"세인트루이스 시티",
  "Atlanta United FC":"애틀랜타 유나이티드",
  "Toronto FC":"토론토 FC",
  "Austin FC":"오스틴 FC",
  "Colorado Rapids":"콜로라도 래피즈",
  "Seattle Sounders":"시애틀 사운더스",
  "LA Galaxy":"LA 갤럭시"
};

function teamKR(name){ return TEAM_KR[name] || name; }
function fmtTZ(dt, tz, opts={}){
  const d = new Date(dt);
  return new Intl.DateTimeFormat('ko-KR', { timeZone: tz, weekday:'short', month:'numeric', day:'numeric', hour:'2-digit', minute:'2-digit', ...opts}).format(d);
}

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  installBtn.hidden = false;
});
installBtn?.addEventListener('click', async () => {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  await deferredPrompt.userChoice;
  deferredPrompt = null;
  installBtn.hidden = true;
});
refreshBtn?.addEventListener('click', () => { localStorage.setItem('forceReload', Date.now().toString()); location.reload(); });
fontBtn?.addEventListener('click', () => {
  const isXL = document.documentElement.classList.toggle('xl');
  fontBtn.setAttribute('aria-pressed', isXL ? 'true' : 'false');
  fontBtn.textContent = isXL ? '글씨 보통' : '글씨 크게';
});
tabs.forEach(t=> t.addEventListener('click', ()=>{
  tabs.forEach(x=> x.classList.remove('active'));
  panels.forEach(p=> p.hidden = true);
  t.classList.add('active');
  document.getElementById(t.dataset.tab).hidden = false;
}));

async function getConfig(){
  const res = await fetch('config.json', {cache:'no-store'});
  return await res.json();
}
async function api(path){
  const cfg = await getConfig();
  const url = cfg.apiBase.replace(/\/$/, '') + path;
  const res = await fetch(url, {cache:'no-store'});
  if (!res.ok) throw new Error('API 오류');
  return await res.json();
}

function makeICS(match){
  const dtStart = new Date(match.datetime);
  const dtEnd = new Date(dtStart.getTime() + 2*60*60*1000);
  const pad = (n)=> String(n).padStart(2,'0');
  function fmt(d){
    return d.getUTCFullYear() + pad(d.getUTCMonth()+1) + pad(d.getUTCDate()) + 'T' + pad(d.getUTCHours()) + pad(d.getUTCMinutes()) + '00Z';
  }
  const ics = [
    'BEGIN:VCALENDAR','VERSION:2.0','PRODID:lafc-mom',
    'BEGIN:VEVENT',
    `UID:${dtStart.getTime()}@lafc-mom`,
    `DTSTAMP:${fmt(new Date())}`,
    `DTSTART:${fmt(dtStart)}`,
    `DTEND:${fmt(dtEnd)}`,
    `SUMMARY:LAFC vs ${teamKR(match.opponent)} (${match.opponent})`,
    `LOCATION:${match.venue || ''}`,
    `DESCRIPTION:중계: ${match.watch || ''}`,
    'END:VEVENT','END:VCALENDAR'
  ].join('\r\n');
  const blob = new Blob([ics], {type:'text/calendar;charset=utf-8'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `LAFC_${(match.date||'').replaceAll('-','')}.ics`;
  a.click();
  URL.revokeObjectURL(url);
}
function exportAllICS(matches){
  const pad = (n)=> String(n).padStart(2,'0');
  function fmt(d){
    return d.getUTCFullYear() + pad(d.getUTCMonth()+1) + pad(d.getUTCDate()) + 'T' + pad(d.getUTCHours()) + pad(d.getUTCMinutes()) + '00Z';
  }
  const lines = ['BEGIN:VCALENDAR','VERSION:2.0','PRODID:lafc-mom'];
  matches.forEach(m=>{
    const dt = new Date(m.datetime);
    const dtEnd = new Date(dt.getTime() + 2*60*60*1000);
    lines.push('BEGIN:VEVENT');
    lines.push(`UID:${dt.getTime()}_${m.opponent}@lafc-mom`);
    lines.push(`DTSTAMP:${fmt(new Date())}`);
    lines.push(`DTSTART:${fmt(dt)}`);
    lines.push(`DTEND:${fmt(dtEnd)}`);
    lines.push(`SUMMARY:LAFC vs ${teamKR(m.opponent)} (${m.opponent})`);
    lines.push(`LOCATION:${m.venue||''}`);
    lines.push('END:VEVENT');
  });
  lines.push('END:VCALENDAR');
  const blob = new Blob([lines.join('\r\n')], {type:'text/calendar;charset=utf-8'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a'); a.href = url; a.download = 'LAFC_schedule.ics'; a.click(); URL.revokeObjectURL(url);
}

function withinLiveWindow(dt){
  const start = new Date(dt).getTime();
  const now = Date.now();
  const end = start + 130*60*1000; // 130min window
  return now >= start && now <= end;
}

function renderSchedule(matches){
  const ul = document.getElementById('schedule');
  const onlyHome = document.getElementById('onlyHome').checked;
  const onlySon = document.getElementById('onlySon').checked;
  const now = new Date();
  ul.innerHTML = '';
  matches
    .filter(m => new Date(m.datetime) >= new Date(now.getTime() - 3*60*60*1000))
    .filter(m => onlyHome ? m.home : true)
    .filter(m => onlySon ? (m.son_expected === true) : true)
    .forEach(m => {
      const li = document.createElement('li');
      const live = withinLiveWindow(m.datetime);
      li.innerHTML = `
        <div class="timeblock">
          <div><span class="tag">한국(KST)</span> ${fmtTZ(m.datetime, 'Asia/Seoul')}</div>
          <div><span class="tag">LA 현지</span> ${fmtTZ(m.datetime, 'America/Los_Angeles')}</div>
        </div>
        <div class="meta">
          <span class="badge">${m.home ? '홈' : '원정'}</span>
          ${live ? '<span class="badge live">LIVE</span>' : ''}
          <strong>LAFC vs ${teamKR(m.opponent)}</strong>
          <span class="muted">· ${m.venue || '-'}</span>
        </div>
        <div style="display:flex;gap:8px;justify-self:end;flex-wrap:wrap">
          <a class="btn small" target="_blank" rel="noopener" href="${m.match_center || '#'}">매치센터</a>
          <a class="btn small" target="_blank" rel="noopener" href="${m.watch || '#'}">중계보기</a>
          <a class="btn small" target="_blank" rel="noopener" href="${m.youtube || 'https://www.youtube.com/results?search_query=LAFC+highlights'}">하이라이트</a>
        </div>`;
      ul.appendChild(li);
    });
}

function renderNext(match){
  const wrap = document.getElementById('nextMatch');
  const live = withinLiveWindow(match.datetime);
  wrap.innerHTML = `
    <div class="match-title">LAFC vs ${teamKR(match.opponent)} <span class="badge">${match.home ? '홈' : '원정'}</span> ${live ? '<span class="badge live">LIVE</span>' : ''}</div>
    <div class="timeblock">
      <div><span class="tag">한국(KST)</span> ${fmtTZ(match.datetime, 'Asia/Seoul')}</div>
      <div><span class="tag">LA 현지</span> ${fmtTZ(match.datetime, 'America/Los_Angeles')}</div>
    </div>
    <div class="muted">장소: ${match.venue || '-'} · 손흥민 출전: ${match.son_expected ? '예정' : '미정'}</div>
  `;
  document.getElementById('btnMatchCenter').href = match.match_center || 'https://www.lafc.com/schedule/';
  document.getElementById('btnSeasonPass').href = match.watch || 'https://tv.apple.com/';
  document.getElementById('btnYT').href = match.youtube || 'https://www.youtube.com/results?search_query=LAFC+highlights';
  document.getElementById('btnICS').onclick = ()=> makeICS(match);
  document.getElementById('btnICSAll').onclick = ()=> exportAllICS(window.__allMatches||[]);
}

async function init(){
  try{
    const sched = await api('/schedule?team=LAFC');
    const matches = sched.matches || [];
    window.__allMatches = matches;
    const upcoming = matches.filter(m => new Date(m.datetime) >= new Date()).sort((a,b)=> new Date(a.datetime)-new Date(b.datetime));
    renderNext(upcoming[0] || matches[0]);
    renderSchedule(matches);

    const lineups = await api('/lineups?team=LAFC&limit=3');
    const box = document.getElementById('lineupList');
    box.innerHTML = '';
    (lineups.items||[]).forEach(item=>{
      const div = document.createElement('div');
      div.className = 'lineup-card';
      const timeKR = fmtTZ(item.datetime, 'Asia/Seoul');
      const start = (item.startingXI||[]).map(p=> p.name).join(', ');
      div.innerHTML = `<b>${timeKR} · LAFC vs ${teamKR(item.opponent)}</b><br><span class="muted">${item.formation||''}</span><br>${start}`;
      box.appendChild(div);
    });

    const squad = await api('/squad?team=LAFC');
    const sbox = document.getElementById('squad');
    sbox.innerHTML = '';
    (squad.players||[]).forEach(p=>{
      const d = document.createElement('div');
      d.className = 'p';
      d.innerHTML = `<b>#${p.number || '-'} ${p.name}</b><span class="muted">${p.position || ''} · ${p.nationality || ''}</span>`;
      sbox.appendChild(d);
    });

    document.getElementById('onlyHome').addEventListener('change', ()=> renderSchedule(matches));
    document.getElementById('onlySon').addEventListener('change', ()=> renderSchedule(matches));
  }catch(e){
    console.error(e);
    document.getElementById('nextMatch').innerHTML = '<span class="muted">데이터를 불러오지 못했습니다. config.json.apiBase를 확인하세요.</span>';
  }
}

if ('serviceWorker' in navigator){
  window.addEventListener('load', ()=>{
    navigator.serviceWorker.register('./service-worker.js');
  });
}

init();
