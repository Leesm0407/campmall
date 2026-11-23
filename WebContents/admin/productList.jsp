<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 관리자 상품 목록 - CHAPTER10/list.jsp 방식 (표 + 수정·삭제 버튼 + 상품 등록)
	request.setCharacterEncoding("utf-8");
	Connection conn = ConnectionProvider.getConnection();
	List<Product> list = null;
	try {
		ProductDao dao = new ProductDao();
		list = dao.selectList(conn, null, "");
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="list" value="<%=list%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>상품 관리 | 모닥</title>
<link rel="icon" type="image/png" href="../images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>상품 관리</h1>
			<p>등록된 상품 ${list.size()}개 · 주문 기록이 있는 상품은 삭제 대신 재고를 0으로 바꿔 품절로 표시해요.</p>
		</div>
		<div class="admin-user">
			<a href="productForm.jsp" class="btn btn-forest">+ 상품 등록</a>
			<span><b><c:out value="${sessionScope.NAME}"/></b>님</span>
			<a href="../logout.jsp" class="btn btn-gray">로그아웃</a>
		</div>
	</div>

	<div class="table-card">
		<table class="data-table compact">
			<thead>
				<tr>
					<th scope="col">사진</th>
					<th scope="col">상품 이름</th>
					<th scope="col">카테고리</th>
					<th scope="col" class="right">가격</th>
					<th scope="col" class="right">재고</th>
					<th scope="col" class="right">판매</th>
					<th scope="col" class="right">관리</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="p" items="${list}">
				<tr>
					<td>
						<c:choose>
							<c:when test="${not empty p.image}"><img src="../images/products/${p.image}" alt="" class="thumb" onerror="this.style.visibility='hidden'"></c:when>
							<c:otherwise><span class="thumb"></span></c:otherwise>
						</c:choose>
					</td>
					<td class="strong"><a href="../productDetail.jsp?productId=${p.productId}" class="plain-link"><c:out value="${p.name}"/></a></td>
					<td><span class="badge-cat">${p.category}</span></td>
					<td class="right"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</td>
					<td class="right">
						<c:choose>
							<c:when test="${p.soldOut}"><span class="badge-stock out">품절</span></c:when>
							<c:when test="${p.lowStock}"><span class="badge-stock low">${p.stock}개 · 품절 임박</span></c:when>
							<c:otherwise>${p.stock}개</c:otherwise>
						</c:choose>
					</td>
					<td class="right">${p.sold}개</td>
					<td>
						<div class="action-cell">
							<a href="productForm.jsp?productId=${p.productId}" class="btn btn-gray">수정</a>
							<form action="productDelete.jsp" method="post" data-name="<c:out value="${p.name}"/>" onsubmit="return confirm(this.getAttribute('data-name') + ' 상품을 삭제할까요?');">
								<input type="hidden" name="productId" value="${p.productId}">
								<button type="submit" class="btn btn-danger">삭제</button>
							</form>
						</div>
					</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
</main>
</body>
</html>
