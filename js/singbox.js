function adjustTextareaHeight(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = (textarea.scrollHeight) + 'px';
}

function isValidURL(string) {
    try {
        new URL(string);
        return true;
    } catch (_) {
        return false;
    }
}

function processSubscriptions() {
    const textarea = document.getElementById("subscriptionInput");
    adjustTextareaHeight(textarea);
    const input = textarea.value;
    const lines = input.split('\n').filter(line => line.trim() !== '');
    const validLinks = lines.filter(line => isValidURL(line.trim()));

    const errorMessage = document.getElementById("error-message");

    if (validLinks.length > 0) {
        errorMessage.style.display = 'none';
        if (validLinks.length === 1) {
            generateConfig(validLinks[0]);
        } else {
            const combinedUrl = validLinks.join('|');
            const encodedUrl = encodeURIComponent(combinedUrl);
            generateConfig(encodedUrl);
        }
    } else {
        document.getElementById("output-container").style.display = "none";
        errorMessage.style.display = 'block';
    }
}

function generateConfig(url) {
    const baseUrl = "https://singbox.xkzs.work/config/";
    const configTemplate = "&file=https://github.com/Meteor-showers/sing-box-subscribe/raw/main/config_template/config_template_groups_rule_set_tun.json";

    if (url) {
        const fullUrl = baseUrl + url + configTemplate;
        document.getElementById("output").textContent = fullUrl;
        document.getElementById("output-container").style.display = "block";
    } else {
        document.getElementById("output-container").style.display = "none";
    }
}

function copyToClipboard() {
    const outputText = document.getElementById("output").textContent;
    navigator.clipboard.writeText(outputText).then(() => {
        const copyButton = document.querySelector('.copy-button');
        copyButton.textContent = '已复制';
        copyButton.classList.add('copied');
        setTimeout(() => {
            copyButton.textContent = '复制';
            copyButton.classList.remove('copied');
        }, 2000);
    });
}

function checkUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    const subscriptionParam = urlParams.get('sub');

    if (subscriptionParam) {
        const urls = subscriptionParam.split('|');
        const validLinks = urls.filter(url => isValidURL(url));

        if (validLinks.length > 0) {
            const textarea = document.getElementById("subscriptionInput");
            textarea.value = validLinks.join('\n');
            adjustTextareaHeight(textarea);

            if (validLinks.length === 1) {
                generateConfig(validLinks[0]);
            } else {
                const combinedUrl = validLinks.join('|');
                const encodedUrl = encodeURIComponent(combinedUrl);
                generateConfig(encodedUrl);
            }
        }
    }
}
