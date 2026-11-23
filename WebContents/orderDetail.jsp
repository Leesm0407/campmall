<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="common/loginCheck.jsp" %>
<%
	// 주문 상세 - CHAPTER10/detail.jsp 흐름 (?purchaseId=). 본인 주문만 볼 수 있다
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	int purchaseId = 0;
	try {
		purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
	} catch (NumberFormatException e) {}

	Connection conn = ConnectionProvider.getConnection();
	Purchase purchase = null;
	try {
		PurchaseDao dao = new PurchaseDao();
		purchase = dao.selectById(conn, purchaseId);
		if (purchase != null && purchase.getUserId().equals(loginId)) {
			purchase.setItems(dao.selectItems(conn, purchaseId));
		}
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
	if (purchase == null || !purchase.getUserId().equals(loginId)) {
		request.setAttribute("msg", "본인 주문만 볼 수 있어요.");
		request.setAttribute("url", "myOrder.jsp");
		pageContext.forward("/common/alert.jsp");
		return;
	}
%>
<c:set var="o" value="<%=purchase%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문 상세 | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css?v=20261123">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page">
	<nav class="breadcrumb" aria-label="현재 위치">
		<a href="myOrder.jsp">주문 내역</a>
		<span aria-hidden="true">›</span>
		<span class="current">O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/></span>
	</nav>
	<div class="page-head">
		<h1>주문 O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/> <span class="status" data-status="${o.status}">${o.status}</span></h1>
		<p><fmt:formatDate value="${o.purchaseDate}" pattern="yyyy년 M월 d일 HH:mm"/> 주문</p>
	</div>

	<div class="table-card">
		<table class="data-table">
			<thead>
				<tr>
					<th scope="col">상품</th>
					<th scope="col" class="right">가격</th>
					<th scope="col" class="right">수량</th>
					<th scope="col" class="right">금액</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="item" items="${o.items}">
				<tr>
					<td>
						<div class="item-cell">
							<c:choose>
								<c:when test="${not empty item.image}"><img src="images/products/${item.image}" alt="" class="thumb" onerror="this.style.visibility='hidden'"></c:when>
								<c:otherwise><span class="thumb"></span></c:otherwise>
							</c:choose>
							<a href="productDetail.jsp?productId=${item.productId}" class="plain-link strong"><c:out value="${item.name}"/></a>
						</div>
					</td>
					<td class="right"><fmt:formatNumber value="${item.price}" pattern="#,###"/>원</td>
					<td class="right">${item.amount}개</td>
					<td class="right strong"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/>원</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>

	<div class="two-col">
		<div class="info-card">
			<h2 class="sub-title">배송 정보</h2>
			<div class="info-rows">
				<div class="price-row"><span class="label">받는 사람</span><span><c:out value="${o.receiver}"/></span></div>
				<div class="price-row"><span class="label">전화번호</span><span><c:out value="${o.phone}"/></span></div>
				<div class="price-row"><span class="label">주소</span><span><c:out value="${o.address}"/></span></div>
				<div class="price-row"><span class="label">요청사항</span><span><c:out value="${empty o.memo ? '-' : o.memo}"/></span></div>
			</div>
		</div>
		<div class="info-card">
			<h2 class="sub-title">결제 금액</h2>
			<div class="price-rows">
				<div class="price-row"><span class="label">상품 합계</span><span><fmt:formatNumber value="${o.itemTotal}" pattern="#,###"/>원</span></div>
				<div class="price-row"><span class="label">배송비</span><span>${o.deliveryFee == 0 ? '무료' : ''}<c:if test="${o.deliveryFee > 0}"><fmt:formatNumber value="${o.deliveryFee}" pattern="#,###"/>원</c:if></span></div>
				<div class="price-row total"><span class="label">결제 금액</span><span class="value"><fmt:formatNumber value="${o.total}" pattern="#,###"/>원</span></div>
			</div>
			<c:if test="${o.status == '주문 접수'}">
			<form action="cancel.jsp" method="post" onsubmit="return confirm('이 주문을 취소할까요?');">
				<input type="hidden" name="purchaseId" value="${o.purchaseId}">
				<button type="submit" class="btn btn-danger btn-block">주문 취소</button>
			</form>
			</c:if>
		</div>
	</div>
	<p><a href="myOrder.jsp" class="more-link">← 주문 내역으로</a></p>
</div>
</main>

<%@ include file="common/footer.jsp" %>
</body>
</html>
