const CACHE="invitstudio-admin-v1";
const ASSETS=["/app.html","/manifest.json","/icon-192.png","/icon-512.png",
  "/assets/ivoire-gatefold2.webp","/assets/ivoire-cover.webp","/assets/intro-arche2.webp","/assets/bismillah-calligraphy.webp"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).catch(()=>{}));self.skipWaiting();});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))));self.clients.claim();});
self.addEventListener("fetch",e=>{
  const r=e.request; if(r.method!=="GET") return;
  const u=new URL(r.url);
  // NE PAS mettre en cache les appels Supabase (toujours frais)
  if(u.hostname.indexOf("supabase")>=0){ return; }
  if(r.mode==="navigate"){ e.respondWith(fetch(r).catch(()=>caches.match("/app.html"))); return; }
  e.respondWith(caches.match(r).then(c=>c||fetch(r).then(res=>{const cp=res.clone();caches.open(CACHE).then(ca=>ca.put(r,cp)).catch(()=>{});return res;}).catch(()=>c)));
});
