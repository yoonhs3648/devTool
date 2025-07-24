<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    /* header, footer 색상 변경 */
    body.dark-mode header,
    body.dark-mode header * {
        background-color: #1e1e1e !important;
        color : #254f73;  !important;
        font-weight: bold; !important;
    }
    body.dark-mode header .header-nav > ul > li > a {
        color : #254f73;  !important;
        font-weight: bold; !important;
    }
    body.dark-mode footer,
    body.dark-mode footer * {
        background-color: #1e1e1e !important;
        color: #555 !important;
        font-weight: bold; !important;
    }
    body.dark-mode #main-content {
        /* background-color: #555; */
    }

    /* 모든 요소에 공통 적용 - Firefox */
    body.dark-mode * {
        scrollbar-width: thin;                /* 얇은 스크롤바 */
        scrollbar-color: #555 #1e1e1e;        /* thumb, track 순 */
    }

    /* 모든 요소에 공통 적용 - Chrome, Edge, Safari */
    body.dark-mode *::-webkit-scrollbar {
        width: 8px;
        height: 8px;
    }

    body.dark-mode *::-webkit-scrollbar-thumb {
        background-color: #555;               /* 스크롤 막대 (thumb) 색상 */
        border-radius: 4px;
        border: 2px solid transparent;        /* padding-like 효과 */
        background-clip: content-box;
    }

    body.dark-mode *::-webkit-scrollbar-track {
        background-color: #1e1e1e;            /* 트랙 배경 */
    }

    /* 다크모드 토글 버튼 위치 및 스타일 */
    .theme-toggle-btn {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 8px 14px;
        font-size: 14px;
        color: #fff;
        background-color: #007bff;
        border: 1px solid #007bff;
        border-radius: 6px;
        transition: background-color 0.3s ease;
    }

    .theme-toggle-btn:hover {
        background-color: #0056b3;
        border-color: #0056b3;
    }

    .theme-toggle-btn .icon {
        display: inline-block;
        font-size: 16px;
        transition: transform 0.3s ease;
    }

    .theme-toggle-btn.dark {
        color: #555;
        background-color: #254f73;
        border: 1px solid #555;
    }

    .theme-toggle-btn.dark:hover {
        border-color: #0056b3;
    }

    .theme-toggle-btn.dark .icon {
        transform: rotate(180deg);
    }
</style>

<script>
    $(document).ready(function () {
        var $themeLinks = $('.theme-link');

        var $toggleBtn = $(`
        <button id="darkModeToggle" class="btn theme-toggle-btn">
            <span class="icon">🌙</span>
            <span class="label">다크모드</span>
        </button>
    `);

        $('header').append($toggleBtn);
        var $icon = $toggleBtn.find('.icon');
        var $label = $toggleBtn.find('.label');

        function applyThemeFromStorage() {
            var theme = localStorage.getItem('theme') || 'light';

            $themeLinks.each(function () {
                var $link = $(this);
                var href = $link.attr('href');

                if (theme === 'dark') {
                    if (!href.includes('-dark.css')) {
                        $link.attr('href', href.replace('.css', '-dark.css'));
                    }
                } else {
                    $link.attr('href', href.replace('-dark.css', '.css'));
                }
            });

            if (theme === 'dark') {
                $label.text('라이트모드');
                $icon.text('☀️');
                $toggleBtn.addClass('dark');
                $('body').addClass('dark-mode');
            } else {
                $label.text('다크모드');
                $icon.text('🌙');
                $toggleBtn.removeClass('dark');
                $('body').removeClass('dark-mode');
            }
        }

        $toggleBtn.on('click', function () {
            var isDark = localStorage.getItem('theme') === 'dark';

            $themeLinks.each(function () {
                var $link = $(this);
                var href = $link.attr('href');

                if (isDark) {
                    // 다크 → 라이트
                    $link.attr('href', href.replace('-dark.css', '.css'));
                } else {
                    // 라이트 → 다크
                    if (!href.includes('-dark.css')) {
                        $link.attr('href', href.replace('.css', '-dark.css'));
                    }
                }
            });

            if (isDark) {
                $label.text('다크모드');
                $icon.text('🌙');
                $toggleBtn.removeClass('dark');
                $('body').removeClass('dark-mode');
                localStorage.setItem('theme', 'light');
            } else {
                $label.text('라이트모드');
                $icon.text('☀️');
                $toggleBtn.addClass('dark');
                $('body').addClass('dark-mode');
                localStorage.setItem('theme', 'dark');
            }
        });

        applyThemeFromStorage();
    });
</script>
