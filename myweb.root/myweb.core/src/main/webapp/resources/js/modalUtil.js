function ensureModalExists() {
    if (document.getElementById('modalOverlay')) return;

    const modalHtml = `
    <div id="modalOverlay" class="modal-overlay">
        <div class="modal-container">
            <div id="modalContent" class="modal-content">
                <div class="modal-inner-box"></div>
            </div>
            <button class="btn-close">닫기</button>
        </div>
    </div>

    <style>
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            z-index: 9998;
            display: none;
            justify-content: center;
            align-items: center;
        }

        .modal-container {
            background-color: #fff;
            width: 90vw;
            max-width: 1000px;
            max-height: 90vh;
            overflow: auto;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            border: 1px solid #f5c6cb;
            color: #333;
            font-family: '맑은 고딕', sans-serif;
            /* flex 제거 */
            display: block;  
        }


        .modal-content {
            overflow: visible;
        }

        .modal-inner-box {
            background: #fffefc;
            border: 1px solid #e0e0e0;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            overflow-x: auto;
            white-space: normal;
            font-family: "D2Coding", Consolas, monospace;
            font-size: 14px;
        }

        .btn-close {
            flex-shrink: 0;
            margin-top: 20px;
            padding: 12px 0;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            font-size: 15px;
            cursor: pointer;
            text-align: center;
            width: 100%;
            user-select: none;
        }

        .btn-close:hover {
            background-color: #0056b3;
        }
    </style>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHtml);
    document.querySelector('#modalOverlay .btn-close').onclick = hideModal;
}

function showModal(html) {
    ensureModalExists();
    const overlay = document.getElementById('modalOverlay');
    const content = document.querySelector('#modalContent .modal-inner-box');
    content.innerHTML = html;
    overlay.style.display = 'flex';
}

function hideModal() {
    const overlay = document.getElementById('modalOverlay');
    if (overlay) overlay.style.display = 'none';
}
