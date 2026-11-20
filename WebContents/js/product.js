// 상품 상세 화면(productDetail.jsp)
// 수량을 고르면 합계(가격 x 수량)를 바로 계산해서 보여준다.
// (실제 주문 금액은 서버의 order.jsp에서 DB 가격으로 다시 계산한다)
(function () {
	var form = document.getElementById("buyForm");
	if (!form) return;

	var price = parseInt(form.getAttribute("data-price"), 10);   // 판매 가격
	var select = form.amount;
	var amountText = document.getElementById("amountText");
	var totalText = document.getElementById("totalText");

	function update() {
		if (select.disabled) return;   // 품절
		var amount = parseInt(select.value, 10) || 0;
		amountText.textContent = amount + "개";
		totalText.textContent = (amount * price).toLocaleString("ko-KR") + "원";
	}

	select.addEventListener("change", update);
	// 버튼을 두 번 눌러 두 번 담기지 않게 한다
	form.addEventListener("submit", function () {
		setTimeout(function () {
			var buttons = form.querySelectorAll("button");
			for (var i = 0; i < buttons.length; i++) buttons[i].disabled = true;
		}, 0);
	});
	// 뒤로 가기로 돌아왔을 때는 버튼을 다시 켠다
	window.addEventListener("pageshow", function () {
		if (select.disabled) return;
		var buttons = form.querySelectorAll("button");
		for (var i = 0; i < buttons.length; i++) buttons[i].disabled = false;
	});
	update();
})();
