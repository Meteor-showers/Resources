'use strict'

/**
 * Static files (404.html, sw.js, conf.js)
 */
const ASSET_URL = 'https://github.xkzs.work/'
// 前缀，如果自定义路由为example.com/gh/*，将PREFIX改为 '/gh/'，注意，少一个杠都会错！
const PREFIX = '/'
// 分支文件使用jsDelivr镜像的开关，0为关闭，默认关闭
const Config = {
    jsdelivr: 0
}
const CACHE_TTL = 3600;  // 缓存时间，单位为秒

const whiteList = [] // 白名单，路径里面有包含字符的才会通过，e.g. ['/username/']

const PREFLIGHT_INIT = {
    status: 204,
    headers: new Headers({
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET,POST,PUT,PATCH,TRACE,DELETE,HEAD,OPTIONS',
        'access-control-max-age': '1728000',
    }),
}

const URL_PATTERNS = [
    /^(?:https?:\/\/)?github\.com\/.+?\/.+?\/(?:releases|archive)\/.*$/i,
    /^(?:https?:\/\/)?github\.com\/.+?\/.+?\/(?:blob|raw)\/.*$/i,
    /^(?:https?:\/\/)?github\.com\/.+?\/.+?\/(?:info|git-).*$/i,
    /^(?:https?:\/\/)?raw\.(?:githubusercontent|github)\.com\/.+?\/.+?\/.+?\/.+$/i,
    /^(?:https?:\/\/)?gist\.(?:githubusercontent|github)\.com\/.+?\/.+?\/.+$/i,
    /^(?:https?:\/\/)?github\.com\/.+?\/.+?\/tags.*$/i
];

addEventListener('fetch', e => {
    const ret = fetchHandler(e).catch(err => {
        console.error('Request handling error:', err);
        return makeRes('cfworker error:\n' + err.stack, 502);
    });
    e.respondWith(ret);
});

function newUrl(urlStr) {
    try {
        return new URL(urlStr);
    } catch (err) {
        return null;
    }
}

function checkUrl(u) {
    return URL_PATTERNS.some(pattern => pattern.test(u));
}

async function fetchHandler(e) {
    const req = e.request;
    const urlStr = req.url;
    const urlObj = new URL(urlStr);
    let path = urlObj.searchParams.get('q');
    if (path) {
        return Response.redirect('https://' + urlObj.host + PREFIX + path, 301);
    }

    path = urlObj.href.substr(urlObj.origin.length + PREFIX.length).replace(/^https?:\/+/, 'https://');
    if (checkUrl(path)) {
        return httpHandler(req, path);
    } else if (path.search(URL_PATTERNS[1]) === 0) {
        return handleBlobToRawRedirect(path);
    } else {
        return fetch(ASSET_URL + path);
    }
}

function handleBlobToRawRedirect(path) {
    if (Config.jsdelivr) {
        const newUrl = path.replace('/blob/', '@').replace(/^(?:https?:\/\/)?github\.com/, 'https://cdn.jsdelivr.net/');
        return Response.redirect(newUrl, 302);
    } else {
        path = path.replace('/blob/', '/raw/');
        return httpHandler(new Request(path), path);
    }
}

function createHeaders(req, host) {
    const headers = new Headers(req.headers);
    headers.set('Host', host);
    headers.set('Connection', 'keep-alive');
    headers.set('Cache-Control', 'max-age=0');
    return headers;
}

async function httpHandler(req, pathname) {
    const reqHdrRaw = req.headers;

    if (req.method === 'OPTIONS' && reqHdrRaw.has('access-control-request-headers')) {
        return new Response(null, PREFLIGHT_INIT);
    }

    const reqHdrNew = createHeaders(req, new URL(pathname).host);
    let urlStr = pathname;
    if (!whiteList.some(allowed => urlStr.includes(allowed))) {
        return new Response("blocked", {status: 403});
    }
    if (!/^https?:\/\//.test(urlStr)) {
        urlStr = 'https://' + urlStr;
    }
    const urlObj = newUrl(urlStr);
    return proxy(urlObj, { method: req.method, headers: reqHdrNew, redirect: 'manual', body: req.body });
}

async function proxy(urlObj, reqInit) {
    try {
        const res = await fetch(urlObj.href, reqInit);
        const resHdrOld = res.headers;
        const resHdrNew = new Headers(resHdrOld);
        const status = res.status;

        if (resHdrNew.has('location')) {
            let _location = resHdrNew.get('location');
            if (checkUrl(_location)) {
                resHdrNew.set('location', PREFIX + _location);
            } else {
                reqInit.redirect = 'follow';
                return proxy(newUrl(_location), reqInit);
            }
        }
        resHdrNew.set('access-control-expose-headers', '*');
        resHdrNew.set('access-control-allow-origin', '*');
        ['content-security-policy', 'content-security-policy-report-only', 'clear-site-data'].forEach(header => resHdrNew.delete(header));

        return cacheResponse(new Response(res.body, { status, headers: resHdrNew }), CACHE_TTL);
    } catch (error) {
        console.error('Proxy error:', error);
        return makeRes('Proxy error', 500);
    }
}

function cacheResponse(response, ttl) {
    const cachedHeaders = new Headers(response.headers);
    cachedHeaders.set('Cache-Control', `max-age=${ttl}`);
    return new Response(response.body, { status: response.status, headers: cachedHeaders });
}

function makeRes(body, status = 200, headers = {}) {
    headers['access-control-allow-origin'] = '*';
    return new Response(body, { status, headers });
}
