<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="common/loginCheck.jsp" %>
<%
	// 내 주문 내역 (?ordered= 방금 주문한 번호가 있으면 완료 안내를 보여준다)
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	int ordered = 0;
	try {
		ordered = Integer.parseInt(request.getParameter("ordered"));
	} catch (NumberFormatException e) {}

	Connection conn = ConnectionProvider.getConnection();
	List<Purchase> list = null;
	try {
		PurchaseDao dao = new PurchaseDao();
		list = dao.selectByUser(conn, loginId);
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="list" value="<%=list%>"/>
<c:set var="ordered" value="<%=ordered%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문 내역 | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page">
	<div class="page-head">
		<h1>주문 내역</h1>
		<p>주문 접수 상태일 때만 취소할 수 있어요. 주문 번호를 누르면 자세히 볼 수 있어요.</p>
	</div>

	<c:if test="${ordered > 0}">
	<div class="success-box">
		<span>주문이 완료되었어요! 주문 번호 <b>O-<fmt:formatNumber value="${ordered}" pattern="0000"/></b></span>
		<a href="orderDetail.jsp?purchaseId=${ordered}">주문 상세 보기 →</a>
	</div>
	</c:if>

	<c:choose>
	<c:when test="${empty list}">
	<div class="empty-box">
		<p>아직 주문 내역이 없어요.</p>
		<a href="productList.jsp" class="btn btn-forest">상품 보러 가기</a>
	</div>
	</c:when>
	<c:otherwise>
	<div class="table-card">
		<table class="data-table">
			<thead>
				<tr>
					<th scope="col">주문 번호</th>
					<th scope="col">주문일</th>
					<th scope="col">상품</th>
					<th scope="col" class="right">결제 금액</th>
					<th scope="col">상태</th>
					<th scope="col" class="right">취소</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="o" items="${list}">
				<tr>
					<td class="num"><a href="orderDetail.jsp?purchaseId=${o.purchaseId}" class="plain-link strong">O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/></a></td>
					<td><fmt:formatDate value="${o.purchaseDate}" pattern="yyyy-MM-dd"/></td>
					<td><a href="orderDetail.jsp?purchaseId=${o.purchaseId}" class="plain-link"><c:out value="${o.firstName}"/></a><c:if test="${o.itemCount > 1}"> <span class="muted">외 ${o.itemCount - 1}건</span></c:if></td>
					<td class="right strong"><fmt:formatNumber value="${o.total}" pattern="#,###"/>원</td>
					<td><span class="status" data-status="${o.status}">${o.status}</span></td>
					<td class="right">
						<c:choose>
							<c:when test="${o.status == '주문 접수'}">
							<form action="cancel.jsp" method="post" onsubmit="return confirm('O-<fmt:formatNumber value="${o.purchaseId}" pattern="0000"/> 주문을 취소할까요?');">
								<input type="hidden" name="purchaseId" value="${o.purchaseId}">
								<button type="submit" class="btn btn-danger">주문 취소</button>
							</form>
							</c:when>
							<c:otherwise><span class="muted">-</span></c:otherwise>
						</c:choose>
					</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
	</c:otherwise>
	</c:choose>
</div>
</main>

<%@ include file="common/footer.jsp" %>
</body>
</html>
