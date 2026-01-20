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

    //Description 툴팁
    let tooltipEl = null;
    $(document).on('mouseenter', '.fieldTooltip', function (e) {
        const text = $(this).text().trim();
        if (!text) return;  //description 없으면 리턴

        tooltipEl = $('<div class="custom-tooltip"></div>')
            .text(text)
            .appendTo('body');

        moveTooltip(e);
    });

    $(document).on('mousemove', '.fieldTooltip', function (e) {
        moveTooltip(e);
    });

    $(document).on('mouseleave', '.fieldTooltip', function () {
        if (tooltipEl) {
            tooltipEl.remove();
            tooltipEl = null;
        }
    });

    function moveTooltip(e) {
        if (!tooltipEl) return;

        tooltipEl.css({
            top: e.clientY - 35,
            left: e.clientX + 10
        });
    }

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

    //IMPORT 스칼라 파라미터 필드 추가
    function addSCField() {
        let field = `
            <tr>
                <td><input type="text" name="scParamKey" style="width:100%"></td>
                <td><input type="text" name="scParamValue" style="width:100%"></td>
                <td><span name="scParamDesc" class="paramType fieldTooltip"></span></td>
                <td><span name="scParamType" class="paramType"></span></td>
                <td><span name="scParamLength" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSCField()" tabindex="-1">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)" tabindex="-1">-</button>
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
                <div style="margin-bottom:15px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="structureNm" class="text-label">
                        <input style="width: 300px;" type="text" name="structureNm">
                    </label>
                    <button type="button" class="btn" onclick="delST(this)" tabindex="-1">X</button>
                </div>
                <div style="margin-bottom:10px;">
                    <span name="imStDesc" style="margin: 5px; width:200px;"></span>
                </div>
                <table id="structureTable_\${stIndex}" name="structureTable" style="table-layout: fixed; width: 100%;">
                    <colgroup>
                        <col style="width:20%" />
                        <col style="width:25%" />
                        <col style="width:15%" />
                        <col style="width:10%" />
                        <col style="width:10%" />
                        <col style="width:20%" />
                    </colgroup>
                    <thead>
                    <tr>
                        <th>KEY</th>
                        <th>VALUE</th>
                        <th>DECS</th>  <!-- 주석 -->
                        <th>TYPE</th>  <!-- 데이터 타입 -->
                        <th>LEN</th>   <!-- 길이(+소수점) -->
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="text" name="stParamKey" style="width:100%"></td>
                        <td><input type="text" name="stParamValue" style="width:100%"></td>
                        <td><span name="stParamDesc" class="paramType fieldTooltip"></span></td>
                        <td><span name="stParamType" class="paramType"></span></td>
                        <td><span name="stParamLength" class="paramType"></span></td>
                        <td>
                            <button type="button" name="btnAdd" class="btn" onclick="addSTField(\${stIndex})" tabindex="-1">+</button>
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
                <td><span name="stParamDesc" class="paramType fieldTooltip"></span></td>
                <td><span name="stParamType" class="paramType"></span></td>
                <td><span name="stParamLength" class="paramType"></span></td>
                <td>
                    <button type="button" name="btnAdd" class="btn" onclick="addSTField(\${index})" tabindex="-1">+</button>
                    <button type="button" name="btnDel" class="btn" onclick="delField(this)" tabindex="-1">-</button>
                </td>
            </tr>
        `;
        $(`#structureTable_\${index} tbody`).append(field);
    }

    //EXPORT 스칼라 파라미터 필드 추가
    function addSCFieldEX() {
        let field = `
            <tr>
                <td><input type="text" name="scParamKeyEX" style="width:100%" tabindex="-1" readonly></td>
                <td><span name="scParamDescEX" class="paramType fieldTooltip"></span></td>
                <td><span name="scParamTypeEX" class="paramType"></span></td>
                <td><span name="scParamLengthEX" class="paramType"></span></td>
                <td>
                    <!--<button type="button" name="btnAdd" class="btn" onclick="addSCFieldEX()" tabindex="-1">+</button>-->
                    <!--<button type="button" name="btnDel" class="btn" onclick="delField(this)" tabindex="-1">-</button>-->
                </td>
                <td></td>
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
                <div style="margin-bottom:15px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="structureNmEX" class="text-label">
                        <input style="width: 300px;" type="text" name="structureNmEX" tabindex="-1" readonly>
                    </label>
                    <!--<button type="button" class="btn" onclick="delST(this)" tabindex="-1">X</button>-->
                </div>
                <div style="margin-bottom:10px;">
                    <span name="exStDesc" style="margin: 5px; width:200px;"></span>
                </div>
                <table id="structureTableEX_\${stEXIndex}" name="structureTableEX" style="table-layout: fixed; width: 100%;">
                    <colgroup>
                        <col style="width:20%" />
                        <col style="width:25%" />
                        <col style="width:15%" />
                        <col style="width:10%" />
                        <col style="width:10%" />
                        <col style="width:20%" />
                    </colgroup>
                    <thead>
                    <tr>
                        <th>KEY</th>
                        <th>DECS</th>  <!-- 주석 -->
                        <th>TYPE</th>  <!-- 데이터 타입 -->
                        <th>LEN</th>   <!-- 길이(소수점) -->
                        <th></th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><input type="text" name="stParamKeyEX" style="width:100%" tabindex="-1" readonly></td>
                        <td><span name="stParamDescEX" class="paramType fieldTooltip"></span></td>
                        <td><span name="stParamTypeEX" class="paramType"></span></td>
                        <td><span name="stParamLengthEX" class="paramType"></span></td>
                        <td>
                            <!--<button type="button" name="btnAdd" class="btn" onclick="addSTEXField(\${stEXIndex})" tabindex="-1">+</button>-->
                        </td>
                        <td></td>
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
                <td><input type="text" name="stParamKeyEX" style="width:100%" tabindex="-1" readonly></td>
                <td><span name="stParamDescEX" class="paramType fieldTooltip"></span></td>
                <td><span name="stParamTypeEX" class="paramType"></span></td>
                <td><span name="stParamLengthEX" class="paramType"></span></td>
                <td>
                    <!--<button type="button" name="btnAdd" class="btn" onclick="addSTEXField(\${stEXIndex})" tabindex="-1">+</button>-->
                </td>
                <td></td>
            </tr>
        `;
        $(`#structureTableEX_\${index} tbody`).append(field);
    }

    //TABLE 파라미터 추가
    function addTable() {
        let table = `
        <div name="tableContBox" class="middle-box" style="display: block;">
            <div class="box-title">
                <div style="margin-bottom:15px;">
                    <span style="margin: 5px; width:200px;">NAME :</span>
                    <label for="tableNm" class="text-label">
                        <input style="width: 300px;" type="text" name="tableNm">
                    </label>
                    <button type="button" class="btn btnAddTbRow" onclick="addTableRow(this)" tabindex="-1">+ROW</button>
                    <button type="button" class="btn" onclick="delTable(this)" tabindex="-1">X</button>
                </div>
                <div style="margin-bottom:10px;">
                    <span name="tbDesc" style="margin: 5px; width:200px;"></span>
                </div>
            </div>
            <div class="row-index">
                <div class="box-title">
                    <span class="row-label" style="margin: 5px;">Row1</span>
                    <button type="button" class="btn" onclick="delTableRow(this)" tabindex="-1">X</button>
                </div>
                <div class="inner-box">
                    <table name="tableTable" style="table-layout: fixed; width: 100%;">
                        <colgroup>
                            <col style="width:20%" />
                            <col style="width:20%" />
                            <col style="width:25%" />
                            <col style="width:15%" />
                            <col style="width:10%" />
                            <col style="width:10%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>DECS</th>  <!-- 주석 -->
                            <th>TYPE</th>  <!-- 데이터 타입 -->
                            <th>LEN</th>   <!-- 길이(+소수점) -->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="tbParamKey" style="width:100%"></td>
                            <td><input type="text" name="tbParamValue" style="width:100%"></td>
                            <td><span name="tbParamDesc" class="paramType fieldTooltip"></span></td>
                            <td><span name="tbParamType" class="paramType"></span></td>
                            <td><span name="tbParamLength" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)" tabindex="-1">+</button>
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
                    <button type="button" class="btn" onclick="delTableRow(this)" tabindex="-1">X</button>
                </div>
                <div class="inner-box">
                    <table name="tableTable" style="table-layout: fixed; width: 100%;">
                        <colgroup>
                            <col style="width:20%" />
                            <col style="width:20%" />
                            <col style="width:25%" />
                            <col style="width:15%" />
                            <col style="width:10%" />
                            <col style="width:10%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>DECS</th>  <!-- 주석 -->
                            <th>TYPE</th>  <!-- 데이터 타입 -->
                            <th>LEN</th>   <!-- 길이(+소수점) -->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="tbParamKey" style="width:100%"></td>
                            <td><input type="text" name="tbParamValue" style="width:100%"></td>
                            <td><span name="tbParamDesc" class="paramType fieldTooltip"></span></td>
                            <td><span name="tbParamType" class="paramType"></span></td>
                            <td><span name="tbParamLength" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)" tabindex="-1">+</button>
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
            <td><span name="tbParamDesc" class="paramType fieldTooltip"></span></td>
            <td><span name="tbParamType" class="paramType"></span></td>
            <td><span name="tbParamLength" class="paramType"></span></td>
            <td>
                <button type="button" name="btnAdd" class="btn" onclick="addTableField(this)" tabindex="-1">+</button>
                <button type="button" name="btnDel" class="btn" onclick="delTableField(this)" tabindex="-1">-</button>
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
        if ($('#scalaContainer input[name="scParamKey"], #structureContainer input[name="stParamKey"], #tableContainer input[name="tbParamKey"]')
                .filter(function () { return $(this).val().trim() !== ''; })
                .length > 0) {
            if (!confirm("⚠️ 입력된 파라미터가 있습니다. 무시하시고 진행하시겠습니까?")) return;
        }

        myAxios.post(
            "/dev/getSAPMeta",
            {
                ashost: $("input[name=ashost]").val().trim(),
                sysnr: $("input[name=sysnr]").val().trim(),
                client: $("input[name=client]").val().trim(),
                user: $("input[name=user]").val().trim(),
                passwd: $("input[name=passwd]").val().trim(),
                lang: $("input[name=lang]").val().trim(),
                functionName: $("input[name=rfcfnc]").val().trim()
            },
            {
                beforeSend: function () {
                    showSpinner("⏳ RFC MetaData 수집중...");
                },
                complete: function () {
                    hideSpinner();
                    showSpinner("⏳ RFC MetaData 바인딩 중...");
                }
            }
        )
        .then(res => {
            const data = res.data;

            if (data.status == "ERROR") {
                $("#parsedJson").html(`<div class='error'>오류 발생: [\${data.status}]::\${data.errKey ? data.errKey : ''} <br><br> 에러메세지: \${data.message ? data.message : ''} <br><br> 원인: \${data.detailMessage ? data.detailMessage : ''}</div>`);
                showMessage("🚫 RFC MetaData 수집 실패", false);
                return;
            }

            const functionName = data.functionName;
            const importParamsArr = data.importParams;
            const tableParamsArr = data.tableParams;
            const exportParamsArr = data.exportParams;

            //import파라미터세팅
            setImportScalaRows(importParamsArr.filter(item => item.dataType === "STRING"));
            setImportStructureRows(importParamsArr.filter(item => item.dataType === "STRUCTURE"))

            //table파라미터세팅
            setTableParam(tableParamsArr);

            //export파라미터세팅
            setExportScalaRows(exportParamsArr.filter(item => item.dataType === "STRING"));
            setExportStructureRows(exportParamsArr.filter(item => item.dataType === "STRUCTURE"))

            showMessage(`✅ [\${functionName}] 바인딩 완료`);
        })
        .catch(error => {
            $("#parsedJson").html(`<div class='error'>오류 발생: [\${error.status ? error.status : ''}] <br><br> 에러메세지: \${error.message ? error.message : ''}</div>`);
            showMessage("🚫 에러발생", false);
        })
        .finally(() => {
            hideSpinner();
        });
    }

    //import파라미터중 스칼라파라미터 세팅
    function setImportScalaRows(importParamsArr) {
        const targetCount = importParamsArr.length;
        let $rows = $('input[name="scParamKey"]').closest('tr');
        let currentCount = $rows.length;

        //import파라미터 탭 오픈
        if (targetCount > 0) {
            openParamTab('importTab');
        }

        // row 부족하면 추가
        while (currentCount < targetCount) {
            addSCField();
            currentCount++;
        }

        // row 많으면 삭제 (뒤에서부터)
        $rows = $('input[name="scParamKey"]').closest('tr');
        while ($rows.length > targetCount) {
            $rows.last().remove();
            $rows = $('input[name="scParamKey"]').closest('tr');
        }

        // 필드 이름 세팅
        $('input[name="scParamKey"]').each(function (idx) {
            if (importParamsArr[idx]) {
                $(this).val(importParamsArr[idx].name);
            }
        });

        // 필드 주석 정보 세팅
        $('span[name="scParamDesc"]').each(function (idx) {
            var fieldDesc = "";
            if (importParamsArr[idx]) {
                fieldDesc = importParamsArr[idx].description
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터타입 정보 세팅
        $('span[name="scParamType"]').each(function (idx) {
            var fieldDesc = "";
            if (importParamsArr[idx]) {
                fieldDesc = importParamsArr[idx].sapType
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터길이 정보 세팅
        $('span[name="scParamLength"]').each(function (idx) {
            var fieldDesc = "";
            if (importParamsArr[idx]) {
                if (importParamsArr[idx].decimals != null && importParamsArr[idx].decimals > 0) {
                    fieldDesc = importParamsArr[idx].length + " (" + importParamsArr[idx].decimals + ")";
                }
                else {
                    fieldDesc = importParamsArr[idx].length;
                }

                $(this).text(fieldDesc);
            }
        });

        // 필드 value값 모두 초기화
        $('input[name="scParamValue"]').val('');
    }

    //import파라미터중 구조체파라미터 세팅
    function setImportStructureRows(importParamsArr) {
        const targetCount = importParamsArr.length;
        let $structures = $('input[name="structureNm"]');
        let stCount = $structures.length;

        //import파라미터 탭 오픈
        if (targetCount > 0) {
            openParamTab('importTab');
        }

        // 구조체 개수 부족하면 추가
        while (stCount < targetCount) {
            addST();
            stCount++;
        }

        // 구조체 개수 많으면 삭제 (뒤에서부터)
        $structures = $('input[name="structureNm"]');
        while ($structures.length > targetCount) {
            $structures.closest('div[class="inner-box"]').last().remove();
            $structures = $('input[name="structureNm"]');
        }

        // 구조체 이름 세팅
        $('input[name="structureNm"]').each(function (idx) {
            if (importParamsArr[idx]) {
                $(this).val(importParamsArr[idx].name);
            }
        });

        // 구조체 주석 세팅
        $('span[name="imStDesc"]').each(function (idx) {
            if (importParamsArr[idx]) {
                $(this).text("Description: " + importParamsArr[idx].description);
            }
        });

        // 구조체 내 필드 정보 세팅
        $('table[name="structureTable"]').each(function (idx){
            if (importParamsArr[idx]) {
                setImportStScalaRows(importParamsArr[idx].fields, idx);
            }
        });

        // 구조체 내 필드 value값 모두 초기화
        $('input[name="stParamValue"]').val('');
    }

    //import파라미터중 구조체 파라미터의 필드 세팅
    function setImportStScalaRows(importStFieldsArr, idx) {
        const targetCount = importStFieldsArr.length;

        //구조체에는 아이디값이 있어서 추가삭제를 하면 아이디 시퀀스값이 순차적이지 않는 문제가있음. 재귀적으로 호출될때 소팅후에 작은값부터 순차적으로 선택
        const structureIdx = idx + 1;
        const $targetSts = $('[id^="structureTable_"]');
        const sortedStructures = $targetSts.get().sort((a, b) => {
            const numA = parseInt(a.id.replace('structureTable_', ''), 10);
            const numB = parseInt(b.id.replace('structureTable_', ''), 10);
            return numA - numB;
        });
        const targetEl = sortedStructures[structureIdx - 1];
        if (!targetEl) {
            return;
        }
        const structureId = targetEl.id;
        const existStructureNo = parseInt(structureId.replace('structureTable_', ''), 10);

        let $rows = $('#' + structureId).find('input[name="stParamKey"]').closest('tr');
        let currentCount = $rows.length;

        // row 부족하면 추가
        while (currentCount < targetCount) {
            addSTField(existStructureNo);
            currentCount++;
        }

        // row 많으면 삭제 (뒤에서부터)
        $rows = $('#' + structureId).find('input[name="stParamKey"]').closest('tr');
        while ($rows.length > targetCount) {
            $rows.last().remove();
            $rows = $('#' + structureId).find('input[name="stParamKey"]').closest('tr');
        }

        // 필드 이름 세팅
        $('#' + structureId).find('input[name="stParamKey"]').each(function (idx) {
            if (importStFieldsArr[idx]) {
                $(this).val(importStFieldsArr[idx].name);
            }
        });

        // 필드 주석 정보 세팅
        $('#' + structureId).find($('span[name="stParamDesc"]')).each(function (idx) {
            var fieldDesc = "";
            if (importStFieldsArr[idx]) {
                fieldDesc = importStFieldsArr[idx].description
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터타입 정보 세팅
        $('#' + structureId).find($('span[name="stParamType"]')).each(function (idx) {
            var fieldDesc = "";
            if (importStFieldsArr[idx]) {
                fieldDesc = importStFieldsArr[idx].sapType
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터길이 정보 세팅
        $('#' + structureId).find($('span[name="stParamLength"]')).each(function (idx) {
            var fieldDesc = "";
            if (importStFieldsArr[idx]) {
                if (importStFieldsArr[idx].decimals != null && importStFieldsArr[idx].decimals > 0) {
                    fieldDesc = importStFieldsArr[idx].length + " (" + importStFieldsArr[idx].decimals + ")";
                }
                else {
                    fieldDesc = importStFieldsArr[idx].length;
                }

                $(this).text(fieldDesc);
            }
        });

        // 필드 value값 모두 초기화
        $('#' + structureId).find($('input[name="stParamValue"]')).val('');
    }

    //table파라미터 세팅
    function setTableParam(tableParamsArr) {
        const targetCount = tableParamsArr.length;
        let $tables = $('input[name="tableNm"]');
        let tableCount = $tables.length;

        //table파라미터 탭 오픈
        if (targetCount > 0) {
            openParamTab('tableTab');
        }

        // 테이블 개수 부족하면 추가
        while (tableCount < targetCount) {
            addTable();
            tableCount++;
        }

        // 테이블 개수 많으면 삭제 (뒤에서부터)
        $tables = $('input[name="tableNm"]');
        while ($tables.length > targetCount) {
            $tables.closest('div[class="middle-box"]').last().remove();
            $tables = $('input[name="tableNm"]');
        }

        // 테이블 이름 세팅
        $('input[name="tableNm"]').each(function (idx) {
            if (tableParamsArr[idx]) {
                $(this).val(tableParamsArr[idx].name);
            }
        });

        // 테이블 주석 세팅
        $('span[name="tbDesc"]').each(function (idx) {
            if (tableParamsArr[idx]) {
                $(this).text("Description: " + tableParamsArr[idx].description);
            }
        });

        // 테이블 내 필드 정보 세팅
        $('div[name="tableContBox"]').each(function (idx){
            if (tableParamsArr[idx]) {
                setTableRows(tableParamsArr[idx].fields, idx);
            }
        });

        // 테이블 내 필드 value값 모두 초기화
        $('input[name="tbParamValue"]').val('');
    }

    //table파라미터 필드 세팅
    function setTableRows(tableFieldsArr, idx) {
        const targetCount = tableFieldsArr.length;

        const $target = $('div[name="tableContBox"]').eq(idx);
        if ($target.length === 0) {
            return;
        }

        //테이블 파라미터 하나당 row는 하나만 세팅
        let $rowIdx = $target.find('div[class="row-index"]');
        while ($rowIdx.length > 1) {
            $rowIdx.last().remove();
            $rowIdx = $target.find('div[class="row-index"]');
        }
        if ($rowIdx.length < 1) {
            $target.find('.btnAddTbRow').click();
        }

        let $rows = $target.find('input[name="tbParamKey"]');
        let currentCount = $rows.length;

        // 필드 부족하면 추가
        while (currentCount < targetCount) {
            $target.find('button[onclick="addTableField(this)"]').first().click();
            currentCount++;
        }

        // row 많으면 삭제 (뒤에서부터)
        $rows = $target.find('input[name="tbParamKey"]');
        while ($rows.length > targetCount) {
            $rows.closest('tr').remove();
            $rows = $target.find('input[name="tbParamKey"]');
        }

        // 필드 이름 세팅
        $target.find('input[name="tbParamKey"]').each(function (idx) {
            if (tableFieldsArr[idx]) {
                $(this).val(tableFieldsArr[idx].name);
            }
        });

        // 필드 주석 정보 세팅
        $target.find($('span[name="tbParamDesc"]')).each(function (idx) {
            var fieldDesc = "";
            if (tableFieldsArr[idx]) {
                fieldDesc = tableFieldsArr[idx].description
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터타입 정보 세팅
        $target.find($('span[name="tbParamType"]')).each(function (idx) {
            var fieldDesc = "";
            if (tableFieldsArr[idx]) {
                fieldDesc = tableFieldsArr[idx].sapType
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터길이 정보 세팅
        $target.find($('span[name="tbParamLength"]')).each(function (idx) {
            var fieldDesc = "";
            if (tableFieldsArr[idx]) {
                if (tableFieldsArr[idx].decimals != null && tableFieldsArr[idx].decimals > 0) {
                    fieldDesc = tableFieldsArr[idx].length + " (" + tableFieldsArr[idx].decimals + ")";
                }
                else {
                    fieldDesc = tableFieldsArr[idx].length;
                }

                $(this).text(fieldDesc);
            }
        });

        // 필드 value값 모두 초기화
        $target.find($('input[name="tbParamValue"]')).val('');
    }

    //export파라미터중 스칼라파라미터 세팅
    function setExportScalaRows(exportParamsArr) {
        const targetCount = exportParamsArr.length;
        let $rows = $('input[name="scParamKeyEX"]').closest('tr');
        let currentCount = $rows.length;

        //export파라미터 탭 display block
        if (targetCount > 0) {
            //openParamTab('exportTab');
            $('#exportTabContainer').css('display', 'block')
        }

        // row 부족하면 추가
        while (currentCount < targetCount) {
            addSCFieldEX();
            currentCount++;
        }

        // row 많으면 삭제 (뒤에서부터)
        $rows = $('input[name="scParamKeyEX"]').closest('tr');
        while ($rows.length > targetCount) {
            $rows.last().remove();
            $rows = $('input[name="scParamKeyEX"]').closest('tr');
        }

        // 필드 이름 세팅
        $('input[name="scParamKeyEX"]').each(function (idx) {
            if (exportParamsArr[idx]) {
                $(this).val(exportParamsArr[idx].name);
            }
        });

        // 필드 주석 정보 세팅
        $('span[name="scParamDescEX"]').each(function (idx) {
            var fieldDesc = "";
            if (exportParamsArr[idx]) {
                fieldDesc = exportParamsArr[idx].description
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터타입 정보 세팅
        $('span[name="scParamTypeEX"]').each(function (idx) {
            var fieldDesc = "";
            if (exportParamsArr[idx]) {
                fieldDesc = exportParamsArr[idx].sapType
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터길이 정보 세팅
        $('span[name="scParamLengthEX"]').each(function (idx) {
            var fieldDesc = "";
            if (exportParamsArr[idx]) {
                if (exportParamsArr[idx].decimals != null && exportParamsArr[idx].decimals > 0) {
                    fieldDesc = exportParamsArr[idx].length + " (" + exportParamsArr[idx].decimals + ")";
                }
                else {
                    fieldDesc = exportParamsArr[idx].length;
                }

                $(this).text(fieldDesc);
            }
        });
    }

    //export파라미터중 구조체파라미터 세팅
    function setExportStructureRows(exportParamsArr) {
        const targetCount = exportParamsArr.length;
        let $structures = $('input[name="structureNmEx"]');
        let stCount = $structures.length;

        //export파라미터 탭 오픈
        if (targetCount > 0) {
            //openParamTab('exportTab');
            $('#exportTabContainer').css('display', 'block')
        }

        // 구조체 개수 부족하면 추가
        while (stCount < targetCount) {
            addSTEX();
            stCount++;
        }

        // 구조체 개수 많으면 삭제 (뒤에서부터)
        $structures = $('input[name="structureNmEX"]');
        while ($structures.length > targetCount) {
            $structures.closest('div[class="inner-box"]').last().remove();
            $structures = $('input[name="structureNmEX"]');
        }

        // 구조체 이름 세팅
        $('input[name="structureNmEX"]').each(function (idx) {
            if (exportParamsArr[idx]) {
                $(this).val(exportParamsArr[idx].name);
            }
        });

        // 구조체 주석 세팅
        $('span[name="exStDesc"]').each(function (idx) {
            if (exportParamsArr[idx]) {
                $(this).text("Description: " + exportParamsArr[idx].description);
            }
        });

        // 구조체 내 필드 정보 세팅
        $('table[name="structureTableEX"]').each(function (idx){
            if (exportParamsArr[idx]) {
                setExportStScalaRows(exportParamsArr[idx].fields, idx);
            }
        });
    }

    //export파라미터중 구조체 파라미터의 필드 세팅
    function setExportStScalaRows(exportStFieldsArr, idx) {
        const targetCount = exportStFieldsArr.length;

        //구조체에는 아이디값이 있어서 추가삭제를 하면 아이디 시퀀스값이 순차적이지 않는 문제가있음. 재귀적으로 호출될때 소팅후에 작은값부터 순차적으로 선택
        const structureIdx = idx + 1;
        const $targetSts = $('[id^="structureTableEX_"]');
        const sortedStructures = $targetSts.get().sort((a, b) => {
            const numA = parseInt(a.id.replace('structureTable_EX', ''), 10);
            const numB = parseInt(b.id.replace('structureTable_EX', ''), 10);
            return numA - numB;
        });
        const targetEl = sortedStructures[structureIdx - 1];
        if (!targetEl) {
            return;
        }
        const structureId = targetEl.id;
        const existStructureNo = parseInt(structureId.replace('structureTableEX_', ''), 10);

        let $rows = $('#' + structureId).find('input[name="stParamKeyEX"]').closest('tr');
        let currentCount = $rows.length;

        // row 부족하면 추가
        while (currentCount < targetCount) {
            addSTEXField(existStructureNo);
            currentCount++;
        }

        // row 많으면 삭제 (뒤에서부터)
        $rows = $('#' + structureId).find('input[name="stParamKeyEX"]').closest('tr');
        while ($rows.length > targetCount) {
            $rows.last().remove();
            $rows = $('#' + structureId).find('input[name="stParamKeyEX"]').closest('tr');
        }

        // 필드 이름 세팅
        $('#' + structureId).find('input[name="stParamKeyEX"]').each(function (idx) {
            if (exportStFieldsArr[idx]) {
                $(this).val(exportStFieldsArr[idx].name);
            }
        });

        // 필드 주석 정보 세팅
        $('#' + structureId).find($('span[name="stParamDescEX"]')).each(function (idx) {
            var fieldDesc = "";
            if (exportStFieldsArr[idx]) {
                fieldDesc = exportStFieldsArr[idx].description
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터타입 정보 세팅
        $('#' + structureId).find($('span[name="stParamTypeEX"]')).each(function (idx) {
            var fieldDesc = "";
            if (exportStFieldsArr[idx]) {
                fieldDesc = exportStFieldsArr[idx].sapType
                $(this).text(fieldDesc);
            }
        });

        // 필드 데이터길이 정보 세팅
        $('#' + structureId).find($('span[name="stParamLengthEX"]')).each(function (idx) {
            var fieldDesc = "";
            if (exportStFieldsArr[idx]) {
                if (exportStFieldsArr[idx].decimals != null && exportStFieldsArr[idx].decimals > 0) {
                    fieldDesc = exportStFieldsArr[idx].length + " (" + exportStFieldsArr[idx].decimals + ")";
                }
                else {
                    fieldDesc = exportStFieldsArr[idx].length;
                }

                $(this).text(fieldDesc);
            }
        });
    }

    //파라미터 탭 오픈
    function openParamTab(id) {
        const $span = $('#' + id);

        if ($span.hasClass('open')) {
            return;
        }

        const $outer = $span.closest('.outer-box');
        const $header = $span.closest('.section-header');

        $outer.find('.middle-box').slideDown(200);
        $header.find('button').show();
        $span.addClass('open');
    }

    //파라미터 탭 토글
    function toggleParamBox(el) {
        const $outer = $(el).closest('.outer-box');
        const $header = $(el).closest('.section-header');

        $outer.find('.middle-box').slideToggle(200);

        $header.find('button').toggle();

        $(el).toggleClass('open');
    }

    function callRFC() {
        //Import파라미터 자료구조 생성
        let importParams = [];
        //스칼라 파라미터
        $("#scalaTable tbody tr").each(function() {
            let key = $(this).find("input[name=scParamKey]").val()?.trim();
            let value = $(this).find("input[name=scParamValue]").val();

            if (key) {
                importParams.push({
                    key: key,
                    value: value,
                    dataType: "STRING"
                });
            }
        });
        //구조체 파라미터
        $("#structureContainer .inner-box").each(function () {
            const $box = $(this);

            // 구조체 이름
            const structName = $box.find('input[name="structureNm"]').val()?.trim();
            if (!structName) {
                return;
            }

            let fields = [];

            // 구조체 내부 필드
            $box.find('table[name="structureTable"] tbody tr').each(function () {
                const $tr = $(this);
                const fieldName = $tr.find('input[name="stParamKey"]').val()?.trim();
                const fieldValue = $tr.find('input[name="stParamValue"]').val();

                if (fieldName) {
                    fields.push({
                        key: fieldName,
                        value: fieldValue
                    });
                }
            });

            importParams.push({
                name: structName,
                dataType: "STRUCTURE",
                fields: fields
            });
        });


        //Table 자료구조 생성
        let tableParams = [];
        $("#tableContainer .middle-box").each(function () {
            const $box = $(this);

            // 테이블 이름
            const tableName = $box.find('input[name="tableNm"]').val()?.trim();
            if (!tableName) {
                return;
            }

            let rows = [];

            // 테이블 rows
            $box.find('div[class="row-index"]').each(function () {
                let rowFields = [];

                // 테이블 rows 내부 필드
                $(this).find('table[name="tableTable"] tbody tr').each(function () {
                    const $tr = $(this);
                    const fieldName = $tr.find('input[name="tbParamKey"]').val()?.trim();
                    const fieldValue = $tr.find('input[name="tbParamValue"]').val();

                    if (fieldName) {
                        rowFields.push({
                            key: fieldName,
                            value: fieldValue
                        });
                    }
                });

                rows.push({
                    fields: rowFields
                });
            })

            tableParams.push({
                name: tableName,
                dataType: "TABLE",
                rows: rows
            });
        });

        myAxios.post(
            "/dev/callRFC",
            {
                ashost: $("input[name=ashost]").val().trim(),
                sysnr: $("input[name=sysnr]").val().trim(),
                client: $("input[name=client]").val().trim(),
                user: $("input[name=user]").val().trim(),
                passwd: $("input[name=passwd]").val().trim(),
                lang: $("input[name=lang]").val().trim(),
                functionName: $("input[name=rfcfnc]").val().trim(),
                importParams: JSON.stringify(importParams),
                tableParams: JSON.stringify(tableParams)
            },
            {
                beforeSend: function () {
                    showSpinner("⏳ RFC Function Call...");
                }
            }
        )
        .then(res => {
            const data = res.data;
            const jsonStrResult = JSON.stringify(res.data.result);

            if (data.status == "ERROR") {
                $("#parsedJson").html(`<div class='error'>오류 발생: [\${data.status}]::\${data.errKey ? data.errKey : ''} <br><br> 에러메세지: \${data.message ? data.message : ''} <br><br> 원인: \${data.detailMessage ? data.detailMessage : ''}</div>`);
                showMessage("🚫 RFC Function Call 오류발생", false);
                return;
            }

            $("#parsedJson").html(jsonStrResult);
            if ($("#kind").val() === 'JPP' || $("#kind").val() === 'XPP') {
                $('.result-container').css('white-space', 'nowrap');
                parseJson(jsonStrResult);
            }

            showMessage("✅ RFC Function Call 성공");
        })
        .catch(error => {
            $("#parsedJson").html(`<div class='error'>오류 발생: [\${error.status ? error.status : ''}] <br><br> 에러메세지: \${error.message ? error.message : ''}</div>`);
            showMessage("🚫 RFC Function Call 오류발생", false);
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
                alert('🚫 파싱 중 오류가 발생했습니다: ' + error);
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
                        $(this).css('border-left', `1px dotted hsla(\${hue}, 70%, 50%, 1)`);
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
                showMessage("✅ 복사 완료");
            } else {
                showMessage('🚫 복사에 실패했습니다...', false);
            }
        } catch (err) {
            alert('🚫 복사 중 오류가 발생했습니다: ' + err);
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

    function showMessage(msg, isSuccess = true) {
        var $messageDiv = $('#copy-success-message');
        $messageDiv.text(msg);

        var orginBgColor = $messageDiv.css('background-color'); //기존 성공배경색 저장

        if (!isSuccess) {
            $messageDiv.css({
                background: '#dc3545'
            });
        }

        $messageDiv.css({
            display: 'block',
            opacity: 1
        });

        // 1초 후에 서서히 사라지게
        setTimeout(function () {
            $messageDiv.css({
                transition: 'opacity 0.5s',
                opacity: 0
            });
        }, 1000);

        // 1.5초 후에 display: none 처리
        setTimeout(function () {
            $messageDiv.css({
                display: 'none',
                transition: '',
                background: orginBgColor    //기존 성공배경색 복구
            });
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
                <button class="btn" id="rfcCall" onclick="callRFC()" tabindex="-1">CALL</button>
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
            <span id="functionDesc" style="margin: 5px; width:200px;"></span>
        </div>

        <div style="margin-top: 20px; text-align: center">
            <button class="btn" style="width: 80%;" id="getSAPMeta" onclick="getSAPMeta()" tabindex="-1">GET RFC METADATA</button>
        </div>

        <!-- IMPORT파라미터 시작-->
        <div class="outer-box">
            <div class="section-header">
                <span id="importTab" onclick="toggleParamBox(this)">IMPORT</span>
            </div>
            <!-- 스칼라 파라미터 시작-->
            <div class="middle-box" id="scalaContainer">
                <div class="box-title">
                    <span style="margin: 5px;">SCALA</span>
                </div>
                <div class="inner-box">
                    <table id="scalaTable" style="table-layout: fixed; width: 100%;">
                        <colgroup>
                            <col style="width:20%" />
                            <col style="width:20%" />
                            <col style="width:25%" />
                            <col style="width:15%" />
                            <col style="width:10%" />
                            <col style="width:10%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>VALUE</th>
                            <th>DECS</th>  <!-- 주석 -->
                            <th>TYPE</th>  <!-- 데이터 타입 -->
                            <th>LEN</th>   <!-- 길이(+소수점) -->
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="scParamKey" style="width:100%"></td>
                            <td><input type="text" name="scParamValue" style="width:100%"></td>
                            <td><span name="scParamDesc" class="paramType fieldTooltip"></span></td>
                            <td><span name="scParamType" class="paramType"></span></td>
                            <td><span name="scParamLength" class="paramType"></span></td>
                            <td>
                                <button type="button" name="btnAdd" class="btn" onclick="addSCField()" tabindex="-1">+</button>
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
                    <button type="button" class="btn" onclick="addST()" tabindex="-1">+</button>
                </div>
            </div>
            <!-- 구조체 파라미터 끝-->
        </div>
        <!-- IMPORT파라미터 끝-->

        <!-- TABLE파라미터 시작-->
        <div class="outer-box" id="tableContainer">
            <div class="section-header">
                <span id="tableTab" onclick="toggleParamBox(this)">TABLE</span>
                <button type="button" class="btn" style="float: right; display: none;" onclick="addTable()" tabindex="-1">+ TABLE</button>
            </div>
        </div>
        <!-- TABLE파라미터 끝-->

        <!-- EXPORT파라미터 시작-->
        <div class="outer-box" id="exportTabContainer" style="display: none;">
            <div class="section-header">
                <span id="exportTab" onclick="toggleParamBox(this)">EXPORT</span>
            </div>
            <!-- 스칼라 파라미터 시작-->
            <div class="middle-box" id="scalaContainerEX">
                <div class="box-title">
                    <span style="margin: 5px;">SCALA</span>
                </div>
                <div class="inner-box">
                    <table id="scalaTableEX" style="table-layout: fixed; width: 100%;">
                        <colgroup>
                            <col style="width:20%" />
                            <col style="width:25%" />
                            <col style="width:15%" />
                            <col style="width:10%" />
                            <col style="width:10%" />
                            <col style="width:20%" />
                        </colgroup>
                        <thead>
                        <tr>
                            <th>KEY</th>
                            <th>DECS</th>  <!-- 주석 -->
                            <th>TYPE</th>  <!-- 데이터 타입 -->
                            <th>LEN</th>   <!-- 길이(+소수점) -->
                            <th></th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><input type="text" name="scParamKeyEX" style="width:100%" tabindex="-1" readonly></td>
                            <td><span name="scParamDescEX" class="paramType fieldTooltip"></span></td>
                            <td><span name="scParamTypeEX" class="paramType"></span></td>
                            <td><span name="scParamLengthEX" class="paramType"></span></td>
                            <td>
                                <%--<button type="button" name="btnAdd" class="btn" onclick="addSCFieldEX()" tabindex="-1">+</button>--%>
                            </td>
                            <td></td>
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
                    <%--<button type="button" class="btn" onclick="addSTEX()" tabindex="-1">+</button>--%>
                </div>
            </div>
            <!-- 구조체 파라미터 끝-->
        </div>
        <!-- EXPORT파라미터 끝-->
    </div>
    <div class="middle">
        <button class='hide-btn' style="width:15px;" onclick="showLeftContainer(this)" tabindex="-1"><</button>
    </div>
    <div class="right" id="result">
        <div class="copy-success-message" id="copy-success-message"></div>
        <div class="result-wrapper">
            <button class="copy-btn" onclick="copyResult()" tabindex="-1">복사</button>
            <!-- 결과 -->
            <div id="parsedJson" class="result-container"></div>
        </div>
    </div>
</div>

