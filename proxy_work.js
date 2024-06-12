/** 页面代理访问 */

addEventListener('fetch',
	event => {
		event.respondWith(handleRequest(event.request));
	});

async function handleRequest(request) {
	const url = new URL(request.url);

	// 从请求路径中提取目标 URL
	let actualUrlStr = url.pathname.replace("/", "");
	actualUrlStr = decodeURIComponent(actualUrlStr);

	// 如果请求路径为空，则返回主页
	if (url.pathname === "/") {
		const mainDomain = url.hostname;
		const websiteTitle = "proxy for Learn"; // 请替换为你的网站标题
		const errorMessage = `
		<html>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, minimal-ui" />
			<meta name="apple-mobile-web-app-capable" content="yes">
			<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
			<title>${websiteTitle}</title>
			<link rel="icon" type="image/jpg" href="https://avatars.githubusercontent.com/u/32284743?v=4">
			<style>
				body {
					font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
					text-align: center;
					background-color: #f8f9fa;
					margin: 0;
					padding: 0;
				}

				#container {
					max-width: 500px;
					margin: 10vh auto;
					background-color: #ffffff;
					padding: 20px;
					border-radius: 15px;
					box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
					transition: transform 0.3s ease, box-shadow 0.3s ease;
				}

				#container:hover {
					transform: translateY(-10px);
					box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
				}

				h1 {
					color: #333;
					margin-bottom: 20px;
				}

				.form-group {
					margin-bottom: 20px;
				}

				label {
					display: block;
					font-size: 1.2em;
					margin-bottom: 10px;
					color: #555;
				}

				input[type="text"] {
					width: 100%;
					padding: 12px;
					border: 1px solid #ddd;
					border-radius: 5px;
					box-sizing: border-box;
					display: block;
					margin-top: 5px;
					margin-bottom: 15px;
					font-size: 1em;
				}

				input[type="button"] {
					background-color: #007bff;
					color: #fff;
					border: none;
					padding: 12px;
					border-radius: 5px;
					cursor: pointer;
					transition: background-color 0.3s ease;
					font-size: 1em;
					width: 100%;
				}

				input[type="button"]:hover {
					background-color: #0056b3;
				}

				p {
					margin-top: 20px;
					color: #777;
				}

				a {
					color: #007bff;
					text-decoration: none;
					transition: color 0.3s ease;
				}

				a:hover {
					color: #0056b3;
				}

				@keyframes shake {
					0% { transform: translateX(0); }
					25% { transform: translateX(-5px); }
					50% { transform: translateX(5px); }
					75% { transform: translateX(-5px); }
					100% { transform: translateX(5px); }
				}

				@media (prefers-color-scheme: dark) {
					body {
						background-color: #333;
					}

					#container {
						background-color: #444;
						color: #ddd;
					}

					input[type="text"] {
						background-color: #555;
						border-color: #666;
						color: #ddd;
					}

					input[type="button"] {
						background-color: #0069d9;
					}

					input[type="button"]:hover {
						background-color: #004f9e;
					}

					label {
						color: #ccc;
					}

					p {
						color: #aaa;
					}

					a {
						color: #66aaff;
					}

					a:hover {
						color: #3399ff;
					}
				}
			</style>
		</head>
		<body>
			<div id="container">
				<h1>${websiteTitle}</h1>
				<div class="form-group">
					<label for="url">输入需要代理的网站:</label>
					<input type="text" id="url" name="url" placeholder="例如：https://github.com/" />
					<input type="button" id="submit" value="进入代理" onclick="redirectToProxy()" />
				</div>
				<p>&copy; 2024 <a href="https://github.com/Meteor-showers/" target="_blank">Meteor-showers</a></p>
			</div>
			<script>
				function redirectToProxy() {
					var urlInput = document.getElementById('url');
					var inputUrl = urlInput.value.trim(); // 移除前后空格
					if (inputUrl) {
						var url = normalizeUrl(inputUrl);
						window.open('https://' + '${mainDomain}' + '/' + url, '_blank');
						// 清空输入框内容
						urlInput.value = '';
					} else {
						// 如果没有输入URL，执行抖动效果
						urlInput.style.animation = 'shake 0.5s';
						setTimeout(() => {
							urlInput.style.animation = ''; // 清除抖动效果
						}, 500);
					}
				}

				function normalizeUrl(inputUrl) {
					// 检查输入的URL是否以 "http://" 或 "https://" 开头
					if (!inputUrl.startsWith("http://") && !inputUrl.startsWith("https://")) {
						// 如果不是以 "http://" 或 "https://" 开头，则默认添加 "https://"
						inputUrl = "https://" + inputUrl;
					}
					return inputUrl;
				}

				// 添加键盘事件监听器
				document.addEventListener('keydown', function(event) {
					if (event.key === 'Enter') {
						// 如果按下回车键，触发提交按钮的点击事件
						document.getElementById('submit').click();
					}
				});
			</script>
			<script src="https://meteor-showers.github.io/github_proxy/Disable.js"></script>
		</body>
		</html>
	  `;

		return new Response(errorMessage, {
			status: 200,
			headers: {
				'Content-Type': 'text/html; charset=utf-8'
			}
		});
	}

	// 创建新 Headers 对象，排除以 'cf-' 开头的请求头
	let newHeaders = new Headers();
	for (let pair of request.headers.entries()) {
		if (!pair[0].startsWith('cf-')) {
			newHeaders.append(pair[0], pair[1]);
		}
	}

	// 创建一个新的请求以访问目标 URL
	const modifiedRequest = new Request(actualUrlStr, {
		headers: newHeaders,
		method: request.method,
		body: request.body,
		redirect: 'manual'
	});

	try {
		// 发起对目标 URL 的请求
		const response = await fetch(modifiedRequest);
		let modifiedResponse;
		let body = response.body;

		// 处理重定向
		if ([301, 302, 303, 307, 308].includes(response.status)) {
			const location = new URL(response.headers.get('location'));
			const modifiedLocation = "/" + encodeURIComponent(location.toString());
			modifiedResponse = new Response(response.body, {
				status: response.status,
				statusText: response.statusText
			});
			modifiedResponse.headers.set('Location', modifiedLocation);
		} else {
			if (response.headers.get("Content-Type") && response.headers.get("Content-Type").includes(
					"text/html")) {
				// 如果响应类型是 HTML，则修改响应内容，将相对路径替换为绝对路径
				const originalText = await response.text();
				const regex = new RegExp('((href|src|action)=["\'])/(?!/)', 'g');
				const modifiedText = originalText.replace(regex,
					`$1${url.protocol}//${url.host}/${encodeURIComponent(new URL(actualUrlStr).origin + "/")}`);
				body = modifiedText;
			}

			modifiedResponse = new Response(body, {
				status: response.status,
				statusText: response.statusText,
				headers: response.headers
			});
		}

			// 添加 CORS 头部，允许跨域访问
		modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
		modifiedResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
		modifiedResponse.headers.set('Access-Control-Allow-Headers', '*');

		return modifiedResponse;
	} catch (error) {
		// 如果请求目标地址时出现错误，返回带有错误消息的响应和状态码 500（服务器错误）
		return new Response('无法访问目标地址: ' + error.message, {
			status: 500
		});
	}
}
