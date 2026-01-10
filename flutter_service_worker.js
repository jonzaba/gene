'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"sqflite_sw.js": "d6d88e4100cd82a8b31f692c23a03656",
"version.json": "958ca7f65209d06c6886542e542f38a8",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"sqflite_sw.dart": "0c4345e5c56153595083a962e427b2d1",
"index.html": "db37447defbc4926fa4d13d8787b0584",
"/": "db37447defbc4926fa4d13d8787b0584",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"manifest.json": "494b85334800b7100a553cb73960cbad",
"assets/NOTICES": "6464e053cc84826c2781e6f3f3acecc3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "e9f47202e9a6f78a4ce9bcd7ba1c671c",
"assets/AssetManifest.bin.json": "8dc7565517045a6909433fc390b4de05",
"assets/fonts/MaterialIcons-Regular.otf": "eb1c4dc1b69ab9c2960ce052ba5e4865",
"assets/assets/images/doc_Nacimiento.png": "4e1cc21a3a5693496b3b7cbbf62545a3",
"assets/assets/images/foto_f.png": "65e27b84a8001f934ba03303fac98dbd",
"assets/assets/images/doc_Separacion.png": "b87e8be14580c261776638b73b71c23c",
"assets/assets/images/doc_Fallecimiento.png": "783287b191d55927fa59f292f733f9a2",
"assets/assets/images/doc_Boda.png": "fc9740fc3bff26086a8c11376f096c40",
"assets/assets/images/foto_m.png": "22bb6833405098329d33de8ba1f2dcef",
"assets/AssetManifest.bin": "f62b7e28acc107c0b2ec88196f620687",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
".git/logs/refs/remotes/origin/gh-pages": "87aaca4aa6a119d5d00eb08ff874b2e1",
".git/logs/refs/heads/gh-pages": "b4a50e9767e804fa3cb951e3ba53e268",
".git/logs/HEAD": "b4a50e9767e804fa3cb951e3ba53e268",
".git/refs/remotes/origin/gh-pages": "03c69b79c9a00c2054b3aadc5f9d1ef3",
".git/refs/heads/gh-pages": "03c69b79c9a00c2054b3aadc5f9d1ef3",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/COMMIT_EDITMSG": "479688a335a1cebe29333b4e2f8b6457",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/index": "63c6a53afa4f373f2d381bd23d2a70ef",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/f9/d012cbcbd6e59143fe29318d8a5659519eaa26": "65ab969f6467aafbb13b1495df83a5bb",
".git/objects/3c/d99bf68793751a34441f02ff4e0a4763ee2d91": "8d967178d42401870a34974f088f8bad",
".git/objects/06/4792aaf6f7c7b8b8fb38ac6e3ccba4c3824334": "c7c93d36a3a9504e08ca6bec77eab952",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/43/c4a5131cdb6b6f8b4b8f0cfdb730701f185249": "b5a2e69fa44259dc4f248b6f4e8495e0",
".git/objects/c8/ea858d08ee13c32a553f9e84b530a2da929dce": "c4219cd4c6610c7aa1aa7ce94d2983dc",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/bc/0bbefc5c78b6ccf89f1878210093efe284a6d5": "b961e538b541fe1eeff01de32a680835",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/56/bacc2a4ac7ce457fa92874976974a5141f70c2": "73601e6533701b971f0ca37f44191a42",
".git/objects/33/20594118f57385f83449ff74596600f1e8ef69": "fcc490df829ac71e70fa5a9579217341",
".git/objects/72/3c4fcb16369788276fe247f89b8c109814f7b2": "5e9e611d615c8449b79607dc58e19cbc",
".git/objects/72/7232a357fbf3834d130749e350e8b16775fc29": "a7049f4760d0b6bdfc008759e6cdee9f",
".git/objects/72/6fdb108aab8c6c7fca98143a9159a33f4adcdc": "1d868a351887604fd8e1dd319d209973",
".git/objects/07/8cf6b706ee3af60af75e79d23a43c793e10b0c": "1003423b547d3f287ce77ddf7001ddb2",
".git/objects/cc/fd00cadc8c935eee5ff4a78696002eee501989": "e7e9415a84f079089de5db42b0bc28e8",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/ad/fcf4705f22b246b8cda1ba55e6ba48d50a58ea": "c005ba75ada21ac71459c20e4d54ba61",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/9a/0ba51970840ec1090310563dd686632f89b7ed": "021d1a0b92d0b5bb51a79a25cd2ec4f0",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/aa/95a15a2094a7a6e3de5ae424d27b5399e68543": "76eaf8a3044d04bc76b3265bd1d653c2",
".git/objects/6d/3e5d3caeedaed1450cbcca3fc9c16bc81631e3": "3498cc1b7f3ad93df5fbe091bd9b0ec5",
".git/objects/6d/47d2ac289b569e182da0a4405bc3f11f4f3cd8": "1f90a06536d31e0f1f9daec235c4dc8e",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/9d/19a738306b0f3bacd1e34eed90784dba31f03f": "1f2a175b9a97e07added5f75ff1a1b68",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/f7/2b7ffba4d0771cc89b62227d5829e564f295c9": "cf504b433e1c4835a55883abc6ce7e5d",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/51/c73ceedcf60c6b064e753837da25bec9b687a6": "ddb844b0e8b5ac06139eaede15e199e0",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/df/73b7bb92566ceb3ba7e6fd5f55307803e66817": "35208c321c3c0af6b8545f5949134e90",
".git/objects/90/02204dfc42f9897adf23cd9cb5359569a7a5ed": "9b371af701481d9bd19f2386e58b6ee9",
".git/objects/a2/be35bc27301cfad59119c88dcbbc92a9634a37": "b6d206a559b85df3cb8252c0e67f40bf",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/fb/689c0752aa40eff408175e39f3668d8a4ed13e": "7c2c01db51aceab2494280ed37c69b29",
".git/objects/2d/af4e9d40e2e6a17376f3bfefd081d8fe2313c3": "320fb7506c8a59554077a653365621f1",
".git/objects/27/d2de4202320742cbebe6d5e2aac0fbf4d07345": "406ee3c111967bda720092fc454fafc3",
".git/objects/04/2d4c4679b0eca1387fd9c97409daef3c046de4": "d24a371507202835e3ccb47c35b29694",
".git/objects/13/aaea02c2fce04748022d85cd0a0152706233e2": "749e28f405e08f5f19fa03abaaa589e7",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/config": "9c1da0895f1ab7db59ca6a314fe1924a",
"flutter_bootstrap.js": "e8e8a4ac329ca6d23e7f1a30c38f17d4",
"main.dart.js": "c82dde5fc209f093210384d09b5c7eb8",
"sqlite3.wasm": "2e9fc1ccbb9d15199fccf405b0ceee53",
"sqflite_sw.js.deps": "6c0871533e415c57b05355f62593a9b9",
"sqflite_sw.js.map": "a2f6e1d21646d1a92e0ac525bc6469f7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
