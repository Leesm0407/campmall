<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 노지마켓 메인 : 인기 상품 4개 (판매 수량 기준, 취소 제외) - CHAPTER10/catalog.jsp 흐름
	request.setCharacterEncoding("utf-8");
	Connection conn = ConnectionProvider.getConnection();
	List<Product> list = null;
	try {
		ProductDao dao = new ProductDao();
		list = dao.selectPopular(conn, 4);
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
<title>노지마켓 - 캠핑용품 쇼핑몰</title>
<link rel="icon" type="image/svg+xml" href="images/logo-mark.svg">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body class="page-white">
<%@ include file="common/header.jsp" %>

<main class="site-main">
	<section class="hero">
		<div class="hero-inner">
			<span class="hero-eyebrow">NOJI MARKET</span>
			<h1>오늘 밤은 노지에서</h1>
			<p>텐트부터 랜턴까지, 캠핑에 필요한 장비를 한곳에서</p>
			<div class="hero-actions">
				<a href="productList.jsp" class="btn">전체 상품 보기</a>
				<a href="productList.jsp?sort=popular" class="btn btn-light">인기 상품 보기</a>
			</div>
			<div class="hero-chips">
				<span>5만 원 이상 무료배송</span>
				<span>평일 오후 2시 전 주문 당일 출고</span>
				<span>주문 접수 단계에서는 바로 취소</span>
			</div>
		</div>
	</section>

	<section class="section section-gray">
		<div class="section-inner">
			<h2 class="section-title">어떤 장비가 필요하세요?</h2>
			<div class="grid-5">
				<c:url var="u1" value="productList.jsp"><c:param name="category" value="텐트·타프"/></c:url>
				<a href="${u1}" class="category-card">
					<span class="cat-icon"><img src="images/icons/cat-tent.svg" width="28" height="28" alt=""></span>
					<span class="cat-name">텐트·타프</span>
					<span class="cat-desc">돔 텐트, 백패킹 텐트, 그늘을 만드는 타프</span>
					<span class="cat-link">보러 가기 →</span>
				</a>
				<c:url var="u2" value="productList.jsp"><c:param name="category" value="침낭·매트"/></c:url>
				<a href="${u2}" class="category-card">
					<span class="cat-icon"><img src="images/icons/cat-mat.svg" width="28" height="28" alt=""></span>
					<span class="cat-name">침낭·매트</span>
					<span class="cat-desc">추운 밤에도 따뜻하고 푹신한 잠자리</span>
					<span class="cat-link">보러 가기 →</span>
				</a>
				<c:url var="u3" value="productList.jsp"><c:param name="category" value="캠핑 가구"/></c:url>
				<a href="${u3}" class="category-card">
					<span class="cat-icon"><img src="images/icons/cat-chair.svg" width="28" height="28" alt=""></span>
					<span class="cat-name">캠핑 가구</span>
					<span class="cat-desc">의자, 테이블, 야전침대로 편안한 사이트</span>
					<span class="cat-link">보러 가기 →</span>
				</a>
				<c:url var="u4" value="productList.jsp"><c:param name="category" value="버너·조리"/></c:url>
				<a href="${u4}" class="category-card">
					<span class="cat-icon"><img src="images/icons/cat-pot.svg" width="28" height="28" alt=""></span>
					<span class="cat-name">버너·조리</span>
					<span class="cat-desc">스토브, 코펠, 그리들로 차리는 캠핑 요리</span>
					<span class="cat-link">보러 가기 →</span>
				</a>
				<c:url var="u5" value="productList.jsp"><c:param name="category" value="랜턴·조명"/></c:url>
				<a href="${u5}" class="category-card">
					<span class="cat-icon"><img src="images/icons/cat-lantern.svg" width="28" height="28" alt=""></span>
					<span class="cat-name">랜턴·조명</span>
					<span class="cat-desc">LED 랜턴부터 헤드랜턴까지 밤을 밝히는 빛</span>
					<span class="cat-link">보러 가기 →</span>
				</a>
			</div>
		</div>
	</section>

	<section class="section section-white">
		<div class="section-inner">
			<div class="section-head">
				<h2 class="section-title">인기 상품</h2>
				<a href="productList.jsp?sort=popular" class="more-link">인기순으로 전체 보기 →</a>
			</div>
			<div class="grid-4 product-grid">
				<c:forEach var="p" items="${list}">
				<%@ include file="common/productCard.jsp" %>
				</c:forEach>
			</div>
		</div>
	</section>

	<section class="section section-gray">
		<div class="section-inner">
			<h2 class="section-title">주문은 이렇게 해요</h2>
			<div class="grid-3">
				<div class="step-card">
					<span class="step-num">1</span>
					<h3>장바구니 담기</h3>
					<p>필요한 장비를 골라 수량을 정하고 담으세요. 로그인하지 않아도 담을 수 있어요.</p>
				</div>
				<div class="step-card">
					<span class="step-num">2</span>
					<h3>주문서 작성</h3>
					<p>받는 사람과 주소를 적으면 끝. 상품 합계가 5만 원 이상이면 배송비가 무료예요.</p>
				</div>
				<div class="step-card">
					<span class="step-num">3</span>
					<h3>배송 확인</h3>
					<p>주문 내역에서 배송 상태를 확인하세요. 주문 접수 단계에서는 바로 취소할 수 있어요.</p>
				</div>
			</div>
		</div>
	</section>
</main>

<%@ include file="common/footer.jsp" %>
</body>
</html>
