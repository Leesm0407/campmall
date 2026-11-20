<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 관리자 홈 : 오늘 주문 / 배송 대기 / 이번 달 매출 / 품절·품절 임박 + 최근 주문 + 재고 적은 상품
	Connection conn = ConnectionProvider.getConnection();
	List<Purchase> recentList = null;
	List<Product> lowList = null;
	int todayCount = 0;
	int waiting = 0;
	int monthSales = 0;
	int lowCount = 0;
	int productCount = 0;
	int userCount = 0;
	try {
		PurchaseDao dao = new PurchaseDao();
		recentList = dao.selectRecent(conn, 5);
		todayCount = dao.countToday(conn);
		waiting = dao.countWaiting(conn);
		monthSales = dao.sumThisMonth(conn);
		ProductDao productDao = new ProductDao();
		lowList = productDao.selectLowStock(conn, 5);
		lowCount = productDao.countLowStock(conn);
		productCount = productDao.selectCount(conn);
		UserDao userDao = new UserDao();
		userCount = userDao.selectCount(conn);
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="recentList" value="<%=recentList%>"/>
<c:set var="lowList" value="<%=lowList%>"/>
<c:set var="todayCount" value="<%=todayCount%>"/>
<c:set var="waiting" value="<%=waiting%>"/>
<c:set var="monthSales" value="<%=monthSales%>"/>
<c:set var="lowCount" value="<%=lowCount%>"/>
<c:set var="productCount" value="<%=productCount%>"/>
<c:set var="userCount" value="<%=userCount%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>관리자 홈 | 노지마켓</title>
<link rel="icon" type="image/svg+xml" href="../images/logo-mark.svg">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>관리자 홈</h1>
			<p>등록 상품 ${productCount}개 · 회원 ${userCount}명</p>
		</div>
		<div class="admin-user">
			<span><b><c:out value="${sessionScope.NAME}"/></b>님</span>
			<a href="../logout.jsp" class="btn btn-gray">로그아웃</a>
		</div>
	</div>

	<div class="stat-grid">
		<a href="orderList.jsp" class="stat-card" id="stat-today">
			<span>오늘 주문 (취소 제외)</span>
			<strong>${todayCount}건</strong>
		</a>
		<a href="orderList.jsp" class="stat-card" id="stat-waiting">
			<span>배송 대기 (주문 접수 + 배송 준비)</span>
			<strong>${waiting}건</strong>
		</a>
		<div class="stat-card" id="stat-sales">
			<span>이번 달 매출 (취소 제외)</span>
			<strong><fmt:formatNumber value="${monthSales}" pattern="#,##0"/>원</strong>
		</div>
		<a href="productList.jsp" class="stat-card" id="stat-low">
			<span>품절·품절 임박 상품</span>
			<strong>${lowCount}개</strong>
		</a>
	</div>

	<div class="two-col">
		<div>
			<h2 class="sub-title">최근 주문</h2>
			<c:choose>
			<c:when test="${empty recentList}">
			<div class="empty-box"><p>아직 주문이 없어요.</p></div>
			</c:when>
			<c:otherwise>
			<div class="table-card">
				<table class="data-table compact" style="min-width: 560px;">
					<thead>
						<tr>
							<th scope="col">주문 번호</th>
							<th scope="col">주문자</th>
							<th scope="col">상품</th>
							<th scope="col" class="right">결제 금액</th>
							<th scope="col">상태</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="o" items="${recentList}">
						<tr>
							<td class="num"><a href="orderDetail.jsp?purchaseId=${o.purchaseId}" class="plain-link strong">O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/></a></td>
							<td><c:out value="${o.userName}"/> <span class="small-id">${o.userId}</span></td>
							<td><c:out value="${o.firstName}"/><c:if test="${o.itemCount > 1}"> <span class="muted">외 ${o.itemCount - 1}건</span></c:if></td>
							<td class="right"><fmt:formatNumber value="${o.total}" pattern="#,###"/>원</td>
							<td><span class="status" data-status="${o.status}">${o.status}</span></td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			</c:otherwise>
			</c:choose>
			<p><a href="orderList.jsp" class="more-link">전체 주문 관리 →</a></p>
		</div>
		<div>
			<h2 class="sub-title">재고 적은 상품</h2>
			<div class="table-card">
				<table class="data-table compact" style="min-width: 360px;">
					<thead>
						<tr>
							<th scope="col">상품</th>
							<th scope="col" class="right">재고</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="p" items="${lowList}">
						<tr>
							<td><a href="productForm.jsp?productId=${p.productId}" class="plain-link"><c:out value="${p.name}"/></a></td>
							<td class="right">
								<c:choose>
									<c:when test="${p.soldOut}"><span class="badge-stock out">품절</span></c:when>
									<c:when test="${p.lowStock}"><span class="badge-stock low">${p.stock}개 · 품절 임박</span></c:when>
									<c:otherwise><span class="stock-num">${p.stock}개</span></c:otherwise>
								</c:choose>
							</td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			<p><a href="productList.jsp" class="more-link">전체 상품 관리 →</a></p>
		</div>
	</div>
</main>
</body>
</html>
