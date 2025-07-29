<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    $(document).ready(function () {
        toggleKeyWrapper();

        $('#algorithm').on('change', function () {
            toggleKeyWrapper();
        });

        function toggleKeyWrapper() {
            const $selectedOption = $('#algorithm option:selected');
            const showKey = $selectedOption.data('show-key') === true;

            if (showKey) {
                $('#decrypt-key-wrapper').show();
            } else {
                $('#decrypt-key-wrapper').hide();
            }
        }
    });

    function doCrypto() {
        if (!$('#content').val()) {
            alert("입력값을 확인하세요");
            return;
        }

        const $selectedOption = $('#algorithm option:selected');
        const showKey = $selectedOption.data('show-key') === true;
        if (showKey && (!$('#pk').val() || !$('#iv').val())) {
            alert("입력값을 확인하세요");
            return;
        }

        myAxios.post('/dev/doCrypto',
            {
                crypto: $('input[name="crypto"]:checked').val(),
                algorithm: $('#algorithm').val(),
                pk: $('#pk').val(),
                iv: $('#iv').val(),
                content: $('#content').val()
            }
        )
        .then(res => {
            const response = res.data;
            const container = document.getElementById('cryptoResult');
            container.innerHTML = '';

            if (response.isSucess == true) {
                const itemDiv = document.createElement('div');
                itemDiv.classList.add('result-item');

                const kindDiv = document.createElement('div');
                kindDiv.classList.add('result-kind');
                kindDiv.textContent = $('input[name="crypto"]:checked').val();

                const resultDiv = document.createElement('div');
                resultDiv.classList.add('result-value');
                resultDiv.textContent = response.returnVal;

                itemDiv.onclick = function () {
                    copyContent(itemDiv);
                };

                itemDiv.appendChild(kindDiv);
                itemDiv.appendChild(resultDiv);

                container.appendChild(itemDiv);
            }
        })
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
        <div class="toolbar">
            <div class="radio-group vertical">
                <label for="decryption" class="radio-label">
                    <input type="radio" id="decryption" name="crypto" value="decryption" checked> 복호화
                </label>
                <label for="encryption" class="radio-label">
                    <input type="radio" id="encryption" name="crypto" value="encryption"> 암호화
                </label>
            </div>
            <div>
                <label for="algorithm" class="select-label">Algorithm
                    <select id="algorithm" class="select-inline">
                        <option value="tripledes" data-show-key="true">TripleDesc</option>
                        <option value="aes" data-show-key="true">AES</option>
                        <option value="engine">Engine</option>
                    </select>
                </label>
                <button class="btn" onclick="doCrypto()">Convert</button>
            </div>
        </div>
        <div id="crypto-wrapper">
            <div id="decrypt-key-wrapper" style="display: none">
                <div class="crypto-group">
                    <div style="margin: 5px;">PK</div>
                    <input type="text" id="pk" name="pk" value="1234567890ABCDEF1234567890ABCDEF">
                </div>
                <div class="crypto-group">
                    <div style="margin: 5px;">IV</div>
                    <input type="text" id="iv" name="iv" value="ABCDEF1234567890">
                </div>
            </div>
            <div class="inputVal" style="margin-top: 20px;">
                <div style="margin: 5px;">Content</div>
                <div class="textarea-wrapper">
                    <textarea id="content" name="content" spellcheck="false" placeholder="내용을 입력하세요"></textarea>
                </div>
            </div>
        </div>
    </div>
    <div class="right" id="result">
        <div class="copy-success-message" id="copy-success-message">✅ 복사 완료</div>
        <div class="result-wrapper">
            <!-- 결과 -->
            <div id="cryptoResult" class="result-container"></div>
        </div>
    </div>
</div>