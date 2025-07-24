<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .main-header {
        display: flex;
        justify-content: space-between;     /* header-top-bar는 왼쪽에, 동적으로 생성되는 요소는 오른쪽에 정렬 */
        align-items: center;
        background: #004080;
        color: #fff;
        padding: 15px 20px;
        height: 60px;
        max-height: 60px;
        box-sizing: border-box;
    }

    .main-header a {
        color: #fff;
        text-decoration: none;
    }

    .header-top-bar {
        display: flex;
        gap: 25px;
    }

    .header-logo {
        margin: 0;
        font-size: 24px;
    }

    .header-nav {
        display: flex;
        align-items: center;
    }

    .header-nav > ul {
        display: inline-flex;
        list-style: none;
        margin: 0;
        padding: 0;
        gap: 20px;
    }

    .header-nav > ul > li > a {
        display: block;
        padding: 8px 14px;
        color: #fff;
        text-decoration: none;
        border-radius: 4px;
        transition: background-color 0.2s ease, color 0.2s ease;
    }
</style>

<header class="main-header">
    <div class="header-top-bar">
        <div class="header-logo">
            <h1><a href="/dev/portal">hsyoon</a></h1>
        </div>
        <nav class="header-nav">
            <ul>
                <li><a href="jsonParser">Json/Xml Parser</a></li>
                <li><a href="translator">Translator</a></li>
                <li><a href="encoder">Encoder/Decoder</a></li>
                <li><a href="urlParser">UrlParser</a></li>
            </ul>
        </nav>
    </div>
</header>
