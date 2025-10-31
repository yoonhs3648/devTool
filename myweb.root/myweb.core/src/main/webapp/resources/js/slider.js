$(document).ready(function () {
    // 모든 슬라이더에 대해 처리
    $('.hsla-controller input[type="range"]').on('input', function () {
        const $this = $(this);
        const prop = $this.data('prop'); // s, l, a

        let displayValue;
        const value = parseFloat($this.val(), 10);
        let $targetSpan;

        if (prop === 's') {
            $targetSpan = $('#saturation-value');
            displayValue = value + '%';
        } else if (prop === 'l') {
            $targetSpan = $('#lightness-value');
            displayValue = value + '%';
        } else if (prop === 'a') {
            $targetSpan = $('#alpha-value');
            displayValue = (value / 100).toFixed(2);
        } else if (prop === 'b') {
            $targetSpan = $('#border-value');
            displayValue = value + 'px';

            // 모든 브라우저에 공통적으로 변수 설정
            this.style.setProperty('--track-height', displayValue);

            //두께변경
            $(this).css('--track-height', displayValue);  // Webkit 브라우저용 (Chrome, Edge, Safari)
            $(this).css({
                'height': displayValue        // Firefox 등 다른 브라우저 대응
            });
        }

        // 표시 텍스트 변경
        $targetSpan.text(displayValue);

        // input의 value 속성도 갱신
        $this.attr('value', value);
    });
});
