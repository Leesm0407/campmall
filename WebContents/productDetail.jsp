<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 상품 상세 + 수량 선택 - CHAPTER10/detail.jsp 흐름 (?productId=)
	request.setCharacterEncoding("utf-8");
	int productId = 0;
	try {
		productId = Integer.parseInt(request.getParameter("productId"));
	} catch (NumberFormatException e) {}

	Connection conn = ConnectionProvider.getConnection();
	Product product = null;
	try {
		ProductDao dao = new ProductDao();
		product = dao.selectById(conn, productId);
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
	if (product == null) {   // 없는 상품이면 안내 후 목록으로
		request.setAttribute("msg", "찾는 상품이 없어요.");
		request.setAttribute("url", "productList.jsp");
		pageContext.forward("/common/alert.jsp");
		return;
	}
%>
<c:set var="p" value="<%=product%>"/>
<c:set var="freeDelivery" value="<%=Purchase.FREE_DELIVERY%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><c:out value="${p.name}"/> | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page tight">
	<c:url var="catUrl" value="productList.jsp"><c:param name="category" value="${p.category}"/></c:url>
	<nav class="breadcrumb" aria-label="현재 위치">
		<a href="productList.jsp">전체 상품</a>
		<span aria-hidden="true">›</span>
		<a href="${catUrl}">${p.category}</a>
		<span aria-hidden="true">›</span>
		<span class="current"><c:out value="${p.name}"/></span>
	</nav>

	<div class="detail-wrap">
		<section class="detail-main">
			<div class="product-photo detail-photo ${empty p.image ? 'empty' : ''}">
				<c:if test="${not empty p.image}">
				<img src="images/products/${p.image}" alt="<c:out value="${p.name}"/>" onerror="this.parentNode.classList.add('empty')">
				</c:if>
				<span class="no-photo"><img src="images/icons/no-photo.svg" width="110" height="110" alt=""><span>사진 준비 중</span></span>
				<span class="photo-badges">
					<c:if test="${p.soldOut}"><span class="badge-stock out">품절</span></c:if>
					<c:if test="${p.lowStock}"><span class="badge-stock low">품절 임박</span></c:if>
				</span>
			</div>
			<div class="info-card">
				<div class="info-title">
					<span class="badge-cat">${p.category}</span>
					<h1><c:out value="${p.name}"/></h1>
				</div>
				<div class="spec-grid">
					<div class="spec"><span>판매 가격</span><strong class="orange"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</strong></div>
					<div class="spec"><span>재고 상태</span>
						<strong>
						<c:choose>
							<c:when test="${p.soldOut}">품절</c:when>
							<c:when test="${p.lowStock}">품절 임박 (${p.stock}개)</c:when>
							<c:otherwise>구매 가능 (${p.stock}개)</c:otherwise>
						</c:choose>
						</strong>
					</div>
					<div class="spec"><span>누적 판매</span><strong>${p.sold}개</strong></div>
				</div>
				<p class="desc"><c:out value="${p.description}"/></p>
			</div>
		</section>

		<aside class="buy-box" aria-label="구매">
			<h2>구매하기</h2>
			<form id="buyForm" name="buyForm" action="cartAdd.jsp" method="post" data-price="${p.price}">
				<input type="hidden" name="productId" value="${p.productId}">
				<div class="field">
					<label for="amount">수량</label>
					<select id="amount" name="amount" class="select" ${p.soldOut ? 'disabled' : ''}>
						<c:choose>
							<c:when test="${p.soldOut}"><option value="0">품절</option></c:when>
							<c:otherwise>
								<c:forEach var="n" begin="1" end="${p.maxAmount}">
								<option value="${n}">${n}개</option>
								</c:forEach>
							</c:otherwise>
						</c:choose>
					</select>
				</div>
				<c:choose>
					<c:when test="${p.soldOut}">
					<p class="notice out">지금은 품절된 상품이에요. 재고가 들어오면 다시 구매할 수 있어요.</p>
					</c:when>
					<c:when test="${p.lowStock}">
					<p class="notice warn">남은 수량이 ${p.stock}개뿐이에요. 서둘러 주세요!</p>
					</c:when>
					<c:otherwise>
					<p class="notice"><img src="images/icons/info.svg" width="18" height="18" alt="">
					한 번에 최대 ${p.maxAmount}개까지 고를 수 있어요.</p>
					</c:otherwise>
				</c:choose>
				<div class="price-rows">
					<div class="price-row"><span class="label">판매 가격</span><span><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</span></div>
					<div class="price-row"><span class="label">수량</span><span id="amountText">${p.soldOut ? '-' : '1개'}</span></div>
					<div class="price-row total"><span class="label">합계</span><span class="value" id="totalText"><c:choose><c:when test="${p.soldOut}">-</c:when><c:otherwise><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</c:otherwise></c:choose></span></div>
				</div>
				<div class="buy-buttons">
					<button type="submit" name="mode" value="cart" class="btn btn-outline btn-lg" ${p.soldOut ? 'disabled' : ''}>장바구니 담기</button>
					<button type="submit" name="mode" value="buy" class="btn btn-orange btn-lg" ${p.soldOut ? 'disabled' : ''}>바로 구매</button>
				</div>
				<p class="hint">상품 합계 <fmt:formatNumber value="${freeDelivery}" pattern="#,###"/>원 이상이면 무료배송이에요.</p>
			</form>
		</aside>
	</div>
</div>
</main>

<%@ include file="common/footer.jsp" %>
<script src="js/product.js"></script>
</body>
</html>
