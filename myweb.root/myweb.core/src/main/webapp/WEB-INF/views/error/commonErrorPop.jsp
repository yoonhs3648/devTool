<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="error-container">
    <div class="error-title">⚠ 오류가 발생했습니다</div>

    <div class="error-content">
        <strong>요청 URL:</strong>
        <div>${url}</div>

        <strong>에러 메시지:</strong>
        <div>${errorMessage}</div>

        <strong>StackTrace:</strong>
        <div class="error-trace">
<pre>
<c:forEach var="line" items="${stackTrace}">
${line}
</c:forEach>
</pre>
        </div>
    </div>
</div>
<style>
    .error-title {
        font-size: 22px;
        color: #dc3545;
        font-weight: 700;
        margin: 0 0 40px 0; /* 아래만 띄움 */
        line-height: 1.2;
    }

    .error-content {
        font-size: 14px;
        color: #333;
    }

    .error-content strong {
        display: block;
        margin-top: 30px;
        margin-bottom: 5px;
        font-weight: 600;
        color: #555;
    }
    .error-content div {
        word-break: break-word;
        color: #222;
    }

    .error-trace {
        font-family: "D2Coding", Consolas, "Courier New", monospace;
        background-color: #f5f5f5;
        border: 1px solid #ccc;
        padding: 12px;
        font-size: 13px;
        white-space: pre-wrap;    /* 줄바꿈은 유지 */
        overflow-x: auto;         /* 가로 스크롤 허용 */
        word-break: normal;       /* 단어 중간에 자르지 않음 */
        border-radius: 6px;
        color: #444;
        box-shadow: inset 0 0 5px #ddd;
    }

    .error-trace pre {
        margin: 0;
        padding: 0;
        background: transparent;
        white-space: pre-wrap;    /* 줄바꿈 유지 */
        overflow-x: auto;         /* 가로 스크롤 허용 */
        font-size: 13px;
        color: #444;
        word-break: normal;       /* 단어 중간 자르지 않도록 */
    }
</style>