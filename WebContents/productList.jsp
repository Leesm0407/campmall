<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 상품 목록 - CHAPTER10/catalog.jsp 흐름 (getConnection → DAO → c:set → c:forEach)
	// ?category= 5개 중 하나 (없거나 잘못되면 전체), ?sort= popular / low / high (그 밖의 값은 기본 정렬)
	request.setCharacterEncoding("utf-8");
	String category = request.getParameter("category");
	if (!Product.isCategory(category)) {
		category = null;
	}
	String sort = request.getParameter("sort");
	if (!"popular".equals(sort) && !"low".equals(sort) && !"high".equals(sort)) {
		sort = "";
	}

	Connection conn = ConnectionProvider.getConnection();
	List<Product> list = null;
	try {
		ProductDao dao = new ProductDao();
		list = dao.selectList(conn, category, sort);
	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		JdbcUtil.close(conn);
	}
	String[][] sorts = {{"", "기본순"}, {"popular", "인기순"}, {"low", "낮은 가격순"}, {"high", "높은 가격순"}};
%>
<c:set var="list" value="<%=list%>"/>
<c:set var="category" value="<%=category%>"/>
<c:set var="sort" value="<%=sort%>"/>
<c:set var="sorts" value="<%=sorts%>"/>
<c:set var="categories" value="<%=Product.CATEGORIES%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${empty category ? '전체 상품' : category} | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<main class="site-main">
<div class="page">
	<div class="page-head">
		<h1>${empty category ? '전체 상품' : category}</h1>
		<p>마음에 드는 장비를 담고, 장바구니에서 한 번에 주문하세요.</p>
	</div>

	<nav class="tabs" aria-label="카테고리">
		<c:url var="allUrl" value="productList.jsp"><c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if></c:url>
		<a href="${allUrl}" class="${empty category ? 'active' : ''}">전체</a>
		<c:forEach var="cat" items="${categories}">
		<c:url var="tabUrl" value="productList.jsp"><c:param name="category" value="${cat}"/><c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if></c:url>
		<a href="${tabUrl}" class="${category == cat ? 'active' : ''}">${cat}</a>
		</c:forEach>
	</nav>

	<div class="list-info">
		<span>총 ${list.size()}개</span>
		<nav class="sort-links" aria-label="정렬">
			<c:forEach var="s" items="${sorts}">
			<c:url var="sortUrl" value="productList.jsp"><c:if test="${not empty category}"><c:param name="category" value="${category}"/></c:if><c:if test="${not empty s[0]}"><c:param name="sort" value="${s[0]}"/></c:if></c:url>
			<a href="${sortUrl}" class="${sort == s[0] ? 'active' : ''}">${s[1]}</a>
			</c:forEach>
		</nav>
	</div>

	<c:if test="${empty list}">
	<div class="empty-box">
		<p>등록된 상품이 없어요.</p>
		<a href="productList.jsp" class="btn btn-gray">전체 상품 보기</a>
	</div>
	</c:if>

	<div class="grid-3 product-grid">
		<c:forEach var="p" items="${list}">
		<%@ include file="common/productCard.jsp" %>
		</c:forEach>
	</div>
</div>
</main>

<%@ include file="common/footer.jsp" %>
</body>
</html>
