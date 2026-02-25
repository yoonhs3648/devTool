<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>

    const ALLOWED_EXTENSIONS = ['txt', 'xlf'];

    $(document).ready(function() {
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
    })

    function a() {
        myAxios.get(
            "/dev/dbSyncerTest1",
            {
            },
            {
            }
        )
        .then(res => {
            const data = res.data;

            let text = "";

            data.data.forEach(item => {
                text += item + "\n";
            });

            $('#a').val(text);
        })
        .catch(error => {
            alert("a error");
        })
        .finally(() => {
        });
    }

    function b() {
        myAxios.get(
            "/dev/dbSyncerTest2",
            {
            },
            {
            }
        )
        .then(res => {
            const data = res.data;

            let text = "";

            data.data.forEach(item => {
                text += item.OBJ_TYPE + " : " + item.OBJ_NAME + "\n";
            });

            $('#b').val(text);
        })
        .catch(error => {
            alert("b error");
        })
        .finally(() => {
        });
    }

    function c() {
        myAxios.get(
            "/dev/dbSyncerTest3",
            {
            },
            {
            }
        )
        .then(res => {
            const data = res.data;
            $('#c').val(data.data);
        })
        .catch(error => {
            alert("c error");
        })
        .finally(() => {
        });
    }

    function doDiff() {
        const formData = new FormData();
        const fileInput = $('#fileInput')[0];
        if (fileInput.files.length > 0) {
            formData.append('file', fileInput.files[0]);        //DDL파일
        }
        else {
            alert("⚠️ DDL 파일을 첨부하세요");
            return;
        }

        myAxios.post(
            '/dev/dbDiff',
            formData,
            {
                beforeSend: function () {
                    showSpinner("⏳ 번역 요청중...");
                }
            })
        .then(res => {
            const data = res.data;

        })
        .catch(error => {
            alert("🚫 에러발생");
        })
        .finally(() => {
            hideSpinner();
        });
    }

    //첨부파일 삭제
    function removeAttachFile() {
        $('#fileInput').val('');
        $('#fileInfo').hide();
        $('#fileDeleteBtn').hide();
        $('#fileEmpty').show();
    }
</script>

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
    <span style="font-size: 20px;">첨부가능한 파일 확장자 목록</span>
    - txt (Plain Text Document)
</div>
<%--
<button class="btn" onclick="a()" tabindex="-1">get DB List</button>
<button class="btn" onclick="b()" tabindex="-1">Get Object List</button>
<button class="btn" onclick="c()" tabindex="-1">Get Table DDL</button>--%>

<textarea id="a"></textarea>
<textarea id="b"></textarea>
<textarea id="c"></textarea>