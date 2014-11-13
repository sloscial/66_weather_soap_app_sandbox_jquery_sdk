Offline data caching, enabled automatically in the SDK, caches API requests.  Data caching is enabled by default:  no developer effort is required.  Data caching is pass-through:  cached results are used _only when offline_.

When an API request succeeds, the results are stored in a *local storage* cache (using the best available backend, see below).  Fresh data is always used if its available.  When the user is online and the server is responding, API requests are made as usual.  If a request fails (for instance because the user is offline or a server is down), cached data are used instead.

Cached results are _not returned for responses in the 400-range_.  Cache items are expired after 7 days by default.  Cache items are keyed by server, current user (if any), and URL.

## GET Requests Only
Offline caching applies only to `GET` requests, since it is readily automated across many kinds of projects.  Other types of requests are not cached because synchronization is a complex problem and because needs vary.

If you generated an HTML5 app with this SDK, you have access to the library [Offline.js](https://github.com/hubspot/offline).  Offline.js is capable of caching `POST`, `PUT`, and `DELETE` requests when users are offline.  While it is disabled by default, interested developers may implement custom synchronization based on Offline.js.

## Underlaying Storage
Offline data caching is based on the library [large local storage](https://github.com/tantaman/LargeLocalStorage).  It provides a unified API for accessing the best available local storage backend.  For the most capable browsers, this means `FilesystemAPI`.  In other browsers backends are used as available, including `IndexedDB`, `WebSQL`, and `localstorage`.
