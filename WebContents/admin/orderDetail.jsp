<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 관리자 주문 상세 : 받는 사람·주소·상품 목록 + 상태 변경
	request.setCharacterEncoding("utf-8");
	int purchaseId = 0;
	try {
		purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
	} catch (NumberFormatException e) {}

	Connection conn = ConnectionProvider.getConnection();
	Purchase purchase = null;
	try {
		PurchaseDao dao = new PurchaseDao();
		purchase = dao.selectById(conn, purchaseId);
		if (purchase != null) {
			purchase.setItems(dao.selectItems(conn, purchaseId));
		}
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
	if (purchase == null) {
		request.setAttribute("msg", "찾는 주문이 없어요.");
		request.setAttribute("url", "orderList.jsp");
		pageContext.forward("/common/alert.jsp");
		return;
	}
%>
<c:set var="o" value="<%=purchase%>"/>
<c:set var="statuses" value="<%=Purchase.STATUSES%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문 상세 | 모닥</title>
<link rel="icon" type="image/png" href="../images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css?v=20261123">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>주문 O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/> <span class="status" data-status="${o.status}">${o.status}</span></h1>
			<p><fmt:formatDate value="${o.purchaseDate}" pattern="yyyy-MM-dd HH:mm"/> · <c:out value="${o.userName}"/> (${o.userId})</p>
		</div>
		<div class="admin-user">
			<a href="orderList.jsp" class="btn btn-gray">← 주문 목록</a>
		</div>
	</div>

	<div class="table-card">
		<table class="data-table compact">
			<thead>
				<tr>
					<th scope="col">상품</th>
					<th scope="col" class="right">주문 당시 가격</th>
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
								<c:when test="${not empty item.image}"><img src="../images/products/${item.image}" alt="" class="thumb" onerror="this.style.visibility='hidden'"></c:when>
								<c:otherwise><span class="thumb"></span></c:otherwise>
							</c:choose>
							<span class="strong"><c:out value="${item.name}"/></span>
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
			<h2 class="sub-title">금액 · 상태</h2>
			<div class="price-rows">
				<div class="price-row"><span class="label">상품 합계</span><span><fmt:formatNumber value="${o.itemTotal}" pattern="#,###"/>원</span></div>
				<div class="price-row"><span class="label">배송비</span><span>${o.deliveryFee == 0 ? '무료' : ''}<c:if test="${o.deliveryFee > 0}"><fmt:formatNumber value="${o.deliveryFee}" pattern="#,###"/>원</c:if></span></div>
				<div class="price-row total"><span class="label">결제 금액</span><span class="value"><fmt:formatNumber value="${o.total}" pattern="#,###"/>원</span></div>
			</div>
			<c:choose>
			<c:when test="${o.status == '취소'}"><p class="notice out">취소된 주문이라 상태를 바꿀 수 없어요.</p></c:when>
			<c:otherwise>
			<form action="orderUpdate.jsp" method="post" class="status-form" onsubmit="return this.status.value != '취소' || confirm('주문을 취소하고 재고를 되돌릴까요?');">
				<input type="hidden" name="purchaseId" value="${o.purchaseId}">
				<input type="hidden" name="from" value="detail">
				<select name="status" class="select" aria-label="상태 변경" style="flex: 1;">
					<c:forEach var="s" items="${statuses}">
					<option ${o.status == s ? 'selected' : ''}>${s}</option>
					</c:forEach>
				</select>
				<button type="submit" class="btn btn-forest">상태 저장</button>
			</form>
			</c:otherwise>
			</c:choose>
		</div>
	</div>
</main>
</body>
</html>
