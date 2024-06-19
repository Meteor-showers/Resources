/** Docker加速 */

const CACHE_TTL = 3600;  // 缓存时间，单位为秒
const HUB_HOST = 'registry-1.docker.io';
const AUTH_URL = 'https://auth.docker.io';
const WORKERS_URL = 'https://docker.example.com';

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event).catch(err => {
    console.error('Request handling error:', err);
    return makeRes('cfworker error:\n' + err.stack, 502);
  }));
});

async function handleRequest(event) {
  const url = new URL(event.request.url);
  console.log(`Handling request for ${url.pathname}`);

  if (event.request.method === 'OPTIONS') {
    return handlePreflight();
  }

  if (url.pathname === '/token') {
    return handleTokenRequest(event);
  }

  return handleProxyRequest(event, url);
}

function handlePreflight() {
  return new Response(null, {
    status: 204,
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, OPTIONS',
      'access-control-allow-headers': 'Authorization, Content-Type',
      'access-control-max-age': '86400',
    },
  });
}

async function handleTokenRequest(event) {
  const tokenUrl = new URL(AUTH_URL + event.request.url.search);
  const headers = createHeaders(event, tokenUrl.host);
  console.log(`Requesting token from ${tokenUrl.href}`);

  try {
    const tokenRequest = new Request(tokenUrl, {
      method: event.request.method,
      headers: headers,
      body: event.request.body
    });

    const response = await fetch(tokenRequest);
    return cacheResponse(response, CACHE_TTL);
  } catch (error) {
    console.error('Token request error:', error);
    return makeRes('Token request error', 500);
  }
}

async function handleProxyRequest(event, url) {
  url.hostname = HUB_HOST;
  const headers = createHeaders(event, HUB_HOST);
  console.log(`Proxying request to ${url.href}`);

  try {
    const proxyRequest = new Request(url, {
      method: event.request.method,
      headers: headers,
      body: event.request.body
    });

    const originalResponse = await fetch(proxyRequest);
    const newResponseHeaders = new Headers(originalResponse.headers);

    updateHeaders(newResponseHeaders);

    if (newResponseHeaders.has("Location")) {
      return handleProxyRedirect(event.request, newResponseHeaders.get("Location"));
    }

    return cacheResponse(new Response(originalResponse.body, {
      status: originalResponse.status,
      headers: newResponseHeaders
    }), CACHE_TTL);
  } catch (error) {
    console.error('Proxy request error:', error);
    return makeRes('Proxy request error', 500);
  }
}

function handleProxyRedirect(request, location) {
  const newUrl = new URL(location);
  console.log(`Handling redirect to ${newUrl.href}`);
  return proxy(newUrl, request);
}

async function proxy(urlObj, request) {
  try {
    const response = await fetch(urlObj.href, request);
    const headers = new Headers(response.headers);

    updateHeaders(headers);

    return cacheResponse(new Response(response.body, {
      status: response.status,
      headers: headers
    }), 1500);
  } catch (error) {
    console.error('Proxy redirect error:', error);
    return makeRes('Proxy redirect error', 500);
  }
}

function createHeaders(event, host) {
  const headers = {
    'Host': host,
    'User-Agent': event.request.headers.get("User-Agent"),
    'Accept': event.request.headers.get("Accept"),
    'Accept-Language': event.request.headers.get("Accept-Language"),
    'Accept-Encoding': event.request.headers.get("Accept-Encoding"),
    'Connection': 'keep-alive',
    'Cache-Control': 'max-age=0',
  };

  if (event.request.headers.has("Authorization")) {
    headers['Authorization'] = event.request.headers.get("Authorization");
  }

  return headers;
}

function updateHeaders(headers) {
  headers.set('access-control-expose-headers', '*');
  headers.set('access-control-allow-origin', '*');
  headers.set('Cache-Control', 'max-age=1500');
  ['content-security-policy', 'content-security-policy-report-only', 'clear-site-data'].forEach(header => headers.delete(header));
}

function cacheResponse(response, ttl) {
  const cachedHeaders = new Headers(response.headers);
  cachedHeaders.set('Cache-Control', `max-age=${ttl}`);

  return new Response(response.body, {
    status: response.status,
    headers: cachedHeaders
  });
}

function makeRes(body, status = 200, headers = {}) {
  headers['access-control-allow-origin'] = '*';
  return new Response(body, { status, headers });
}
