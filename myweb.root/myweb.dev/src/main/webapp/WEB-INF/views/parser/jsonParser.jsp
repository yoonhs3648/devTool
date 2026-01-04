<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<script>

    $(document).ready(function () {
        loadLocalStorageData();

        function updateOptionalDisplay() {
            const color = $('input[name="borderColor"]:checked').val();
            if (color === "rainbow") {
                $('#optionalVal').css('display', 'block');
            } else {
                $('#optionalVal').css('display', 'none');
            }
        }
        $('input[name="borderColor"]').on('change', updateOptionalDisplay);
        updateOptionalDisplay();    //초기화

        const $checkbox = $('#indentLine');
        $checkbox.on('change', showIndentLine);

        const $sliders = $('#saturationSlider, #lightnessSlider, #alphaSlider, #borderSlider, input[name="borderStyle"], input[name="borderColor"]');
        $sliders.on('input', function() {
            const $this = $(this);
            const value = $this.val();
            const prop = $this.data('prop');

            // 현재 슬라이더에 대응하는 값 표시 영역 갱신 & 로컬스토리지 갱신
            if (prop === 's') {
                $('#saturation-value').text(value + '%');
                localStorage.setItem('saturation-value', value);
            } else if (prop === 'l') {
                $('#lightness-value').text(value + '%');
                localStorage.setItem('lightness-value', value);
            } else if (prop === 'a') {
                // Alpha는 소수점 2자리로 표시 (0.00 ~ 1.00)
                const alpha = (value / 100).toFixed(2);
                $('#alpha-value').text(alpha);
                localStorage.setItem('alpha-value', value);
            } else if (prop === 'b') {
                $('#border-value').text(value + 'px')
                localStorage.setItem('border-value', value);
            } else if (prop === 'bs') {
                localStorage.setItem('border-style', value);
            } else if (prop === 'bc') {
                localStorage.setItem('border-color', value);
            }

            if ($checkbox.is(':checked')) {
                showIndentLine()
            }
        });
    })

    //로컬스토리지에 저장된 indentline 속성값 가져오기
    function loadLocalStorageData() {
        const saturation = localStorage.getItem('saturation-value');
        const lightness = localStorage.getItem('lightness-value');
        const alpha = localStorage.getItem('alpha-value');
        const border = localStorage.getItem('border-value');
        const style = localStorage.getItem('border-style');
        const color = localStorage.getItem('border-color');

        if (saturation !== null) {
            $('#saturationSlider').val(saturation);
            $('#saturation-value').text(saturation + '%');
        }
        if (lightness !== null) {
            $('#lightnessSlider').val(lightness);
            $('#lightness-value').text(lightness + '%');
        }
        if (alpha !== null) {
            $('#alphaSlider').val(alpha);
            $('#alpha-value').text((alpha / 100).toFixed(2));
        }
        if (border !== null) {
            $('#borderSlider').val(border);
            $('#border-value').text(border + 'px');
        }
        if (style !== null) {
            $('input[name="borderStyle"][value="' + style + '"]').prop('checked', true);
        }
        if (color !== null) {
            $('input[name="borderColor"][value="' + color + '"]').prop('checked', true);
        }
    }

    function showLeftContainer(el) {
        var $left = $("#leftContainer");

        if ($left.hasClass("hidden-slide-left")) {
            $left.css("display", "block");
            setTimeout(function() {
                $left.removeClass("hidden-slide-left");
            }, 10);
            $(el).text("<");
        } else {
            $left.addClass("hidden-slide-left");
            $(el).text(">");
            setTimeout(function() {
                $left.css("display", "none");
            }, 300);
        }
    }

    function showIndentLine() {
        const $checkbox = $('#indentLine');
        const isShow = $checkbox.is(':checked');

        const hueStep = 37;
        const saturation = $('#saturationSlider').val() + '%';
        const lightness = $('#lightnessSlider').val() + '%';
        const alpha = ($('#alphaSlider').val() / 100).toFixed(2);
        const border = ($('#borderSlider').val()) + 'px';
        const style = $('input[name="borderStyle"]:checked').val();
        const color = $('input[name="borderColor"]:checked').val();

        if (isShow) {
            $('#hslaController').css('display', 'block');
        } else {
            $('#hslaController').css('display', 'none');
        }

        $('#parsedJson')
            .find('div') // 모든 하위 div
            .filter(function () {
                const id = $(this).attr('id');
                return /^\d+$/.test(id); // id가 숫자인 것만 필터
            })
            .each(function () {
                const id = $(this).attr('id');

                if (isShow) {
                    var hue = "";
                    hue = (((id - 1) * hueStep)) % 360;

                    /* hsla(H, S, L, A)
                        인자 |        명칭         |    값 범위    |           의미
                    1.  H           Hue (색상)        0 ~ 360     색상환에서의 위치. 0도(또는 360도)는 빨간색, 120도는 초록색, 240도는 파란색
                    2.  S       Saturation (채도)     0% ~ 100%   색상의 순수함 또는 강도. 100%는 순수한 색상, 0%는 회색
                    3.  L       Lightness (명도)      0% ~ 100%   색상의 밝기. 0%$ 검은색, 100%는 흰색이며, 50%일 때 가장 순수한 색상
                    4.  A       Alpha (투명도)        0.0 ~ 1.0    색상의 불투명도. 1.0은 완전 불투명(100%), 0.0은 완전 투명(0%)
                     */
                    if (color === "default"){
                        $(this).css('border-left', `\${border} \${style} #999999`);
                    } else {
                        $(this).css('border-left', `\${border} \${style} hsla(\${hue}, \${saturation}, \${lightness}, \${alpha})`);
                    }
                } else {
                    $(this).css('border-left', '');
                }
            });
    }

    function makeJsonSample() {
        const jsonSample = `{\"scalars\":{\"IV_MODE\":\"C\"},\"structures\":{\"IS_HEADER\":{\"BUKRS\":\"1000\",\"BUDAT\":\"20240115\",\"BLART\":\"SA\",\"WAERS\":\"KRW\",\"GWUID\":\"GW-20241201\"}},\"tables\":{\"IT_ITEM\":[{\"DOC_NO\":\"0001\",\"BUZEI\":\"001\",\"SHKZG\":\"S\",\"HKONT\":\"111100\",\"WRBTR\":\"100000\",\"SGTXT\":\"차변 테스트\"},{\"DOC_NO\":\"0001\",\"BUZEI\":\"002\",\"SHKZG\":\"H\",\"HKONT\":\"210000\",\"WRBTR\":\"100000\",\"SGTXT\":\"대변 테스트\"}]}}`;

        $("#inputString").val(jsonSample);
    }
    
    function makeXMLSample() {
        const xmlSample = `<?xml version="1.0" encoding="UTF-8" standalone="no"?><rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0"> <channel> <title>Example News Feed</title> <link>https://news.example.com/</link> <description><![CDATA[ 최신 뉴스와 미디어 콘텐츠를 제공합니다. ]]></description> <item id="001" type="breaking"> <title>국제 정상회담 개최</title>형제태그가있어도 텍스트 가능<link/> <pubDate>1996-01-22</pubDate> <content:encoded><![CDATA[ <p>세계 정상들이 모여 다양한 이슈를 논의했습니다.</p> <p>협력과 평화가 강조되었습니다.</p> ]]></content:encoded> <media:thumbnail height="90" url="https://news.example.com/thumbs/summit.jpg" width="120"/> <details> <organizer country="KOR"> <name>대한민국 정부</name> <contact> <email>contact@korea.gov.kr</email> <phone>+82-2-1234-5678</phone> </contact> </organizer> </details> </item> <item id="002" type="update"> <title>유엔, 긴급회의 소집</title> <link>https://news.example.com/world/un-meeting</link> <pubDate>2000-01-01</pubDate> <content:encoded><![CDATA[ <p>유엔은 국제 분쟁 해결을 위해 긴급회의를 소집했다.</p> <ul> <li>의제 1: 무력 충돌 중단</li> <li>의제 2: 인도적 지원 확대</li> </ul> ]]></content:encoded> <media:thumbnail height="90" url="https://news.example.com/thumbs/ai.jpg" width="120"/> <details> <organizer country="USA"> <name>UN 안전 보장 이사회</name> <contact> <email>un안보리@un.org</email> <phone>+1-123-45-6789</phone> </contact> </organizer> </details> </item> </channel> </rss>`;

        $("#inputString").val(xmlSample);
    }

    function parseJson() {

        $.ajax({
            url: "/dev/convert",
            type: "POST",
            contentType: "application/json;charset=UTF-8",
            data: JSON.stringify({
                inputString: $("#inputString").val(),
                kind: $("#kind").val()
            }),
            async: false,
            success: function(data){
                if ($("#kind").val() === 'JL' || $("#kind").val() === 'XL'){
                    $('.result-container').css('white-space', 'normal');    //linear는 자동줄바꿈
                    $("#parsedJson").text(data);
                }
                else {
                    $('.result-container').css('white-space', 'nowrap');    //prettyprint는 줄바꿈안함
                    $("#parsedJson").html(data);
                }

                showIndentLine();
            },
            error: function(response, status, error){
                $("#parsedJson").html(`<div class='error'>오류 발생: [${status}]:: ${response}\n${error}</div>`);
            }
        });
    }

    function toggle(el) {
        const $toggle = $(el); // 클릭한 toggle span
        const toggleId = $toggle.attr('id'); // 예: toggle_2
        const n = toggleId.split('_')[1]; // n = 2

        const $parentDiv = $('#' + n); // div id="2"
        const $childDivs = $parentDiv.children('div');
        const $otherDivs = $childDivs.slice(1); // 첫 번째 제외 나머지 div ( 객체 또는 배열의 닫는 } 또는 ] 가 마지막 div)

        const $hideSpan = $('#hide_' + n);
        const $bracketSpan = $('#bracket_' + n);
        const $img = $toggle.find('img')

        const isCollapsed = !$toggle.data('collapsed'); // 초기 상태는 펼쳐진 상태

        if (isCollapsed) {
            // 펼침 -> 접기

            // 1. 아이콘 변경
            const src = $img.attr('src');
            const newSrc = src.replace('minus', 'plus');
            $img.attr('src', newSrc);

            // 2. div 숨기기
            $otherDivs.hide();

            // 3. 숨긴 개수 표시
            const type = $toggle.data('type');
            if (type === 'array') {
                $hideSpan.text('[' + ($otherDivs.length - 1) + ']').css('display', 'inline');
            }

            // 4. bracket 텍스트 설정
            if (type === 'object') {
                $bracketSpan.text('{ ... }');
            } else if (type === 'array') {
                $bracketSpan.text('[ ... ]');
            }

            // 5. 상태 저장
            $toggle.data('collapsed', true);
        } else {
            // 접힘 -> 다시 펼침

            // 1. 아이콘 변경
            const src = $img.attr('src');
            const newSrc = src.replace('plus', 'minus');
            $img.attr('src', newSrc);

            // 2. div 펼치기
            $otherDivs.show();

            // 3. 숨긴 개수 표시 삭제
            $hideSpan.text('').css('display', 'none');

            // 4. bracket 텍스트 원복
            const type = $toggle.data('type');
            if (type === 'object') {
                $bracketSpan.text('{');
            } else if (type === 'array') {
                $bracketSpan.text('[');
            }

            // 5. 상태 저장
            $toggle.data('collapsed', false);
        }
    }

    function xmlToggle(el) {
        const $toggle = $(el);
        const toggleId = $toggle.attr('id');
        const n = toggleId. split('_')[1];

        const $childDiv = $('#' + n);
        const $hideDiv = $('#hide_' + n);
        const $hideSpan = $('#collapsed_' + n);

        const isCollapsed = !$toggle.data('collapsed');

        if (isCollapsed) {
            // 펼침 -> 접기

            // 1. 자식노드 숨기기
            $childDiv.hide();

            // 2. 숨김 텍스트 표시
            $hideDiv.show();
            $hideSpan.text('...');

            // 3. 상태 저장
            $toggle.data('collapsed', true);
        } else {
            // 접힘 -> 다시 펼침

            // 1. 자식노드 펼치기
            $childDiv.show();

            // 2. 숨김 텍스트 없애기
            $hideDiv.hide();
            $hideSpan.text('');

            // 3. 상태 저장
            $toggle.data('collapsed', false);
        }
    }

    function copyResult() {
        const element = $('#parsedJson');
        const kind = $('#kind').val();

        //접혀있는 영역을 찾아서 복사전 펼치기
        const collapsedEl = [];

        if (kind === "JPP" || kind === "XPP") {
            element.find('span').each(function() {
                const $el = $(this);
                if ($el.data('collapsed') === true) {
                    collapsedEl.push(this);
                    kind === "JPP" ? toggle(this) : xmlToggle(this);
                }
            });
        }

        const text = element.text().trim();
        if (!text || element.find('.error').length > 0) {
            return; //빈영역이거나 파싱에러일 경우 복사하지 않음
        }

        let tempTextarea = null;
        try {
            let formattedText = '';

            if (kind === 'JPP') {
                const json = JSON.parse(text);
                formattedText = JSON.stringify(json, null, '\t');
            } else if (kind === 'XPP') {
                formattedText = formatXml(text);
            } else {
                formattedText = text;
            }

            tempTextarea = document.createElement('textarea');
            tempTextarea.value = formattedText; // 줄바꿈/탭 그대로
            document.body.appendChild(tempTextarea);

            //why? 만약 parsedJson영역에 사용자가 드래그를 해논경우 문제가 발생함. 처리 개선을 위해서 영역 초기화
            const selection = window.getSelection();  //선택된 영역(사용자가 브라우저 화면에서 드래그한 텍스트)을 가져옴
            selection.removeAllRanges();            //해당 선택된 영역을 해제 (복사전 불필요한 선택 제거)

            tempTextarea.select();  //선택범위 지정

            const success = document.execCommand('copy'); //선택된 범위를 클립보드로 복사
            if (success) {
                showCopySuccessMessage();
            } else {
                alert('복사에 실패했습니다...');
            }
        } catch (err) {
            alert('복사 중 오류가 발생했습니다: ' + err);
        } finally {
            //selection.removeAllRanges();    //선택영역 해제
            if (tempTextarea && tempTextarea.parentNode) {
                document.body.removeChild(tempTextarea);    //임시 DOM 제거
                tempTextarea = null;
            }
        }

        //접혀있다가 펼친 엘리먼트 다시 접기
        collapsedEl.forEach(function(el) {
            kind === "JPP" ? toggle(el) : xmlToggle(el);
        })
    }

    function formatXml(xml) {
        const PADDING = '\t';
        let formatted = "";
        let pad = 0;

        //빈 태그 사이의 공백과 줄바꿈을 제거
        xml = xml.replace(/(<(\w[^>]*?)>)\s*(<\/\2>)/g, '$1$3');

        //모든 '>'와 '<' 사이에 줄바꿈을 삽입
        //여는 태그와 닫는 태그가 연달아 올 때만 분리 (Self-closing 태그가 아닌 일반 태그만 분리)
        const reg = /(>)\s*(<)(\/*)/g;

        xml = xml.replace(reg, "$1\r\n$2$3");
        xml = xml.replace(/(<(\w[^>]*?)>)\r\n(<\/\2>)/g, '$1$3');


        //들여쓰기 적용
        xml.split("\r\n").forEach((node) => {
            let text = node.trim();

            if (text.length === 0) return; // 빈 줄 스킵

            //순수 텍스트 노드 또는 주석은 들여쓰기 레벨을 변경하지 않고 출력
            if (!text.match(/^<[\/\w]/)) {
                formatted += PADDING.repeat(pad) + text + "\r\n";
                return;
            }

            //닫는태그는 레벨을 먼저 감소시킨 후 출력
            const isSelfContained = text.includes('</') && !text.match(/^<\/\w/);

            if (text.match(/^<\/\w/)) {
                if (pad > 0) {
                    pad -= 1;
                }
            }

            // 들여쓰기를 추가하고 현재 노드를 출력
            formatted += PADDING.repeat(pad) + text + "\r\n";

            //여는태그는 출력 후에 레벨을 증가시킨다
            if (text.match(/^<\w[^>]*[^/]>$/) && !isSelfContained) {
                pad += 1;
            }
        });

        return formatted.trim();
    }

    //navigator.clipboard API는 보안 컨텍스트(https 또는 localhost)에서만 동작한다
    /*
    function copyResult() {
        const targetText = $('#parsedJson').text();

        navigator.clipboard.writeText(targetText)
            .then(() => showCopySuccessMessage())
            .catch(err => alert('복사 중 오류가 발생했습니다: ' + err));
    }
    */

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

<div class="container">
    <div class="left" id="leftContainer">
        <div>
            <span style="float: right;">
                <label for="indentLine" class="checkbox-label">
                    <input type="checkbox" id="indentLine" value="indentLine" checked>
                    indent Line
                </label>
                <label for="kind" class="select-label">Choose Option
                <select id="kind" class="select-inline">
                    <option value="JPP">JSON Pretty Print</option>
                    <option value="JL">JSON Linearize</option>
                    <option value="XPP">XML Pretty Print</option>
                    <option value="XL">XML Linearize</option>
                </select>
                </label>
                <button class="btn" onclick="parseJson()">Convert</button>
            </span>
        </div>
        <div>
            <textarea id="inputString" name="inputString" spellcheck="false" placeholder="여기에 JSON 또는 XML 문자열을 입력하세요."></textarea>
        </div>
        <div>
            <span>
                <button class="btn" onclick="makeJsonSample()" style="display: none;">JSON Sample</button>
                <button class="btn" onclick="makeXMLSample()" style="display: none;">XML Sample</button>
            </span>
        </div>
        <div class="hsla-controller" id="hslaController" style="margin-top: 10px;">
            <div>
                <span>SLA 설정</span>
            </div>
            <div class="slider-group">
                <label>라인 종류(Border Style):</label>
                <div class="radio-group horizontal">
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="solid" data-prop="bs" checked> Solid
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="dotted" data-prop="bs"> Dotted
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="dashed" data-prop="bs"> Dashed
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="double" data-prop="bs"> Double
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="groove" data-prop="bs"> Groove
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderStyle" value="ridge" data-prop="bs"> Ridge
                    </label>
                </div>
            </div>
            <div class="slider-group">
                <label for="borderSlider">라인 두께(Border): <span id="border-value">1px</span></label>
                <input type="range" class="border-slider" id="borderSlider" min="0" max="5" step="0.5" value="1" data-prop="b">
            </div>
            <div class="slider_group">
                <label>라인 컬러(Border Color)</label>
                <div class="radio-group horizontal">
                    <label class="radio-label">
                        <input type="radio" name="borderColor" value="default" data-prop="bc" checked> Default
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="borderColor" value="rainbow" data-prop="bc"> Rainbow
                    </label>
                </div>
            </div>
            <div id="optionalVal" style="display: none;">
                <div class="slider-group">
                    <label for="saturationSlider">채도(Saturation): <span id="saturation-value">70%</span></label>
                    <input type="range" class="saturation-slider" id="saturationSlider" min="0" max="100" value="70" data-prop="s">
                </div>
                <div class="slider-group">
                    <label for="lightnessSlider">명도(Lightness): <span id="lightness-value">50%</span></label>
                    <input type="range" class="lightness-slider" id="lightnessSlider" min="0" max="100" value="50" data-prop="l">
                </div>
                <div class="slider-group">
                    <label for="alphaSlider">투명도(Alpha): <span id="alpha-value">1.00</span></label>
                    <input type="range" class="alpha-slider" id="alphaSlider" min="0" max="100" value="100" data-prop="a">
                </div>
            </div>
        </div>
    </div>
    <div class="middle">
        <button class='hide-btn' style="width:15px;" onclick="showLeftContainer(this)"><</button>
    </div>
    <div class="right" id="result">
        <div class="copy-success-message" id="copy-success-message">✅ 복사 완료</div>
        <div class="result-wrapper">
            <button class="copy-btn" onclick="copyResult()">복사</button>
            <!-- 결과 -->
            <div id="parsedJson" class="result-container"></div>
        </div>
    </div>
</div>