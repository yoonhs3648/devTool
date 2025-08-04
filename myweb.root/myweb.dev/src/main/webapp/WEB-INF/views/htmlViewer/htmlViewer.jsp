<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<script>
    function renderHTML() {
        const htmlString = $('#inputHtml').val();
        const enableScript = $('#enableScript').is(':checked');

        if (enableScript) {
            const cleanHTML = DOMPurify.sanitize(htmlString);  // 스크립트 및 위험 요소 제거
            $('#renderedHTML').html(cleanHTML);
        } else {
            $('#renderedHTML').html(htmlString);
        }
    }
</script>
<div class="container">
    <div class="left">
        <span style="float:right">
            <label for="enableScript" class="checkbox-label" data-tooltip="HTML의 스크립트, 이벤트 핸들러 등 동적 기능을 제거하여 안전한 정적 콘텐츠만 허용합니다">
                <input type="checkbox" id="enableScript" checked>
                DOMPurify
            </label>
            <button class="btn" onclick="renderHTML()">Render</button>
        </span>
        <textarea id="inputHtml" name="inputHtml" spellcheck="false" placeholder="여기에 HTML 문자열을 입력하세요."></textarea>
    </div>
    <div class="right" id="result">
        <div class="result-wrapper">
            <div id="renderedHTML" class="html-render-wrapper"></div>
        </div>
    </div>
</div>