<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
    $(document).ready(function () {
        loadSAPConnInfo();

        //sap connector info 로컬스토리지 저장
        const $sapConInfo = $('input[name=ashost], input[name=sysnr], input[name=client], input[name=user], input[name=passwd], input[name=lang], input[name=rfcfnc]');
        $sapConInfo.on('input change', function () {
            const key = this.name;
            const value = this.value;

            localStorage.setItem(key, value);
        });
    })

    //테이블 파라미터 필드값 동기화
    $(document).on('input', 'input[name="tbParamKey"]', function () {
        const $input = $(this);
        const trIndex = $input.closest('tr').index();
        const inputName = $input.attr('name');
        const $middleBox = $input.closest('.middle-box');
        const value = $input.val();
        $middleBox.find('.row-index').each(function () {
            const $targetTr = $(this).find('tbody tr').eq(trIndex);
            const $targetInput = $targetTr.find(`input[name="\${inputName}"]`);

            // 자기 자신 제외 (무한루프 방지)
            if (!$targetInput.is($input)) {
                $targetInput.val(value);
            }
        });
    });

    //테이블 파라미터 필드의 Type값 동기화
    function setParamType(el, typeValue) {

        const $span = $(el);
        const trIndex = $span.closest('tr').index();
        const $middleBox = $span.closest('.middle-box');

        $middleBox.find('.row-index').each(function () {

            const $targetSpan = $(this)
                .find('tbody tr')
                .eq(trIndex)
                .find('span.paramType');

            $targetSpan.html(typeValue);
        });
    }

    /*
    // 예: KEY 입력 시 타입 계산해서 반영
function calculateType(el) {

    const type = 'VARCHAR(100)'; // 예시
    const $span = $(el).closest('tr').find('span.paramType');

    setParamType($span, type);
}


     */


    //IMPORT 스칼라 파라미터 필드 추가
    function addSCField() {
        let field = `
            <tr>
                <td><input type="text" name="scParamKey" style="width:100%"></td>
                <td><input type="text" name="scParamValue" style="width:100%"></td>
                <td><span name="scParamType" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSCField()">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)">-</button>
                </td>
            </tr>
        `;
        $("#scalaTable tbody").append(field);
    }

    let stIndex = 0;
    //IMPORT 구조체 파라미터 추가
    function addST() {
        stIndex++;
        let structure = `
            <div class="inner-box">
                <div style="margin-bottom:10px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="structureNm" class="text-label">
                        <input style="width: 300px;" type="text" name="structureNm">
                    </label>
                    <button type="button" class="btn" onclick="delST(this)">X</button>
                </div>
                <table id="structureTable_\${stIndex}">
                    <colgroup>
                        <col style="width:35%" />
                        <col style="width:35%" />
                        <col style="width:10%" />
                        <col style="width:20%" />
                    </colgroup>
                    <thead>
                    <tr>
                        <th>KEY</th>
                        <th>VALUE</th>
                        <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="text" name="stParamKey" style="width:100%"></td>
                        <td><input type="text" name="stParamValue" style="width:100%"></td>
                        <td><span name="stParamType" class="paramType"></span></td>
                        <td>
                            <button type="button" name="btnAdd" class="btn" onclick="addSTField(\${stIndex})">+</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        `;

        $("#structureContainer").append(structure);
    }

    //IMPORT 구조체 파라미터 필드 추가
    function addSTField(index) {
        let field = `
            <tr>
                <td><input type="text" name="stParamKey" style="width:100%"></td>
                <td><input type="text" name="stParamValue" style="width:100%"></td>
                <td><span name="stParamType" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSTField(\${index})">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)">-</button>
                </td>
            </tr>
        `;
        $(`#structureTable_\${index} tbody`).append(field);
    }

    //EXPORT 스칼라 파라미터 필드 추가
    function addSCFieldEX() {
        let field = `
            <tr>
                <td><input type="text" name="scParamKeyEX" style="width:100%"></td>
                <td><input type="text" name="scParamValueEX" style="width:100%"></td>
                <td><span name="scParamTypeEX" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSCFieldEX()">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)">-</button>
                </td>
            </tr>
        `;
        $("#scalaTableEX tbody").append(field);
    }

    let stEXIndex = 0;
    //EXPORT 구조체 파라미터 추가
    function addSTEX() {
        stEXIndex++;
        let structure = `
            <div class="inner-box">
                <div style="margin-bottom:10px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="structureNmEX" class="text-label">
                        <input style="width: 300px;" type="text" name="structureNmEX">
                    </label>
                    <button type="button" class="btn" onclick="delST(this)">X</button>
                </div>
                <table id="structureTableEX_\${stEXIndex}">
                    <colgroup>
                        <col style="width:35%" />
                        <col style="width:35%" />
                        <col style="width:10%" />
                        <col style="width:20%" />
                    </colgroup>
                    <thead>
                    <tr>
                        <th>KEY</th>
                        <th>VALUE</th>
                        <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="text" name="stParamKeyEX" style="width:100%"></td>
                        <td><input type="text" name="stParamValueEX" style="width:100%"></td>
                        <td><span name="stParamTypeEX" class="paramType"></span></td>
                        <td>
                            <button type="button" name="btnAdd" class="btn" onclick="addSTEXField(\${stEXIndex})">+</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        `;

        $("#structureContainerEX").append(structure);
    }

    //EXPORT 구조체 파라미터 필드 추가
    function addSTEXField(index) {
        let field = `
            <tr>
                <td><input type="text" name="stParamKeyEX" style="width:100%"></td>
                <td><input type="text" name="stParamValueEX" style="width:100%"></td>
                <td><span name="stParamTypeEX" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSTEXField(\${index})">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)">-</button>
                </td>
            </tr>
        `;
        $(`#structureTableEX_\${index} tbody`).append(field);
    }

    //TABLE 파라미터 추가
    function addTable() {
        let table = `
        <div class="middle-box" style="display: block;">
            <div class="box-title">
                <div style="margin-bottom:10px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="tableNm" class="text-label">
                        <input style="width: 300px;" type="text" name="tableNm">
                    </label>
                    <button type="button" class="btn" onclick="addTableRow(this)">+ROW</button>
                    <button type="button" class="btn" onclick="delTable(this)">X</button>
                </div>
            </div>
            <div class="row-index">
                <div class="box-title">
                    <span class="row-label" style="margin: 5px;">Row1</span>
                    <button type="button" class="btn" onclick="delTableRow(this)">X</button>
                </div>
                <div class="inner-box">
                    <table>
                        <colgroup>
                            <col style="width:35%" />
                            <col style="width:35%" />
                            <col style="width:10%" />
                            <col style="width:20%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="tbParamKey" style="width:100%"></td>
                            <td><input type="text" name="tbParamValue" style="width:100%"></td>
                            <td><span name="tbParamType" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)">+</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        `;

        $("#tableContainer").append(table);
    }

    //TABLE 파라미터 Row 추가
    function addTableRow(el) {
        const $table = $(el).closest('.middle-box');
        let $row = $table.find('.row-index').first().clone(true);

        if ($row.length === 0) {
            $row = $(`
            <div class="row-index">
                <div class="box-title">
                    <span class="row-label" style="margin: 5px;">Row1</span>
                    <button type="button" class="btn" onclick="delTableRow(this)">X</button>
                </div>
                <div class="inner-box">
                    <table>
                        <colgroup>
                            <col style="width:35%" />
                            <col style="width:35%" />
                            <col style="width:10%" />
                            <col style="width:20%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="tbParamKey" style="width:100%"></td>
                            <td><input type="text" name="tbParamValue" style="width:100%"></td>
                            <td><span name="tbParamType" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)">+</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            `);
        }

        $row.find('input[name="tbParamValue"]').val('');    // 파라미터 key와 데이터타입만 클론하고 value는 빈값으로 생성

        $table.append($row);
        renumberRows($table);
    }

    function renumberRows($table) {
        $table.find('.row-label').each(function (idx) {
            $(this).text('Row' + (idx + 1));
        });
    }

    //TABLE 파라미터 필드 추가
    function addTableField(el) {
        let field = `
        <tr>
            <td><input type="text" name="tbParamKey" style="width:100%"></td>
            <td><input type="text" name="tbParamValue" style="width:100%"></td>
            <td><span name="tbParamType" class="paramType"></span></td>
            <td>
                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)">+</button>
                <button type="button" name="btnDel" class="btn" onclick="delTableField(this)">-</button>
            </td>
        </tr>
        `;

        const $table = $(el).closest(".middle-box");
        $table.find('table tbody').each(function (idx) {
            $(this).append(field);
        })
    }

    //파라미터 필드 삭제
    function delField(el) {
        $(el).closest("tr").remove();
    }

    //구조체 파라미터 삭제
    function delST(el) {
        $(el).closest(".inner-box").remove();
    }

    //테이블 파라미터 삭제
    function delTable(el) {
        $(el).closest(".middle-box").remove()
    }

    //테이블 Row 삭제
    function delTableRow(el) {
        const $table = $(el).closest(".middle-box");
        $(el).closest(".row-index").remove();
        renumberRows($table);
    }

    //테이블 파라미터 필드 삭제
    function delTableField(el) {
        const $currentTr = $(el).closest('tr');

        const trIndex = $currentTr.index();

        const $middleBox = $(el).closest('.middle-box');

        $middleBox.find('.row-index').each(function () {
            const $tbody = $(this).find('tbody');
            const $rows = $tbody.find('tr');

            if ($rows.length > trIndex) {
                $rows.eq(trIndex).remove();
            }
        });
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

    function getSAPMeta() {
        //TODO: trim할것들 하기

        myAxios.post(
            "/dev/getSAPMeta",
            {
                ashost: $("input[name=ashost]").val(),
                sysnr: $("input[name=sysnr]").val(),
                client: $("input[name=client]").val(),
                user: $("input[name=user]").val(),
                passwd: $("input[name=passwd]").val(),
                lang: $("input[name=lang]").val(),
                functionName: $("input[name=rfcfnc]").val()
            },
            {
                beforeSend: function () {
                    showSpinner("RFC MetaData 수집중...");
                },
                complete: function () {
                    hideSpinner();
                }
            }
        )
        .then(res => {
            const data = res.data;

            if (data.status == "ERROR") {
                $("#parsedJson").html(`<div class='error'>오류 발생: [\${data.status}]::\${data.errKey ? data.errKey : ''} <br><br> 에러메세지: \${data.message ? data.message : ''} <br><br> 원인: \${data.detailMessage ? data.detailMessage : ''}</div>`);
                return;
            }

            const functionName = data.functionName;
            const importParams = data.importParams;
            const exportParams = data.exportParams;
            const tableParams = data.tableParams;

        })
        .catch(error => {
            $("#parsedJson").html(`<div class='error'>오류 발생: [\${error.status ? error.status : ''}] <br><br> 에러메세지: \${error.message ? error.message : ''}</div>`);
        });
    }

    function toggleParamBox(el) {
        const $outer = $(el).closest('.outer-box');
        const $header = $(el).closest('.section-header');

        $outer.find('.middle-box').slideToggle(200);

        $header.find('button').toggle();

        $(el).toggleClass('open');
    }

    function callRFC() {
        //TODO: trim할것들 하기

        //Import파라미터 자료구조 생성
        let importParams = {};
        $("#paramTable tbody tr").each(function() {
            let key = $(this).find("input[name=paramKey]").val().trim();
            let value = $(this).find("input[name=paramValue]").val().trim();

            if (key.length > 0) {
                importParams[key] = value;
            }
        });

        //Table 자료구조 생성
        let tableParams = {};
        $("#tableContainer .table-wrapper").each(function () {

            let tableName = $(this).find("input[name=tableName]").val().trim();
            if (tableName.length === 0) return;

            let tableRows = [];
            let currentRow = {};

            $(this).find("tbody tr").each(function () {
                let key = $(this).find("input[name=tableKey]").val().trim();
                let value = $(this).find("input[name=tableValue]").val().trim();

                if (key.length > 0) {
                    currentRow[key] = value;
                }

                if (Object.keys(currentRow).length > 0) {
                    tableRows.push(currentRow);
                    currentRow = {};
                }
            });

            if (tableRows.length > 0) {
                tableParams[tableName] = tableRows;
            }
        });

        myAxios.post(
            "/dev/callRFC",
            {
                ashost: $("input[name=ashost]").val(),
                sysnr: $("input[name=sysnr]").val(),
                client: $("input[name=client]").val(),
                user: $("input[name=user]").val(),
                passwd: $("input[name=passwd]").val(),
                lang: $("input[name=lang]").val(),
                functionName: $("input[name=rfcfnc]").val(),
                params: JSON.stringify(importParams),
                tables: JSON.stringify(tableParams)
            },
            {
                beforeSend: function () {
                    showSpinner("얌전히 기다려라");
                },
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            }
        )
        .then(res => {
            const data = res.data;
            const jsonStrResult = JSON.stringify(res.data.result);

            if (data.status == "ERROR") {
                $("#parsedJson").html(`<div class='error'>오류 발생: [\${data.status}]::\${data.errKey ? data.errKey : ''} <br><br> 에러메세지: \${data.message ? data.message : ''} <br><br> 원인: \${data.detailMessage ? data.detailMessage : ''}</div>`);
                return;
            }

            $("#parsedJson").html(jsonStrResult);
            if ($("#kind").val() === 'JPP' || $("#kind").val() === 'XPP') {
                $('.result-container').css('white-space', 'nowrap');
                parseJson(jsonStrResult);
            }
        })
        .catch(error => {
            $("#parsedJson").html(`<div class='error'>오류 발생: [\${error.status ? error.status : ''}] <br><br> 에러메세지: \${error.message ? error.message : ''}</div>`);
        })
        .finally(() => {
            hideSpinner();
        });
    }

    function parseJson(data) {
        $.ajax({
            url: "/dev/convert",
            type: "POST",
            contentType: "application/json;charset=UTF-8",
            data: JSON.stringify({
                inputString: data,
                kind: $("#kind").val()
            }),
            async: false,
            success: function(data){
                $('.result-container').css('white-space', 'nowrap');
                $("#parsedJson").html(data);

                showIndentLine();
            },
            error: function(response, status, error){
                $("#parsedJson").html(`<div class='error'>오류 발생: [\${status}]:: <br> \${response} <br> \${error}</div>`);
                alert('파싱 중 오류가 발생했습니다: ' + error);
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

    function loadSAPConnInfo() {
        const ashost = localStorage.getItem('ashost');
        const sysnr = localStorage.getItem('sysnr');
        const client = localStorage.getItem('client');
        const user = localStorage.getItem('user');
        const passwd = localStorage.getItem('passwd');
        const lang = localStorage.getItem('lang');
        const rfcfnc = localStorage.getItem('rfcfnc');

        if (ashost !== null && ashost.trim() !== '') {
            $("input[name=ashost]").val(ashost);
        }
        if (sysnr !== null && sysnr.trim() !== '') {
            $("input[name=sysnr]").val(sysnr);
        }
        if (client !== null && client.trim() !== '') {
            $("input[name=client]").val(client);
        }
        if (user !== null && user.trim() !== '') {
            $("input[name=user]").val(user);
        }
        if (passwd !== null && passwd.trim() !== '') {
            $("input[name=passwd]").val(passwd);
        }
        if (lang !== null && lang.trim() !== '') {
            $("input[name=lang]").val(lang);
        }
        if (rfcfnc !== null && rfcfnc.trim() !== '') {
            $("input[name=rfcfnc]").val(rfcfnc);
        }
    }

    function showIndentLine() {
        const saturation = localStorage.getItem('saturation-value');
        const lightness = localStorage.getItem('lightness-value');
        const alpha = localStorage.getItem('alpha-value');
        const border = localStorage.getItem('border-value');
        const style = localStorage.getItem('border-style');
        const color = localStorage.getItem('border-color');

        const isShow = true;
        const hueStep = 37;

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
                <label for="kind" class="select-label">Choose Option
                    <select id="kind" class="select-inline">
                        <option value="JPP">JSON</option>
                        <option value="XPP">XML</option>
                        <option value="PT">Plain Text</option>
                    </select>
                </label>
                <button class="btn" id="rfcCall" onclick="callRFC()">CALL</button>
            </span>
        </div>

        <div style="margin-top: 70px;">
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">ASHOST :</span>
                <input style="width: 300px;" type="text" name="ashost" value="">
            </div>
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">SYSNR :</span>
                <input style="width: 300px;" type="text" name="sysnr" value="">
            </div>
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">CLIENT :</span>
                <input style="width: 300px;" type="text" name="client" value="">
            </div>
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">USER :</span>
                <input style="width: 300px;" type="text" name="user" value="">
            </div>
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">PASSWD :</span>
                <input style="width: 300px;" type="text" name="passwd" value="">
            </div>
            <div style="margin-bottom: 10px;">
                <span style="margin: 5px; display: inline-block; width:80px;">LANG :</span>
                <input style="width: 300px;" type="text" name="lang" placeholder="미입력시 기본값 'KO'">
            </div>
        </div>

        <div style="margin-top: 20px;">
            <span style="margin: 5px; width:200px;">RFC FUNCTION :</span>
            <label for="rfcfnc" class="text-label">
                <input style="width: 300px;" type="text" name="rfcfnc" value="">
            </label>
        </div>

        <div style="margin-top: 20px; text-align: center">
            <button class="btn" style="width: 80%;" id="getSAPMeta" onclick="getSAPMeta()">GET RFC METADATA</button>
        </div>

        <!-- IMPORT파라미터 시작-->
        <div class="outer-box">
            <div class="section-header">
                <span onclick="toggleParamBox(this)">IMPORT</span>
            </div>
            <!-- 스칼라 파라미터 시작-->
            <div class="middle-box" id="scalaContainer">
                <div class="box-title">
                    <span style="margin: 5px;">SCALA</span>
                </div>
                <div class="inner-box">
                    <table id="scalaTable">
                        <colgroup>
                            <col style="width:35%" />
                            <col style="width:35%" />
                            <col style="width:10%" />
                            <col style="width:20%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="scParamKey" style="width:100%"></td>
                            <td><input type="text" name="scParamValue" style="width:100%"></td>
                            <td><span name="scParamType" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addSCField()">+</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- 스칼라 파라미터 끝-->
            <!-- 구조체 파라미터 시작-->
            <div class="middle-box" id="structureContainer">
                <div class="box-title">
                    <span style="margin: 5px;">STRUCTURE</span>
                    <button type="button" class="btn" onclick="addST()">+</button>
                </div>
            </div>
            <!-- 구조체 파라미터 끝-->
        </div>
        <!-- IMPORT파라미터 끝-->

        <!-- TABLE파라미터 시작-->
        <div class="outer-box" id="tableContainer">
            <div class="section-header">
                <span onclick="toggleParamBox(this)">TABLE</span>
                <button type="button" class="btn" style="float: right; display: none;" onclick="addTable()">+ TABLE</button>
            </div>
        </div>
        <!-- TABLE파라미터 끝-->

        <!-- EXPORT파라미터 시작-->
        <div class="outer-box">
            <div class="section-header">
                <span onclick="toggleParamBox(this)">EXPORT</span>
            </div>
            <!-- 스칼라 파라미터 시작-->
            <div class="middle-box" id="scalaContainerEX">
                <div class="box-title">
                    <span style="margin: 5px;">SCALA</span>
                </div>
                <div class="inner-box">
                    <table id="scalaTableEX">
                        <colgroup>
                            <col style="width:35%" />
                            <col style="width:35%" />
                            <col style="width:10%" />
                            <col style="width:20%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>Type(len/dec)</th>  <!-- 타입(길이/소수점(decimals))-->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="scParamKeyEX" style="width:100%"></td>
                            <td><input type="text" name="scParamValueEX" style="width:100%"></td>
                            <td><span name="scParamTypeEX" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addSCFieldEX()">+</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- 스칼라 파라미터 끝-->
            <!-- 구조체 파라미터 시작-->
            <div class="middle-box" id="structureContainerEX">
                <div class="box-title">
                    <span style="margin: 5px;">STRUCTURE</span>
                    <button type="button" class="btn" onclick="addSTEX()">+</button>
                </div>
            </div>
            <!-- 구조체 파라미터 끝-->
        </div>
        <!-- EXPORT파라미터 끝-->
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

