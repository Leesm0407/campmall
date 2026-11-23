<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 주문 관리 : 상태별 보기 + 상태 변경 (?status= 없으면 전체)
	request.setCharacterEncoding("utf-8");
	String status = request.getParameter("status");
	if (!Purchase.isStatus(status)) {
		status = null;
	}

	Connection conn = ConnectionProvider.getConnection();
	List<Purchase> list = null;
	Map<String, Integer> counts = new HashMap<String, Integer>();   // 상태별 건수 (버튼 옆 숫자)
	try {
		PurchaseDao dao = new PurchaseDao();
		list = dao.selectList(conn, status);
		for (String s : Purchase.STATUSES) {
			counts.put(s, dao.countByStatus(conn, s));
		}
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="list" value="<%=list%>"/>
<c:set var="statuses" value="<%=Purchase.STATUSES%>"/>
<c:set var="status" value="<%=status%>"/>
<c:set var="counts" value="<%=counts%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문 관리 | 모닥</title>
<link rel="icon" type="image/png" href="../images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css?v=20261123">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>주문 관리</h1>
			<p>취소로 바꾸면 재고가 자동으로 되돌아가요. 이미 취소된 주문은 상태를 바꿀 수 없어요.</p>
		</div>
		<div class="admin-user">
			<span><b><c:out value="${sessionScope.NAME}"/></b>님</span>
			<a href="../logout.jsp" class="btn btn-gray">로그아웃</a>
		</div>
	</div>

	<nav class="filter-pills" aria-label="상태별 보기">
		<a href="orderList.jsp" class="${empty status ? 'active' : ''}">전체</a>
		<c:forEach var="s" items="${statuses}">
		<c:url var="filterUrl" value="orderList.jsp"><c:param name="status" value="${s}"/></c:url>
		<a href="${filterUrl}" class="${status == s ? 'active' : ''}">${s} ${counts[s]}</a>
		</c:forEach>
	</nav>

	<c:choose>
	<c:when test="${empty list}">
	<div class="empty-box"><p>해당하는 주문이 없어요.</p></div>
	</c:when>
	<c:otherwise>
	<div class="table-card">
		<table class="data-table compact">
			<thead>
				<tr>
					<th scope="col">주문 번호</th>
					<th scope="col">주문일</th>
					<th scope="col">주문자</th>
					<th scope="col">상품</th>
					<th scope="col" class="right">결제 금액</th>
					<th scope="col">상태</th>
					<th scope="col">상태 변경</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="o" items="${list}">
				<tr>
					<td class="num"><a href="orderDetail.jsp?purchaseId=${o.purchaseId}" class="plain-link strong">O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/></a></td>
					<td><fmt:formatDate value="${o.purchaseDate}" pattern="MM-dd HH:mm"/></td>
					<td><c:out value="${o.userName}"/> <span class="small-id">${o.userId}</span></td>
					<td><c:out value="${o.firstName}"/><c:if test="${o.itemCount > 1}"> <span class="muted">외 ${o.itemCount - 1}건</span></c:if></td>
					<td class="right"><fmt:formatNumber value="${o.total}" pattern="#,###"/>원</td>
					<td><span class="status" data-status="${o.status}">${o.status}</span></td>
					<td>
						<c:choose>
						<c:when test="${o.status == '취소'}"><span class="muted">변경 불가</span></c:when>
						<c:otherwise>
						<form action="orderUpdate.jsp" method="post" class="status-form" onsubmit="return this.status.value != '취소' || confirm('주문을 취소하고 재고를 되돌릴까요?');">
							<input type="hidden" name="purchaseId" value="${o.purchaseId}">
							<input type="hidden" name="filter" value="${status}">
							<select name="status" class="select" aria-label="O-${o.purchaseId} 상태 변경">
								<c:forEach var="s" items="${statuses}">
								<option ${o.status == s ? 'selected' : ''}>${s}</option>
								</c:forEach>
							</select>
							<button type="submit" class="btn btn-forest">저장</button>
						</form>
						</c:otherwise>
						</c:choose>
					</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
	</c:otherwise>
	</c:choose>
</main>
</body>
</html>
