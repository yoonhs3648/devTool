$(document).ready(function () {
    const $clock = $('.clock');

    // 숫자 1~12 추가
    for (let i = 1; i <= 12; i++) {
        const angle = (i - 3) * 30 * (Math.PI / 180); // -90도 보정
        const x = 50 + 45 * Math.cos(angle);
        const y = 50 + 45 * Math.sin(angle);

        const $number = $('<div class="number">').text(i).css({
            left: `${x}%`,
            top: `${y}%`
        });
        $clock.append($number);
    }

    // 바늘 추가
    const $hourHand = $('<div id="hourHand" class="hand hour"></div>');
    const $minuteHand = $('<div id="minuteHand" class="hand minute"></div>');
    const $secondHand = $('<div id="secondHand" class="hand second"></div>');
    $clock.append($hourHand, $minuteHand, $secondHand);

    function updateClock() {
        const now = new Date();
        const seconds = now.getSeconds();
        const minutes = now.getMinutes();
        const hours = now.getHours();

        // ✅ 보정 제거
        const secondDeg = seconds * 6;
        const minuteDeg = minutes * 6 + seconds * 0.1;
        const hourDeg = (hours % 12) * 30 + minutes * 0.5;

        $('#secondHand').css('transform', `rotate(${secondDeg}deg)`);
        $('#minuteHand').css('transform', `rotate(${minuteDeg}deg)`);
        $('#hourHand').css('transform', `rotate(${hourDeg}deg)`);

        const dateStr = now.toLocaleDateString('ko-KR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            weekday: 'short'
        });
        $('#clockDate').text(dateStr);
    }


    updateClock();
    setInterval(updateClock, 1000);
});
