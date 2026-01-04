function createSpinner() {
    if (document.getElementById("loadingOverlay")) return;

    const overlay = document.createElement("div");
    overlay.id = "loadingOverlay";
    overlay.innerHTML = `
            <div class="loading-content">
                <div class="spinner"></div>
                <div class="loading-text">Loading...</div>
            </div>
        `;

    document.body.appendChild(overlay);
}

function createSpinnerStyle() {
    if (document.getElementById("spinnerStyle")) return;

    const style = document.createElement("style");
    style.id = "spinnerStyle";
    style.innerHTML = `
            #loadingOverlay {
                position: fixed;
                top: 0; left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.3);
                z-index: 9999;
                display: none;
                align-items: center;
                justify-content: center;
            }

            .loading-content {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: white;
                text-align: center;
            }

            .spinner {
                width: 60px;
                height: 60px;
                border: 6px solid #ccc;
                border-top: 6px solid #1e90ff;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

            .loading-text {
                margin-top: 10px;
                font-size: 14px;
            }

            @keyframes spin {
                from { transform: rotate(0deg); }
                to   { transform: rotate(360deg); }
            }
        `;

    document.head.appendChild(style);
}

window.showSpinner = function (message) {
    createSpinnerStyle();
    createSpinner();

    if (message) {
        document.querySelector("#loadingOverlay .loading-text").innerText = message;
    }

    document.getElementById("loadingOverlay").style.display = "flex";
};

window.hideSpinner = function () {
    const overlay = document.getElementById("loadingOverlay");
    if (overlay) {
        overlay.style.display = "none";
    }
};