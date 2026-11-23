<%@ page pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="ko_KR"/><%-- 가격을 158,000처럼 쉼표로 표시 --%>
<%-- 사용자 화면 공통 헤더 : 각 화면에서 <%@ include file="common/header.jsp" %> 로 넣는다 --%>
<c:set var="headerUri" value="${pageContext.request.requestURI}"/>
<c:set var="onList" value="${fn:endsWith(headerUri, 'productList.jsp')}"/>
<c:set var="navCategories" value="<%=my.model.Product.CATEGORIES%>"/>
<header class="site-header">
	<div class="header-inner">
		<a href="index.jsp" class="logo" aria-label="모닥 처음 화면">
			<img src="images/logo-mark.png" alt="">
			<span class="logo-text"><b>모닥</b><small>MODAK</small></span>
		</a>
		<nav class="main-nav" aria-label="주 메뉴">
			<c:forEach var="navCat" items="${navCategories}">
			<c:url var="navUrl" value="productList.jsp"><c:param name="category" value="${navCat}"/></c:url>
			<a href="${navUrl}" class="${onList && param.category == navCat ? 'active' : ''}">${navCat}</a>
			</c:forEach>
			<a href="myOrder.jsp" class="${fn:endsWith(headerUri, 'myOrder.jsp') || fn:endsWith(headerUri, 'orderDetail.jsp') ? 'active' : ''}">주문 내역</a>
		</nav>
		<div class="header-actions">
			<a href="cart.jsp" class="btn btn-gray cart-link">장바구니 <span class="cart-count">${fn:length(sessionScope.CART)}</span></a>
			<c:choose>
				<c:when test="${empty sessionScope.LOGIN}">
					<a href="loginForm.jsp" class="btn btn-outline">로그인</a>
					<a href="registerForm.jsp" class="btn btn-forest">회원가입</a>
				</c:when>
				<c:otherwise>
					<span class="hello"><b><c:out value="${sessionScope.NAME}"/></b>님</span>
					<c:if test="${sessionScope.LOGIN == 'admin'}">
						<a href="admin/index.jsp" class="btn btn-outline">관리자 화면</a>
					</c:if>
					<a href="logout.jsp" class="btn btn-gray">로그아웃</a>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</header>
