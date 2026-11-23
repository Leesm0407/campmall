<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 장바구니 목록 - pro0928 CHAPTER10/putCart.jsp의 목록 부분 방식
	// 세션의 List<Cart>를 돌면서 상품 정보(이름·가격·재고)를 DB에서 다시 읽어 채운다
	request.setCharacterEncoding("utf-8");
	@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
	if (cart == null) {
		cart = new ArrayList<Cart>();
	}
	int itemTotal = 0;
	boolean stockProblem = false;   // 재고보다 많이 담은 상품이 있으면 주문 버튼을 막는다
	Connection conn = ConnectionProvider.getConnection();
	try {
		ProductDao dao = new ProductDao();
		Iterator<Cart> it = cart.iterator();
		while (it.hasNext()) {
			Cart c = it.next();
			Product product = dao.selectById(conn, c.getProductId());
			if (product == null) {   // 관리자가 삭제한 상품은 장바구니에서도 뺀다
				it.remove();
				continue;
			}
			c.fill(product);
			itemTotal += c.getSubtotal();
			if (c.isOverStock()) stockProblem = true;
		}
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
	int deliveryFee = cart.isEmpty() ? 0 : Purchase.deliveryFeeOf(itemTotal);
	int total = itemTotal + deliveryFee;
	int needMore = Purchase.FREE_DELIVERY - itemTotal;   // 무료배송까지 남은 금액
%>
<c:set var="cart" value="<%=cart%>"/>
<c:set var="itemTotal" value="<%=itemTotal%>"/>
<c:set var="deliveryFee" value="<%=deliveryFee%>"/>
<c:set var="total" value="<%=total%>"/>
<c:set var="needMore" value="<%=needMore%>"/>
<c:set var="stockProblem" value="<%=stockProblem%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>장바구니 | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page">
	<div class="page-head">
		<h1>장바구니</h1>
		<p>수량을 바꾸거나 삭제한 뒤 주문하세요. 가격과 재고는 지금 기준으로 다시 계산돼요.</p>
	</div>

	<c:choose>
	<c:when test="${empty cart}">
	<div class="empty-box">
		<p>장바구니가 비어 있어요.</p>
		<a href="productList.jsp" class="btn btn-forest">상품 보러 가기</a>
	</div>
	</c:when>
	<c:otherwise>
	<div class="cart-wrap">
		<section class="cart-list" aria-label="담은 상품">
			<c:forEach var="item" items="${cart}">
			<div class="cart-item">
				<a href="productDetail.jsp?productId=${item.productId}" class="product-photo ${empty item.image ? 'empty' : ''}">
					<c:if test="${not empty item.image}">
					<img src="images/products/${item.image}" alt="" onerror="this.parentNode.classList.add('empty')">
					</c:if>
					<span class="no-photo"><img src="images/icons/no-photo.svg" width="32" height="32" alt=""></span>
				</a>
				<div class="cart-info">
					<h2><a href="productDetail.jsp?productId=${item.productId}"><c:out value="${item.name}"/></a></h2>
					<span class="muted"><fmt:formatNumber value="${item.price}" pattern="#,###"/>원</span>
					<c:if test="${item.stock == 0}"><span class="warn-text">품절된 상품이에요. 삭제한 뒤 주문해 주세요.</span></c:if>
					<c:if test="${item.stock > 0 && item.overStock}"><span class="warn-text">재고가 ${item.stock}개 남았어요. 수량을 줄여 주세요.</span></c:if>
				</div>
				<div class="cart-actions">
					<c:if test="${item.stock > 0}">
					<form action="cartUpdate.jsp" method="post">
						<input type="hidden" name="productId" value="${item.productId}">
						<select name="amount" class="select" aria-label="<c:out value="${item.name}"/> 수량" onchange="this.form.submit()">
							<c:forEach var="n" begin="1" end="${item.maxAmount}">
							<option value="${n}" ${n == item.amount ? 'selected' : ''}>${n}개</option>
							</c:forEach>
							<c:if test="${item.overStock}"><option value="${item.amount}" selected>${item.amount}개</option></c:if>
						</select>
						<noscript><button type="submit" class="btn btn-gray">변경</button></noscript>
					</form>
					</c:if>
					<span class="cart-sub"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/>원</span>
					<form action="cartDelete.jsp" method="post">
						<input type="hidden" name="productId" value="${item.productId}">
						<button type="submit" class="btn btn-gray" aria-label="<c:out value="${item.name}"/> 삭제">삭제</button>
					</form>
				</div>
			</div>
			</c:forEach>
		</section>

		<aside class="summary-box" aria-label="결제 예정 금액">
			<h2>결제 예정 금액</h2>
			<div class="price-rows">
				<div class="price-row"><span class="label">상품 합계</span><span id="itemTotal"><fmt:formatNumber value="${itemTotal}" pattern="#,##0"/>원</span></div>
				<div class="price-row"><span class="label">배송비</span><span id="deliveryFee">${deliveryFee == 0 ? '무료' : ''}<c:if test="${deliveryFee > 0}"><fmt:formatNumber value="${deliveryFee}" pattern="#,###"/>원</c:if></span></div>
				<div class="price-row total"><span class="label">결제 금액</span><span class="value" id="orderTotal"><fmt:formatNumber value="${total}" pattern="#,##0"/>원</span></div>
			</div>
			<c:choose>
				<c:when test="${needMore > 0}"><p class="free-note"><fmt:formatNumber value="${needMore}" pattern="#,###"/>원 더 담으면 무료배송이에요.</p></c:when>
				<c:otherwise><p class="free-note">무료배송 조건(5만 원 이상)을 채웠어요.</p></c:otherwise>
			</c:choose>
			<c:choose>
				<c:when test="${stockProblem}">
				<button type="button" class="btn btn-lg btn-block" disabled>재고를 확인해 주세요</button>
				</c:when>
				<c:otherwise>
				<a href="orderForm.jsp" class="btn btn-orange btn-lg btn-block">${empty sessionScope.LOGIN ? '로그인하고 주문하기' : '주문하기'}</a>
				</c:otherwise>
			</c:choose>
			<a href="productList.jsp" class="btn btn-gray btn-block">계속 쇼핑하기</a>
		</aside>
	</div>
	</c:otherwise>
	</c:choose>
</div>
</main>

<%@ include file="common/footer.jsp" %>
</body>
</html>
