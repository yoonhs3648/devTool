<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<script>
    function doParse() {
        let input = $('#urlInput').val().trim();
        let hasProtocol = 1;    //true
        if (!input.startsWith("http://") && !input.startsWith("https://")) {
            input = 'https://' + input;
            hasProtocol = 0;
        }
        const container = document.getElementById('parsedUrlResult');
        container.innerHTML = '';

        try {
            const url = new URL(input);
            let html = '';
            const params = {};
            for (const [key, value] of url.searchParams.entries()) {
                if (params[key]) {
                    if (Array.isArray(params[key])) {
                        params[key].push(value);
                    } else {
                        params[key] = [params[key], value];
                    }
                } else {
                    params[key] = value;
                }
            }

            // html += `
            //     <div class="urlElement" onclick="copyContent(this)">
            //         <div class="urlElement-name">전체 URL</div>
            //         <div class="urlElement-content">\${url.href}</div>
            //     </div>`;

            // if (hasProtocol) {
            //     html += `
            //     <div class="urlElement" onclick="copyContent(this)">
            //         <div class="urlElement-name">프로토콜</div>
            //         <div class="urlElement-content">\${url.protocol}</div>
            //     </div>`;
            // }

            html += `
                <div class="urlElement" onclick="copyContent(this)">
                    <div class="urlElement-name">호스트</div>
                    <div class="urlElement-content">\${url.host}</div>
                </div>`;

            // if (url.port) {     //http, https 는 포트번호가 안나옴
            //     html += `
            //     <div class="urlElement" onclick="copyContent(this)">
            //         <div class="urlElement-name">포트</div>
            //         <div class="urlElement-content">\${url.port}</div>
            //     </div>`;
            // }

            if (url.pathname) {
                html += `
                <div class="urlElement" onclick="copyContent(this)">
                    <div class="urlElement-name">경로</div>
                    <div class="urlElement-content">\${url.pathname}</div>
                </div>`;
            }

            if (url.pathname.endsWith(".aspx")) {
                html += `
                <div class="urlElement" onclick="copyContent(this)">
                    <div class="urlElement-name">ASP.NET 파일명</div>
                    <div class="urlElement-content">\${url.pathname.substring(url.pathname.lastIndexOf('/') + 1)}</div>
                </div>`;
            }

            // if (url.search) {
            //     html += `
            //     <div class="urlElement" onclick="copyContent(this)">
            //         <div class="urlElement-name">쿼리스트링</div>
            //         <div class="urlElement-content">\${url.search}</div>
            //     </div>`;
            // }

            // if (url.hash) {
            //     html += `
            //     <div class="urlElement" onclick="copyContent(this)">
            //         <div class="urlElement-name">해쉬</div>
            //         <div class="urlElement-content">\${url.hash}</div>
            //     </div>`;
            // }

            if (Object.keys(params).length > 0) {
                html += '<br>';
                for (const key in params) {
                    const value = params[key];
                    const valueText = Array.isArray(value) ? value.join(', ') : value;

                    html += `
                    <div class="urlElement" onclick="copyContent(this)">
                        <div class="urlElement-name">\${key}</div>
                        <div class="urlElement-content">\${valueText}</div>
                    </div>`;
                }
            }

            container.innerHTML = html;
        }
        catch (e) {
            container.innerHTML = `<div style="color:red;">잘못된 URL입니다</div>`;
        }
    }

    function copyContent(element) {
        var selection = window.getSelection();
        selection.removeAllRanges();

        var range = document.createRange();
        range.selectNodeContents(element);
        selection.addRange(range);

        try {
            var success = document.execCommand('copy');
            if (success) {
                showCopySuccessMessage();
            } else {
                alert('복사에 실패했습니다...');
            }
        } catch (err) {
            alert('복사 중 오류가 발생했습니다: ' + err);
        }

        selection.removeAllRanges();
    }

    function showCopySuccessMessage() {
        var messageDiv = document.getElementById('copy-success-message');
        messageDiv.style.display = 'block';
        messageDiv.style.opacity = '1';

        // 1초 후에 서서히 사라지게
        setTimeout(function () {
            messageDiv.style.transition = 'opacity 0.5s';
            messageDiv.style.opacity = '0';
        }, 1000);

        // 1.5초 후에 display: none 처리
        setTimeout(function () {
            messageDiv.style.display = 'none';
            messageDiv.style.transition = '';
        }, 1500);
    }
</script>

<div class="vertical-container">
    <div class="top">
        <div class="toolbar">
            <button id="parserBtn" class="btn" onclick="doParse()">파싱</button>
        </div>
        <textarea id="urlInput" name="urlInput" spellcheck="false" placeholder="분석할 URL을 여기에 입력하세요."></textarea>
    </div>
    <div class="bottom" id="result">
        <div class="copy-success-message" id="copy-success-message">✅ 복사 완료</div>
        <div class="result-wrapper">
            <!-- 결과 -->
            <div id="parsedUrlResult" class="result-container"></div>
        </div>
    </div>
</div>