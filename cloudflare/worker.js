
// Cloudflare Worker proxy for API-FOOTBALL (API-Sports direct key)
// ENV variables required:
//   API_FOOTBALL_KEY (secret) - your API key
//   API_FOOTBALL_HOST = v3.football.api-sports.io
//   LAFC_TEAM_ID = 1609
//   MLS_LEAGUE_ID = 253
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Basic CORS
    const headers = { "Access-Control-Allow-Origin":"*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"GET,OPTIONS" };
    if (request.method === "OPTIONS") return new Response(null, { headers });

    try {
      if (path === "/schedule") {
        const res = await schedule(env, ctx);
        return json(res, headers, 300);
      }
      if (path.startsWith("/lineups")) {
        const limit = Number(url.searchParams.get("limit")||"3");
        const res = await lineups(env, ctx, limit);
        return json(res, headers, 600);
      }
      if (path.startsWith("/squad")) {
        const res = await squad(env, ctx);
        return json(res, headers, 86400);
      }
      return new Response("Not found", { status:404, headers });
    } catch (e) {
      return new Response("Proxy error: " + e.message, { status: 500, headers });
    }
  }
}

function json(obj, baseHeaders, sMaxAge){
  const h = new Headers(baseHeaders);
  h.set("content-type","application/json; charset=utf-8");
  if (sMaxAge) h.set("Cache-Control", `public, s-maxage=${sMaxAge}`);
  return new Response(JSON.stringify(obj), { headers: h });
}

async function schedule(env, ctx){
  const teamId = env.LAFC_TEAM_ID || "1609";

  const qNext = new URLSearchParams({ team: teamId, next: "10" });
  const fixtures = await api(env, ctx, "/fixtures", qNext);

  const matches = (fixtures.response||[]).map(fx => ({
    fixture_id: fx.fixture?.id,
    date: (fx.fixture?.date)||"",
    datetime: (fx.fixture?.date)||"",
    venue: fx.fixture?.venue?.name || "",
    status: fx.fixture?.status?.short || "",
    home: fx.teams?.home?.name === "Los Angeles FC",
    opponent: fx.teams?.home?.name === "Los Angeles FC" ? (fx.teams?.away?.name||"") : (fx.teams?.home?.name||""),
    match_center: fx.fixture?.id ? `https://www.api-football.com/demo/api/v3/fixtures?id=${fx.fixture.id}` : "",
    watch: "https://tv.apple.com/",
    youtube: "https://www.youtube.com/results?search_query=LAFC+highlights",
    son_expected: true
  }));

  const qPrev = new URLSearchParams({ team: teamId, last: "3" });
  const prev = await api(env, ctx, "/fixtures", qPrev);
  const recent = (prev.response||[]).map(fx => ({
    fixture_id: fx.fixture?.id,
    date: (fx.fixture?.date)||"",
    datetime: (fx.fixture?.date)||"",
    venue: fx.fixture?.venue?.name || "",
    status: fx.fixture?.status?.short || "",
    home: fx.teams?.home?.name === "Los Angeles FC",
    opponent: fx.teams?.home?.name === "Los Angeles FC" ? (fx.teams?.away?.name||"") : (fx.teams?.home?.name||""),
    goals: { home: fx.goals?.home, away: fx.goals?.away },
    match_center: fx.fixture?.id ? `https://www.api-football.com/demo/api/v3/fixtures?id=${fx.fixture.id}` : ""
  }));

  return { matches, recent };
}

async function lineups(env, ctx, limit){
  const teamId = env.LAFC_TEAM_ID || "1609";
  const qPrev = new URLSearchParams({ team: teamId, last: String(limit) });
  const prev = await api(env, ctx, "/fixtures", qPrev);
  const items = [];
  for (const fx of (prev.response||[])){
    const fid = fx.fixture?.id;
    if (!fid) continue;
    const lu = await api(env, ctx, "/fixtures/lineups", new URLSearchParams({ fixture: String(fid) }));
    const first = (lu.response||[])[0];
    items.push({
      fixture_id: fid,
      datetime: fx.fixture?.date,
      opponent: fx.teams?.home?.name === "Los Angeles FC" ? (fx.teams?.away?.name||"") : (fx.teams?.home?.name||""),
      formation: first?.formation || "",
      startingXI: (first?.startXI||[]).map(x=> ({ name: x.player?.name, number: x.player?.number }))
    });
  }
  return { items };
}

async function squad(env, ctx){
  const teamId = env.LAFC_TEAM_ID || "1609";
  const res = await api(env, ctx, "/players/squads", new URLSearchParams({ team: teamId }));
  const players = [];
  for (const sq of (res.response||[])){
    for (const p of (sq.players||[])){
      players.push({ id: p.id, name: p.name, number: p.number, position: p.position, age: p.age, nationality: p.nationality });
    }
  }
  players.sort((a,b)=> (a.number||999) - (b.number||999));
  return { players };
}

async function api(env, ctx, endpoint, search){
  const host = env.API_FOOTBALL_HOST || "v3.football.api-sports.io";
  const url = new URL(`https://${host}${endpoint}`);
  if (search) url.search = search.toString();

  const req = new Request(url.toString(), {
    headers: { "x-apisports-key": env.API_FOOTBALL_KEY }
  });

  // cache by URL to save free quota
  const cache = caches.default;
  const cached = await cache.match(req);
  if (cached) return await cached.json();

  const resp = await fetch(req);
  const data = await resp.json();
  const cacheResp = new Response(JSON.stringify(data), { headers: { "content-type":"application/json" } });
  ctx.waitUntil(cache.put(req, cacheResp.clone()));
  return data;
}
