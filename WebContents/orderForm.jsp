<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 주문서 - CHAPTER10/register.jsp 같은 입력 폼 + putCart.jsp의 장바구니 목록
	// 로그인하지 않았으면 로그인 화면으로 보내고, 로그인 후에는 장바구니로 돌아오게 한다
	if (session.getAttribute("LOGIN") == null) {
		response.sendRedirect("loginForm.jsp?returnUrl="
				+ java.net.URLEncoder.encode(request.getContextPath() + "/cart.jsp", "UTF-8"));
		return;
	}
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
	if (cart == null) {
		cart = new ArrayList<Cart>();
	}

	String msg = null;
	User user = null;
	int itemTotal = 0;
	Connection conn = ConnectionProvider.getConnection();
	try {
		ProductDao dao = new ProductDao();
		Iterator<Cart> it = cart.iterator();
		while (it.hasNext()) {
			Cart c = it.next();
			Product product = dao.selectById(conn, c.getProductId());
			if (product == null) {
				it.remove();
				continue;
			}
			c.fill(product);
			itemTotal += c.getSubtotal();
			if (c.isOverStock()) msg = "재고가 부족한 상품이 있어요. 장바구니에서 수량을 확인해 주세요.";
		}
		UserDao userDao = new UserDao();
		user = userDao.selectById(conn, loginId);   // 받는 사람·전화번호 기본값
	} catch (SQLException e) {
		e.printStackTrace();
		msg = "주문서를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.";
	} finally {
		JdbcUtil.close(conn);
	}
	if (cart.isEmpty()) {
		msg = "장바구니가 비어 있어요.";
	}
	if (msg != null) {   // 장바구니가 비었거나 재고가 모자라면 안내 후 장바구니로
		request.setAttribute("msg", msg);
		request.setAttribute("url", "cart.jsp");
		pageContext.forward("/common/alert.jsp");
		return;
	}
	// 새로고침·두 번 누르기로 같은 주문이 두 번 저장되지 않게 주문서마다 한 번만 쓸 수 있는 값을 만든다
	String token = UUID.randomUUID().toString();
	session.setAttribute("ORDER_TOKEN", token);
	int deliveryFee = Purchase.deliveryFeeOf(itemTotal);
%>
<c:set var="cart" value="<%=cart%>"/>
<c:set var="user" value="<%=user%>"/>
<c:set var="token" value="<%=token%>"/>
<c:set var="itemTotal" value="<%=itemTotal%>"/>
<c:set var="deliveryFee" value="<%=deliveryFee%>"/>
<c:set var="total" value="<%=itemTotal + deliveryFee%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문서 작성 | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page">
	<div class="page-head">
		<h1>주문서 작성</h1>
		<p>배송 받을 곳을 적어 주세요. 이 사이트는 결제 연동 없이 주문만 접수돼요.</p>
	</div>

	<form class="order-wrap" name="orderForm" action="order.jsp" method="post" onsubmit="return checkOrder(this)">
		<input type="hidden" name="token" value="${token}">
		<section class="order-form">
			<div class="info-card">
				<h2 class="sub-title">배송 정보</h2>
				<div class="field">
					<label for="receiver">받는 사람</label>
					<input type="text" id="receiver" name="receiver" class="input" maxlength="30" value="<c:out value="${user.name}"/>" autocomplete="name">
				</div>
				<div class="field">
					<label for="phone">전화번호</label>
					<input type="tel" id="phone" name="phone" class="input" maxlength="13" placeholder="010-1234-5678" value="<c:out value="${user.phone}"/>" autocomplete="tel">
				</div>
				<div class="field">
					<label for="address">주소</label>
					<input type="text" id="address" name="address" class="input" maxlength="200" placeholder="도로명 주소와 상세 주소" autocomplete="street-address">
				</div>
				<div class="field">
					<label for="memo">요청사항 <span class="muted">(선택)</span></label>
					<input type="text" id="memo" name="memo" class="input" maxlength="200" placeholder="예) 문 앞에 놓아 주세요.">
				</div>
			</div>
		</section>

		<aside class="summary-box" aria-label="주문 상품과 금액">
			<h2>주문 상품 ${cart.size()}개</h2>
			<div class="mini-items">
				<c:forEach var="item" items="${cart}">
				<div class="mini-item"><span><c:out value="${item.name}"/> x ${item.amount}</span><span><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/>원</span></div>
				</c:forEach>
			</div>
			<div class="price-rows">
				<div class="price-row"><span class="label">상품 합계</span><span><fmt:formatNumber value="${itemTotal}" pattern="#,###"/>원</span></div>
				<div class="price-row"><span class="label">배송비</span><span>${deliveryFee == 0 ? '무료' : ''}<c:if test="${deliveryFee > 0}"><fmt:formatNumber value="${deliveryFee}" pattern="#,###"/>원</c:if></span></div>
				<div class="price-row total"><span class="label">결제 금액</span><span class="value"><fmt:formatNumber value="${total}" pattern="#,###"/>원</span></div>
			</div>
			<button type="submit" name="ok" class="btn btn-orange btn-lg btn-block"><fmt:formatNumber value="${total}" pattern="#,###"/>원 주문하기</button>
			<a href="cart.jsp" class="btn btn-gray btn-block">장바구니로 돌아가기</a>
		</aside>
	</form>
</div>
</main>

<%@ include file="common/footer.jsp" %>
<script type="text/javascript">
function checkOrder(frm) {
	if (frm.receiver.value.trim() == "") {
		alert("받는 사람을 입력해 주세요.");
		frm.receiver.focus();
		return false;
	}
	if (!/^[0-9-]{9,13}$/.test(frm.phone.value.trim())) {
		alert("전화번호를 숫자와 -로 입력해 주세요. 예) 010-1234-5678");
		frm.phone.focus();
		return false;
	}
	if (frm.address.value.trim().length < 5) {
		alert("주소를 자세히 입력해 주세요.");
		frm.address.focus();
		return false;
	}
	frm.ok.disabled = true;
	frm.ok.textContent = "주문 중...";
	return true;
}
</script>
</body>
</html>
