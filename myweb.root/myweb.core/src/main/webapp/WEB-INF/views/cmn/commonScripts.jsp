<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- 최상위 템플릿 CSS -->
<style>
    /* 기본 스타일 */
    html, body {
        font-family: Arial, sans-serif;
        margin: 0; padding: 0;
        height: 100%;
        min-width: 100%;
        background-color: #f9f9f9;
    }

    body {
        display: inline-flex;
        flex-direction: column;
    }

    header, footer {
        width: 100%;
        padding: 20px;
        box-sizing: border-box;
    }

    #main-content {
        flex: 1;    /* header, footer를 제외한 나머지 영역 차지 */
        display: flex;
    }

    /* Chrome 자동완성 배경 제거 */
    input:-webkit-autofill,
    textarea:-webkit-autofill {
        box-shadow: 0 0 0 1000px white inset !important;
        -webkit-text-fill-color: #000 !important;
        transition: background-color 5000s ease-in-out 0s !important;
    }

    /* 모바일 터치 시 블루 하이라이트 제거 */
    * {
        -webkit-tap-highlight-color: transparent;
    }
</style>

<!-- 공통 CSS 로드 -->
<link class="theme-link" rel="stylesheet" type="text/css" href="/core/resources/css/default.css">

<!-- 공통 JS 로드 -->
<script type="text/javascript" src="/core/resources/js/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="/core/resources/js/axios.min.js"></script>
<script type="text/javascript" src="/core/resources/js/common.js"></script>
<script type="text/javascript" src="/core/resources/js/utils.js"></script>
<script type="text/javascript" src="/core/resources/js/modalUtil.js"></script>
<script type="text/javascript" src="/core/resources/js/dompurify.min.js"></script>
<script type="text/javascript" src="/core/resources/js/slider.js"></script>
<script type="text/javascript" src="/core/resources/js/spinner.js"></script>

<script>
    // 모든 input과 textarea에 자동완성 끄기 및 spellcheck 끄기
    $(function() {
        $('input, textarea').attr('autocomplete', 'off');

        $('input[type="text"], textarea').attr('spellcheck', 'false');
    });
</script>