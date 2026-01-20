<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let inputCount = 1;
    const targetLangList = JSON.parse('${targetLangStr}');
    let latestInputValue = '';
    const ALLOWED_EXTENSIONS = ['docx', 'pptx', 'xlsx', 'pdf', 'htm', 'html', 'txt', 'xlf', 'xliff', 'srt', 'jpeg', 'jpg', 'png'];

    $(document).ready(function () {
        const $checkbox = $('#autoLan');
        const $select = $('#sourceLang');
        const $selectLabel = $('.start-lang');

        function updateSelectState() {
            const isDisabled = $checkbox.is(':checked');
            $select.prop('disabled', isDisabled);

            if (isDisabled) {
                $select.addClass('disabled');
                $selectLabel.addClass('disabled');
            } else {
                $select.removeClass('disabled');
                $selectLabel.removeClass('disabled');
            }
        }

        $checkbox.on('change', updateSelectState);
        // 초기 설정
        updateSelectState();

        const mainInput = $('#inputString_1');
        if (mainInput.length > 0) {
            latestInputValue = mainInput.val(); // 초기값 저장

            mainInput.on('input', function () {
                latestInputValue = mainInput.val(); // 최신 값 업데이트

                for (let i = 2; i <= inputCount; i++) {
                    const targetTextarea = $('#inputString_' + i);
                    if (targetTextarea.length > 0) {
                        targetTextarea.val(latestInputValue);
                    }
                }
            });
        }

        //파일업로드 시 데이터 표시
        $('#fileInput').on('change', function () {
            if (this.files.length === 0) {
                $('#fileInfo').hide();
                $('#fileDeleteBtn').hide();
                $('#fileEmpty').show();
                return;
            }

            const file = this.files[0];
            const fileName = file.name;     //파일명
            const ext = file.name.includes('.') ? file.name.split('.').pop() : '';    //확장자

            // 확장자 체크
            if (!ALLOWED_EXTENSIONS.includes(ext)) {
                alert(
                    '지원하지 않는 파일 형식입니다.\n\n' +
                    '허용 확장자:\n' +
                    ALLOWED_EXTENSIONS.join(', ')
                );

                // 파일 선택 취소
                this.value = '';
                $('#fileInfo').hide();
                $('#fileDeleteBtn').hide();
                $('#fileEmpty').show();
                return;
            }

            $('#fileName').text(fileName);
            $('#fileExt').text('확장자: ' + ext.toUpperCase());

            // 용량
            const size = file.size;
            const sizeText = size < 1024 * 1024
                ? (size / 1024).toFixed(1) + ' KB'
                : (size / (1024 * 1024)).toFixed(2) + ' MB';

            $('#fileSize').text('용량: ' + sizeText);

            $('#fileEmpty').hide();
            $('#fileInfo').show();
            $('#fileDeleteBtn').show();
        });

        //Drag & Drop (file-upload 전체)
        const $fileUpload = $('#fileUpload');
        const $fileInput  = $('#fileInput');
        // 기본 동작 방지
        $fileUpload.on('dragenter dragover', function (e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).addClass('drag-over');
        });

        $fileUpload.on('dragleave', function (e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass('drag-over');
        });

        $fileUpload.on('drop', function (e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass('drag-over');

            const files = e.originalEvent.dataTransfer.files;
            if (!files || files.length === 0) return;

            //fileInput에 파일 주입
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(files[0]); // 단일 파일
            $fileInput[0].files = dataTransfer.files;

            //기존 change 로직 실행
            $fileInput.trigger('change');
        });
    });

    function onKindChange() {
        const mode = $('input[name="translateKind"]:checked').val();

        if (mode === "plainText") {
            $('#inputLang-wrapper').css('display', 'block');
            $('#attachFile-wrapper').css('display', 'none');
        }
        else if (mode === "attachFile") {
            $('#inputLang-wrapper').css('display', 'none');
            $('#attachFile-wrapper').css('display', 'block');
        }
    }

    //번역텍스트 컨테이너 추가
    function addTarget() {
        inputCount++;

        const $wrapper = $('#inputLang-wrapper');

        const $group = $('<div>', {
            class: 'input-group',
            id: 'group_' + inputCount
        });

        // 1. select 영역
        const $selectLine = $('<div>').css({
            display: 'flex',
            justifyContent: 'flex-end',
            marginBottom: '5px'
        });

        const $label = $('<label>', {
            for: 'targetLang_' + inputCount,
            class: 'select-label',
            text: '도착언어 '
        });

        const $select = $('<select>', {
            id: 'targetLang_' + inputCount,
            class: 'select-inline'
        });

        $.each(targetLangList, function (_, lang) {
            $('<option>', {
                value: lang.language,
                text: lang.name
            }).appendTo($select);
        });

        $label.append($select);

        $selectLine.append($label);

        // 2. textarea + delete 버튼
        const $textareaWrapper = $('<div>', {
            class: 'textarea-wrapper'
        });

        const $textarea = $('<textarea>', {
            id: 'inputString_' + inputCount,
            name: 'inputString',
            spellcheck: false,
            placeholder: '번역할 내용을 입력하세요',
            readonly: true
        }).val(typeof latestInputValue === 'string' ? latestInputValue : '');

        const $deleteBtn = $('<button>', {
            class: 'delete-btn',
            type: 'button',
            text: 'x'
        }).on('click', function () {
            removeTarget($group.attr('id'));
        });

        $textareaWrapper.append($textarea, $deleteBtn);

        // 최종 조립
        $group.append($selectLine, $textareaWrapper);
        $wrapper.append($group);
    }

    //번역텍스트 컨테이너 삭제
    function removeTarget(groupId) {
        $('#' + groupId).remove();
    }

    //첨부파일 삭제
    function removeAttachFile() {
        $('#fileInput').val('');
        $('#fileInfo').hide();
        $('#fileDeleteBtn').hide();
        $('#fileEmpty').show();
    }

    //번역전 text, 첨부파일 분기처리
    function preTranslate() {
        const mode = $('input[name="translateKind"]:checked').val();

        if (mode === "plainText") {
            textTranslate();
        }
        else if (mode === "attachFile") {
            fileTranslate();
        }
    }

    //text 번역시작
    function textTranslate() {
        const targetList = [];

        $("[id^='inputString_']").each(function () {
            const idSuffix = this.id.split("_")[1];
            const targetLang = $("#targetLang_" + idSuffix).val();
            targetList.push(targetLang);
        });
        const isAutoLan = $('#autoLan').is(':checked');

        const bodyData = {
            targetList: targetList, //도착언어
            sourceLang: isAutoLan ? "" : $('#sourceLang').val(),    //출발언어
            content: $('#inputString_1').val()  //번역할 내용
        };

        myAxios.post(
            '/dev/translate/text',
            bodyData,
            {
                beforeSend: function () {
                    showSpinner("⏳ 번역중...");
                }
            })
        .then(res => {
            const translateList = res.data;
            const container = document.getElementById('transResult');
            container.innerHTML = '';

            translateList.forEach((item, index) => {
                const itemDiv = document.createElement('div');
                itemDiv.classList.add('translate-item');

                const langDiv = document.createElement('div');
                langDiv.classList.add('target-lang');
                langDiv.textContent = item.targetLang;

                const textDiv = document.createElement('div');
                textDiv.classList.add('translated-text');
                textDiv.textContent = item.text;

                itemDiv.onclick = function () {
                    copyContent(itemDiv);
                };

                itemDiv.appendChild(langDiv);
                itemDiv.appendChild(textDiv);

                container.appendChild(itemDiv);
            });
        })
        .catch(error => {
            $("#transResult").html(`<div class='error'>오류 발생</div>`);
            showMessage("🚫 에러발생", false);
        })
        .finally(() => {
            hideSpinner();
        });
    }

    //첨부파일 번역시작
    function fileTranslate() {
        const targetLang = $("#FiletargetLang").val();
        const isAutoLan = $('#autoLan').is(':checked');

        const formData = new FormData();
        formData.append('targetLang', targetLang);      //도착언어
        formData.append('sourceLang', isAutoLan ? '' : $('#sourceLang').val());     //출발언어
        const fileInput = $('#fileInput')[0];
        if (fileInput.files.length > 0) {
            formData.append('file', fileInput.files[0]);        //번역할 파일
        }
        else {
            alert("⚠️ 번역할 파일을 첨부하세요");
            return;
        }

        myAxios.post(
            '/dev/translate/file',
            formData,
            {
                beforeSend: function () {
                    showSpinner("⏳ 번역 요청중...");
                }
            })
        .then(res => {
            const data = res.data;

            const docId = data.docId;
            const docKey = data.docKey;
            const originalName = data.originalName;
            const downloadName = data.downloadName;
            const fileSize = data.fileSize;

            if (docId != null && docId.length > 0
                && docKey != null && docKey.length > 0
                && fileSize != null && fileSize > 0) {
                $('#docId').val(docId);
                $('#docKey').val(docKey);
                $('#originalName').val(originalName);
                $('#downloadName').val(downloadName);
                $('#targetFileSize').val(fileSize);

                getRemainTime();
            }
            else {
                alert("🚫 에러발생");
            }
        })
        .catch(error => {
            alert("🚫 에러발생");
        })
        .finally(() => {
            hideSpinner();
        });
    }

    function getRemainTime() {
        const docId = $('#docId').val();
        const docKey = $('#docKey').val();
        const fileSize = $('#targetFileSize').val();
        const sizeMB = fileSize / (1024 * 1024);

        /* 폴링주기
        ≤ 1MB	    1초	거의 즉시 끝남
        1MB ~ 5MB	2초	일반 문서
        5MB ~ 20MB	3초	번역 시간 체감됨
        20MB 초과	5초	대용량, 과도한 요청 방지
         */
        let interval;
        if (sizeMB <= 1) {
            interval = 1000;
        } else if (sizeMB <= 5) {
            interval = 2000;
        } else if (sizeMB <= 20) {
            interval = 3000;
        } else {
            interval = 5000;
        }

        //무한 폴링방지
        const MAX_TRY_COUNT = 100; // 최대 시도 횟수
        let tryCount = 0;
        let stopped = false;

        const poll = () => {
            //서버 요청이 끝나고 interval후에 재요청
            if (stopped) {
                return;
            }

            tryCount++;
            // 타임아웃 처리
            if (tryCount >= MAX_TRY_COUNT) {
                alert('⏱ 번역 시간이 초과되었습니다.');
                hideSpinner();

                $('#docId').val();
                $('#docKey').val();
                $('#originalName').val();
                $('#downloadName').val();
                $('#targetFileSize').val();

                return;
            }

            myAxios.get('/dev/translate/fileStatus', {
                params: {
                    docId: docId,
                    docKey: docKey
                }
            })
            .then(res => {
                const data = res.data;
                const fileStatus = data.fileStatus; //queued, translating, done, error
                const remainSec = data.remainSec;
                const charUsage = data.charUsage;   //사용량 기록
                const errMsg = data.errMsg;
                const isSuccess = data.isSuccess;

                showSpinner("⏳ 남은시간: " + remainSec + "초");

                if (fileStatus === 'done') {
                    stopped = true;
                    hideSpinner();
                    $('#charUsage').val(charUsage);
                    downloadTranslatedFile();
                    return;
                } else if (fileStatus === 'error') {
                    stopped = true;
                    alert('🚫 오류가 발생했습니다: ' + errMsg);
                    hideSpinner();
                    return;
                } else if (isSuccess !== 'OK') {
                    stopped = true;
                    alert('🚫 오류가 발생했습니다');
                    hideSpinner();
                    return;
                }

                // QUEUED / TRANSLATING 은 계속 폴링
                setTimeout(poll, interval);
            })
            .catch(error => {
                stopped = true;
                alert('🚫 오류가 발생했습니다.');
                hideSpinner();
            });
        }

        poll();
    }

    function downloadTranslatedFile() {
        const docId = $('#docId').val();
        const docKey = $('#docKey').val();
        const downloadName = $('#downloadName').val()

        myAxios.get('/dev/translate/fileDownload', {
            params: {
                docId: docId,
                docKey: docKey
            },
            responseType: 'blob'
        })
        .then(res => {
            // 에러 응답(JSON)이 blob으로 오는 경우 방어
            if (res.data.type === 'application/json') {
                const reader = new FileReader();
                reader.onload = () => {
                    const err = JSON.parse(reader.result);
                    alert(err.message || '🚫 다운로드 실패');
                };
                reader.readAsText(res.data);
                return;
            }

            const blob = new Blob([res.data]);
            const url = window.URL.createObjectURL(blob);

            const a = document.createElement('a');
            a.href = url;
            a.download = downloadName || 'translated_file';
            document.body.appendChild(a);
            a.click();

            a.remove();
            window.URL.revokeObjectURL(url);

            showMessage("✅ 다운로드 완료: " + downloadName);
        })
        .catch(error => {
            alert('🚫 오류가 발생했습니다.');
        });
    }

    function copyContent(element) {
        var selection = window.getSelection();
        selection.removeAllRanges();

        var range = document.createRange();
        range.selectNodeContents(element);
        selection.addRange(range);

        try {
            var success = document.execCommand('copy');
            if (success) {
                showMessage("✅ 복사 완료");
            } else {
                showMessage('🚫 복사에 실패했습니다...', false);
            }
        } catch (err) {
            alert('🚫 복사 중 오류가 발생했습니다: ' + err);
        }

        selection.removeAllRanges();
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
    <div class="left">
        <div class="toolbar">
            <span style="float:right">
                <label for="autoLan" class="checkbox-label">
                    <input type="checkbox" id="autoLan" value="autoLan" checked>
                    자동 언어 감지
                </label>
                <label for="sourceLang" class="select-label start-lang">출발언어
                    <select id="sourceLang" class="select-inline">
                        <c:forEach var="lang" items="${sourceLang}">
                            <option value="${lang.language}">${lang.name}</option>
                        </c:forEach>
                    </select>
                </label>
                <button class="btn" onclick="preTranslate()">Convert</button>
            </span>
        </div>
        <div class="radio-group horizontal">
            <label class="radio-label">
                <input type="radio" name="translateKind" value="plainText" onchange="onKindChange()" checked> Text
            </label>
            <label class="radio-label">
                <input type="radio" name="translateKind" value="attachFile" onchange="onKindChange()"> AttachFile
            </label>
        </div>
        <div id="inputLang-wrapper">
            <div class="input-group" id="group_1">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                    <button class="btn" onclick="addTarget()">+</button>
                    <label for="targetLang_1" class="select-label">도착언어
                        <select id="targetLang_1" class="select-inline">
                            <c:forEach var="lang" items="${targetLang}">
                                <option value="${lang.language}">${lang.name}</option>
                            </c:forEach>
                        </select>
                    </label>
                </div>
                <div class="textarea-wrapper">
                    <textarea id="inputString_1" name="inputString" spellcheck="false" placeholder="번역할 내용을 입력하세요"></textarea>
                </div>
            </div>
        </div>
        <div id="attachFile-wrapper" style="display: none;">
            <div style="display: flex; justify-content: flex-end; margin-bottom: 5px;">
                <label for="FiletargetLang" class="select-label">도착언어
                    <select id="FiletargetLang" class="select-inline">
                        <c:forEach var="lang" items="${targetLang}">
                            <option value="${lang.language}">${lang.name}</option>
                        </c:forEach>
                    </select>
                </label>
            </div>
            <div class="file-upload" id="fileUpload">
                <label for="fileInput" class="btn">
                    파일 선택
                </label>
                <div class="file-info" id="fileInfo" style="display:none;">
                    <div class="file-name" id="fileName"></div>
                    <div class="file-size" id="fileSize"></div>
                    <div class="file-ext" id="fileExt"></div>
                </div>
                <span class="file-empty" id="fileEmpty">선택된 파일 없음</span>
                <button type="button" class="btn btn-delete" id="fileDeleteBtn" onclick="removeAttachFile()" style="display:none;">삭제</button>
                <input type="file" id="fileInput" hidden />
            </div>
            <div style="white-space: pre-line; line-height: 1.6;">
                <span style="font-size: 20px;">번역가능한 파일 확장자 목록</span>
                - docx (Microsoft Word Document)
                - pptx (Microsoft PowerPoint Document)
                - xlsx (Microsoft Excel Document)
                - pdf (Portable Document Format)
                - htm/html (HTML Document)
                - txt (Plain Text Document)
                - xlf/xliff (XLIFF Document, version 2.1)
                - srt (SRT Document)
                - jpeg/jpg/png (Image)
            </div>
        </div>
    </div>
    <div class="right" id="result">
        <div class="copy-success-message" id="copy-success-message">✅ 복사 완료</div>
        <div class="result-wrapper">
            <!-- 결과 -->
            <div id="transResult" class="result-container"></div>
        </div>
    </div>
</div>

<input type="hidden" id="docId" />
<input type="hidden" id="docKey" />
<input type="hidden" id="originalName" />
<input type="hidden" id="downloadName" />
<input type="hidden" id="targetFileSize" />
<input type="hidden" id="charUsage" />