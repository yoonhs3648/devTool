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
            const showSearch = $selectedOption.val() === 'tripledes';

            if (showKey) {
                $('#decrypt-key-wrapper').show();
            } else {
                $('#decrypt-key-wrapper').hide();
            }

            if (showSearch) {
                $('#searchCustom').show();
            } else {
                $('#searchCustom').hide();
            }
        }
    });

    function doSearchCustom() {
        if (!$('#customer').val().trim()) {
            alert("고객사명을 입력하세요");
            return;
        }

        const customer = $('#customer').val();
        const encodedCustomer = encodeURIComponent(customer);

        myAxios.get('/dev/crawl/custom', {
            params: {
                customerName: encodedCustomer
            }
        })
        .then(res => {
            const response = res.data;

            if (response.status == "SUCCESS") {
                const list = response.customerList;

                if (!list || list.length === 0) {
                    alert("조회된 고객사가 없습니다");
                    return;
                }

                let customerListHTML = `
        <style>
            #customerTable {
                width: 100%;
                border-collapse: collapse;
                font-family: Arial, sans-serif;
                margin-top: 10px;
            }
            #customerTable th, #customerTable td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: center;
            }
            #customerTable th {
                background-color: #f2f2f2;
                font-weight: bold;
            }
            #customerTable tr:hover {
                background-color: #eaf4ff;
                cursor: pointer;
            }
        </style>

        <table id="customerTable">
            <thead>
                <tr>
                    <th>MessageID</th>
                    <th>Subject</th>
                    <th>CategoryName</th>
                </tr>
            </thead>
            <tbody>
    `;

                list.forEach(item => {
                    const messageId = item.MessageID || '';
                    const subject = item.Subject || '';
                    const category = item.CategoryName || '';

                    customerListHTML += `
            <tr onclick="getCustomInfo('\${messageId}'); hideModal();">
                <td>\${messageId}</td>
                <td>\${subject}</td>
                <td>\${category}</td>
            </tr>
        `;
                });

                customerListHTML += `
            </tbody>
        </table>
    `;
                showModal(customerListHTML);

            } else {
                alert("사내 고객사 정보 조회에 실패했습니다");
                return;
            }
        });
    }

    function getCustomInfo(messageId) {
        myAxios.get('/dev/crawl/customInfo', {
            params: {
                messageID: messageId
            }
        })
        .then(res => {
            const response = res.data;

            if (response.status == "SUCCESS") {
                const list = response.customerMessageDetail;

                if (!list || list.length === 0) {
                    return;
                }

                $('#customer').val(list.Subject);

                // 유니코드 디코딩
                const unicodeDecoded = list.Body.replace(/%u([0-9A-F]{4})/gi, (_, hex) => {
                    return String.fromCharCode(parseInt(hex, 16));
                });

                // 브라우저 기반의 디코딩을 활용
                const tempUrlVal = new URL("http://dummy.com?hsyoon=" + unicodeDecoded);
                const urlDecoded = tempUrlVal.searchParams.get("hsyoon");

                $('#hiddenCustomerBody').val(urlDecoded);

                if ($('#searchCustom button.crawl-result').length === 0) {
                    const $btn = $('<button>')
                        .addClass('btn crawl-result')
                        .text('정보조회')
                        .css('float', 'right')
                        .attr('onclick', 'showCustomInfo()');
                    $('#searchCustom').append($btn);
                }

            } else {
                return;
            }
        })
    }

    function showCustomInfo() {
        resultHtml = '<div class="html-render-wrapper">' + $('#hiddenCustomerBody').val() + '</div>'
        showModal(resultHtml);
    }

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

        //TODO 개발중
        if ($('#algorithm').val() == 'engine') {
            alert("엔진 crypto는 개발중입니다...");
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
                        <option value="tripledes" data-show-key="true">TripleDES</option>
                        <option value="aes" data-show-key="true">AES</option>
                        <option value="engine">Engine</option>
                    </select>
                </label>
                <button class="btn" onclick="doCrypto()">Crypto</button>
            </div>
        </div>
        <div id="crypto-wrapper" style="margin-top: 30px;">
            <div id="searchCustom" class="custom-search" style="display: none; margin-bottom: 20px;">
                <span>고객사</span>
                <label for="customer" class="text-label">
                    <input type="text" style="width: 400px;" id="customer" name="customer" class="search-input" onkeydown="if(event.key === 'Enter'){ event.preventDefault(); doSearchCustom(); }">
                </label>
                <button class="btn" onclick="doSearchCustom()">검색</button>
            </div>
            <div id="decrypt-key-wrapper" style="display: none">
                <div class="crypto-group">
                    <span style="margin: 5px; display: inline-block;">PK</span>
                    <input type="text" id="pk" name="pk">
                </div>
                <div class="crypto-group">
                    <span style="margin: 5px; display: inline-block;">IV</span>
                    <input type="text" id="iv" name="iv">
                </div>
            </div>
            <div class="inputVal" style="margin-top: 20px;">
                <span style="margin: 5px; display: inline-block;">Content</span>
                <div class="textarea-wrapper">
                    <textarea id="content" name="content" placeholder="내용을 입력하세요"></textarea>
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

<input type="hidden" id="hiddenCustomerBody" name="hiddenCustomerBody" />