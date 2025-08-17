
// Enhanced: supports Google Sheets CSV via config.json, and "Export all ICS" feature.
let deferredPrompt;
const installBtn = document.getElementById('installBtn');
const refreshBtn = document.getElementById('refreshBtn');

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

refreshBtn?.addEventListener('click', () => {
  localStorage.setItem('forceReload', Date.now().toString());
  location.reload();
});

async function loadConfig(){
  try{
    const res = await fetch('config.json', {cache: 'no-store'});
    if (!res.ok) throw 0;
    return await res.json();
  }catch{
    return { sheet_csv_url: "", timezone: "Asia/Seoul" };
  }
}

async function loadMatchesFromCSV(url){
  const res = await fetch(url, {cache: 'no-store'});
  const text = await res.text();
  // Simple CSV parsing
  const rows = text.split(/\r?\n/).filter(r=>r.trim().length);
  const header = rows.shift().split(',').map(h=>h.trim());
  const idx = (name)=> header.findIndex(h=>h.toLowerCase()===name);
  const m = [];
  for (const r of rows){
    const cells = r.split(',').map(c=>c.trim());
    const obj = {};
    header.forEach((h,i)=> obj[h] = cells[i] || "");
    m.push({
      date: obj['date'] || "",
      datetime: obj['datetime'] || "",
      opponent: obj['opponent'] || "",
      home: (obj['home']||"").toLowerCase().startsWith('t'),
      venue: obj['venue'] || "",
      son_expected: (obj['son_expected']||"").toLowerCase().startsWith('t'),
      lineup: (obj['lineup']||"").split('|').map(s=>s.trim()).filter(Boolean),
      match_center: obj['match_center'] || "",
      watch: obj['watch'] || "",
      youtube: obj['youtube'] || ""
    });
  }
  return m;
}

async function loadData(){
  const cfg = await loadConfig();
  if (cfg.sheet_csv_url){
    try { 
      const fromSheet = await loadMatchesFromCSV(cfg.sheet_csv_url);
      return fromSheet;
    } catch(e){
      console.warn('CSV load failed, fallback to matches.json', e);
    }
  }
  const res = await fetch('matches.json', {cache: 'no-store'});
  const data = await res.json();
  return data.matches;
}

function toLocal(dt){
  const d = new Date(dt);
  try{
    return d.toLocaleString('ko-KR', {weekday:'short', month:'numeric', day:'numeric', hour:'2-digit', minute:'2-digit'});
  }catch{
    return d.toLocaleString();
  }
}

function makeICS(match){
  const dtStart = new Date(match.datetime);
  const dtEnd = new Date(dtStart.getTime() + 2 * 60 * 60 * 1000);
  const pad = (n)=> String(n).padStart(2,'0');
  function fmt(d){
    return d.getUTCFullYear() + pad(d.getUTCMonth()+1) + pad(d.getUTCDate()) + 'T' + pad(d.getUTCHours()) + pad(d.getUTCMinutes()) + '00Z';
  }
  const ics = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:lafc-mom',
    'BEGIN:VEVENT',
    `UID:${Date.now()}@lafc-mom`,
    `DTSTAMP:${fmt(new Date())}`,
    `DTSTART:${fmt(dtStart)}`,
    `DTEND:${fmt(dtEnd)}`,
    `SUMMARY:LAFC vs ${match.opponent}`,
    `LOCATION:${match.venue || ''}`,
    `DESCRIPTION:경기 보기: ${match.watch || ''}`,
    'END:VEVENT',
    'END:VCALENDAR'
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
  matches.forEach(match=>{
    const dtStart = new Date(match.datetime);
    const dtEnd = new Date(dtStart.getTime() + 2*60*60*1000);
    lines.push('BEGIN:VEVENT');
    lines.push(`UID:${dtStart.getTime()}_${match.opponent}@lafc-mom`);
    lines.push(`DTSTAMP:${fmt(new Date())}`);
    lines.push(`DTSTART:${fmt(dtStart)}`);
    lines.push(`DTEND:${fmt(dtEnd)}`);
    lines.push(`SUMMARY:LAFC vs ${match.opponent}`);
    lines.push(`LOCATION:${match.venue || ''}`);
    lines.push(`DESCRIPTION:경기 보기: ${match.watch || ''}`);
    lines.push('END:VEVENT');
  });
  lines.push('END:VCALENDAR');
  const blob = new Blob([lines.join('\r\n')], {type:'text/calendar;charset=utf-8'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `LAFC_schedule.ics`;
  a.click();
  URL.revokeObjectURL(url);
}

function renderNext(match){
  const wrap = document.getElementById('nextMatch');
  wrap.innerHTML = `
    <div class="match-title">LAFC vs ${match.opponent} <span class="badge">${match.home ? '홈' : '원정'}</span></div>
    <div class="muted">킥오프: ${toLocal(match.datetime)} · 장소: ${match.venue || '-'}</div>
    <div class="muted">손흥민 출전: ${match.son_expected ? '예정' : '미정'}</div>
  `;
  document.getElementById('btnMatchCenter').href = match.match_center || 'https://www.lafc.com/schedule/';
  document.getElementById('btnSeasonPass').href = match.watch || 'https://tv.apple.com/';
  document.getElementById('btnYT').href = match.youtube || 'https://www.youtube.com/results?search_query=LAFC+highlights';
  document.getElementById('btnICS').onclick = ()=> makeICS(match);
  document.getElementById('btnICSAll').onclick = ()=> exportAllICS(window.__allMatches||[]);
  document.getElementById('lineup').innerHTML = match.lineup?.length
    ? `<pre>${match.lineup.join('\n')}</pre>`
    : '<span class="muted">아직 발표 전입니다.</span>';
}

function renderList(matches){
  const ul = document.getElementById('schedule');
  const onlyHome = document.getElementById('onlyHome').checked;
  const onlySon = document.getElementById('onlySon').checked;
  const now = new Date();
  ul.innerHTML = '';
  matches
    .filter(m => new Date(m.datetime) >= new Date(now.getTime() - 3*60*60*1000)) // past 3h grace
    .filter(m => onlyHome ? m.home : true)
    .filter(m => onlySon ? (m.son_expected === true) : true)
    .sort((a,b)=> new Date(a.datetime) - new Date(b.datetime))
    .forEach(m => {
      const li = document.createElement('li');
      li.innerHTML = `
        <div class="muted">${toLocal(m.datetime)}</div>
        <div class="meta">
          <span class="badge">${m.home ? '홈' : '원정'}</span>
          <strong>LAFC vs ${m.opponent}</strong>
          <span class="muted">· ${m.venue || '-'}</span>
        </div>
        <div style="display:flex;gap:6px;justify-self:end;flex-wrap:wrap">
          <a class="btn small" target="_blank" rel="noopener" href="${m.match_center || '#'}">매치센터</a>
          <a class="btn small" target="_blank" rel="noopener" href="${m.watch || '#'}">중계보기</a>
          <a class="btn small" target="_blank" rel="noopener" href="${m.youtube || 'https://www.youtube.com/results?search_query=LAFC+highlights'}">하이라이트</a>
        </div>
      `;
      ul.appendChild(li);
    });
}

async function init(){
  try{
    const matches = await loadData();
    window.__allMatches = matches.slice();
    const upcoming = matches.filter(m => new Date(m.datetime) >= new Date()).sort((a,b)=> new Date(a.datetime)-new Date(b.datetime));
    if (upcoming.length){
      renderNext(upcoming[0]);
    } else {
      const sorted = matches.slice().sort((a,b)=> new Date(b.datetime)-new Date(a.datetime));
      renderNext(sorted[0]);
    }
    renderList(matches);
    document.getElementById('onlyHome').addEventListener('change', ()=> renderList(matches));
    document.getElementById('onlySon').addEventListener('change', ()=> renderList(matches));
  }catch(e){
    console.error(e);
    document.getElementById('nextMatch').innerHTML = '<span class="muted">데이터를 불러오지 못했습니다. matches.json 또는 config.json을 확인하세요.</span>';
  }
}

if ('serviceWorker' in navigator){
  window.addEventListener('load', ()=>{
    navigator.serviceWorker.register('./service-worker.js');
  });
}

init();
