<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    #main-content {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100%;
        background-color: #f0f0f0;
        font-family: 'Courier New', monospace;
        color: #444444;
    }
</style>

<script>
    $(document).ready(function () {
        var adminPageBtn = `<button id="adaminPage" class="btn" onclick="location.href='/dev/portal'">
                                <span class="label">사용자페이지</span>
                            </button>`
        $('header').append(adminPageBtn);
    })
</script>

<!-- 외부 리소스 로드 -->
<link rel="stylesheet" href="/core/resources/css/clock.css">
<script src="/core/resources/js/clock.js"></script>

<div class="clock"></div>
