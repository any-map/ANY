var CACHE = 'any-v12';
var ASSETS = [
  'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css',
  'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js',
  'https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css',
  'https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css',
  'https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js'
];

self.addEventListener('install', function(e) {
  e.waitUntil(
    caches.open(CACHE).then(function(cache) {
      return cache.addAll(ASSETS);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(keys.filter(function(k) { return k !== CACHE; }).map(function(k) { return caches.delete(k); }));
    })
  );
  self.clients.claim();
});

self.addEventListener('push', function(e) {
  if (!e.data) return;
  var data = {};
  try { data = e.data.json(); } catch(err) { data = { title: 'ANY', body: e.data.text() }; }
  e.waitUntil(
    self.registration.showNotification(data.title || 'ANY', {
      body: data.body || '',
      icon: '/ANY/icon-192.png',
      badge: '/ANY/icon-192.png',
      data: { url: data.url || '/ANY/' },
      vibrate: [200, 100, 200]
    })
  );
});

self.addEventListener('notificationclick', function(e) {
  e.notification.close();
  var target = (e.notification.data && e.notification.data.url) || '/ANY/';
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(list) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].url.includes('any24-7') || list[i].url.includes('github.io')) {
          return list[i].focus();
        }
      }
      return clients.openWindow(target);
    })
  );
});

self.addEventListener('fetch', function(e) {
  if (e.request.method !== 'GET') return;
  var url = e.request.url;
  if (url.includes('supabase.co')) return;
  // HTML toujours depuis le réseau, jamais mis en cache
  var isHTML = e.request.headers.get('accept') && e.request.headers.get('accept').includes('text/html');
  if (isHTML) return;
  e.respondWith(
    caches.match(e.request).then(function(cached) {
      return cached || fetch(e.request).then(function(res) {
        if (res && res.status === 200 && res.type !== 'opaque') {
          var clone = res.clone();
          caches.open(CACHE).then(function(cache) { cache.put(e.request, clone); });
        }
        return res;
      }).catch(function() { return cached; });
    })
  );
});
