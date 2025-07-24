<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<script>
    function makeJsonSample() {
        const jsonSample = `{"user":{"id":101,"name":"홍길동","profile":{"contact":{"email":"hong@example.com","phone":null,"social":{"kakao":"hong123","github":"gildong","tags":[["dev","coder"],["blogger","writer",["nested1","nested2"]],null]}},"preferences":{"theme":"dark","language":"ko","notification":{"email":true,"sms":false,"push":{"enabled":true,"schedules":[[{"day":"Mon","time":"08:00"},{"day":"Fri","time":"18:00"}],[{"day":"Wed","time":"12:00"},null]]}}}}},"system":{"env":"production","meta":{"version":"6.0","timestamp":1718700000000,"history":{"created":{"at":"2023-12-01T12:00:00Z","by":{"id":"admin","roles":["creator",["superuser","owner"],null]}},"updated":{"at":null,"by":{"id":"editor","roles":[["moderator"],"reviewer"]}}}}}}`;

        $("#inputString").val(jsonSample);
    }
    
    function makeXMLSample() {
        const xmlSample = `<?xml version="1.0" encoding="UTF-8" standalone="no"?><rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0"> <channel> <title>Example News Feed</title> <link>https://news.example.com/</link> <description><![CDATA[ 최신 뉴스와 미디어 콘텐츠를 제공합니다. <special>중요 공지 포함</special> ]]></description> <item id="001" type="breaking"> <title>국제 정상회담 개최</title>형제태그가있어도 텍스트 가능<link/> <pubDate>1996-01-22</pubDate> <content:encoded><![CDATA[ <p>세계 정상들이 모여 다양한 이슈를 논의했습니다.</p> <p>협력과 평화가 강조되었습니다.</p> ]]></content:encoded> <media:thumbnail height="90" url="https://news.example.com/thumbs/summit.jpg" width="120"/> <details> <organizer country="KOR"> <name>대한민국 정부</name> <contact> <email>contact@korea.gov.kr</email> <phone>+82-2-1234-5678</phone> </contact> </organizer> </details> </item> <item id="002" type="update"> <title>유엔, 긴급회의 소집</title> <link>https://news.example.com/world/un-meeting</link> <pubDate>2000-01-01</pubDate> <content:encoded><![CDATA[ <p>유엔은 국제 분쟁 해결을 위해 긴급회의를 소집했다.</p> <ul> <li>의제 1: 무력 충돌 중단</li> <li>의제 2: 인도적 지원 확대</li> </ul> ]]></content:encoded> <media:thumbnail height="90" url="https://news.example.com/thumbs/ai.jpg" width="120"/> <details> <organizer country="USA"> <name>UN 안전 보장 이사회</name> <contact> <email>un안보리@un.org</email> <phone>+1-123-45-6789</phone> </contact> </organizer> </details> </item> </channel> </rss>`;

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

            // 3. 상태 저장
            $toggle.data('collapsed', false);
        }
    }

    function copyResult() {
        var element = document.getElementById('parsedJson');
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

<div class="container">
    <div class="left">
        <span style="float:right">
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
        <textarea id="inputString" name="inputString" spellcheck="false" placeholder="여기에 JSON 또는 XML 문자열을 입력하세요."></textarea><br>
        <span style="float:left">
            <button class="btn" onclick="makeJsonSample()">JSON Sample</button>
            <button class="btn" onclick="makeXMLSample()">XML Sample</button>
        </span>
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