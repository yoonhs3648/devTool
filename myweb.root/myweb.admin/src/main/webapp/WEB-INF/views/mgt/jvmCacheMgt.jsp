<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<script>
    function initToolbar() {
        const $keyLabel = $('#cacheKeyLabel');
        const $keyInput = $('#cacheKey');
        const $selectBtn = $('#selectBtn');
        const $insertBtn = $('#insertBtn');
        const $valueInputContainer = $('#valueInputContainer');

        // 기본 상태 초기화
        $keyInput.prop('disabled', false);
        $keyInput.removeClass('disabled');
        $keyLabel.removeClass('disabled');
        $selectBtn.show();
        $insertBtn.hide();
        $valueInputContainer.empty();
    }

    function onModeChange() {
        initToolbar();
        const $checkbox = $('#getAll');
        $checkbox.prop('checked', false);

        const mode = $('input[name="cacheMode"]:checked').val();
        const $valueInputContainer = $('#valueInputContainer');
        const $selectBtn = $('#selectBtn');
        const $insertBtn = $('#insertBtn');

        if (mode ==='create') {
            // value 입력란 동적 생성
            const valueElement = `
                <label for="cacheVal" id="cacheValLabel" class="text-label" style="margin-left: 10px;">Value
                    <input type="text" id="cacheVal" name="cacheVal" class="text-inline" style="width: 250px;">
                </label>`;

            $valueInputContainer.append(valueElement);
            $selectBtn.hide();
            $insertBtn.show();
        }
    }

    function onGetAllMode() {
        initToolbar();

        const $keyLabel = $('#cacheKeyLabel');
        const $keyInput = $('#cacheKey');
        const $checkbox = $('#getAll');

        if ($checkbox.is(':checked')) {
            $('input[name="cacheMode"][value="get"]').prop('checked', true)

            $keyInput.prop('disabled', true);
            $keyInput.addClass('disabled');
            $keyLabel.addClass('disabled');
        }
    }

    function onSelect() {
        const key = $('#cacheKey').val().trim();
        if (!key) {
            alert("올바른 key를 입력하세요");
            return;
        }

        myAxios.get('/admin/cache/jvm/get',{
            params: {
                cacheKey: key,
            }
        })
        .then(res => {
            const map = res.data;
            const container = document.querySelector('#result .result-wrapper');
            container.innerHTML = '';

            for (const key in map) {
                if (map.hasOwnProperty(key)) {
                    const itemDiv = document.createElement('div');
                    itemDiv.classList.add('result-item');

                    const keyDiv = document.createElement('div');
                    keyDiv.classList.add('result-kind');
                    keyDiv.textContent = key;

                    const valueDiv = document.createElement('div');
                    valueDiv.classList.add('result-value');
                    valueDiv.textContent = map[key];

                    itemDiv.appendChild(keyDiv);
                    itemDiv.appendChild(valueDiv);

                    container.appendChild(itemDiv);
                }
            }
        })
    }

    function onInsert() {
        const key = $('#cacheKey').val().trim();
        const value = $('#cacheVal').val().trim();
        if (!key) {
            alert("올바른 key를 입력하세요");
            return;
        }

        if (!value) {
            alert("올바른 value를 입력하세요");
            return;
        }

        myAxios.post('/admin/cache/jvm/set',
            {
                cacheKey: key,
                cacheVal: value
            })
            .then(res => {
                alert(res.data);
            })
    }

    function clearCache() {

    }
</script>

<div class="vertical-container">
    <div class="top">
        <div class="toolbar">
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                <!-- 라디오 그룹 -->
                <div class="radio-group horizontal">
                    <label class="radio-label">
                        <input type="radio" name="cacheMode" value="get" checked onchange="onModeChange()"> 조회
                    </label>
                    <label class="radio-label">
                        <input type="radio" name="cacheMode" value="create" onchange="onModeChange()"> 생성
                    </label>
                </div>

                <!-- key 입력 -->
                <label for="cacheKey" id="cacheKeyLabel" class="text-label" style="margin-left: 10px;">Key
                    <input type="text" id="cacheKey" name="cacheKey" class="text-inline" style="width: 200px;">
                </label>

                <!-- value 입력 (동적) -->
                <div id="valueInputContainer"></div>

                <label for="getAll" class="checkbox-label">
                    <input type="checkbox" id="getAll" value="getAll" onchange="onGetAllMode()"> 전체 조회
                </label>

                <!-- 동작 버튼 -->
                <button class="btn" id="selectBtn" onclick="onSelect()">찾기</button>
                <button class="btn" id="insertBtn" onclick="onInsert()" style="display: none">생성</button>
            </div>

            <div>
                <button class="btn" onclick="clearCache()">전체 초기화</button>
            </div>
        </div>
    </div>

    <div class="bottom" id="result">
        <div class="result-wrapper">
        </div>
    </div>
</div>

