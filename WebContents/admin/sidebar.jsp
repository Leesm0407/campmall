<%@ page pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="ko_KR"/><%-- 금액을 158,000처럼 쉼표로 표시 --%>
<%-- 관리자 화면 왼쪽 메뉴 : 각 관리자 화면에서 include --%>
<c:set var="adminUri" value="${pageContext.request.requestURI}"/>
<nav class="admin-nav" aria-label="관리자 메뉴">
	<a href="index.jsp" class="admin-brand">
		<span class="mark"><img src="../images/logo-mark.svg" alt=""></span>
		노지마켓 관리자
	</a>
	<a href="index.jsp" class="menu ${fn:endsWith(adminUri, '/admin/index.jsp') || fn:endsWith(adminUri, '/admin/') ? 'active' : ''}">관리자 홈</a>
	<a href="productList.jsp" class="menu ${fn:contains(adminUri, '/admin/product') ? 'active' : ''}">상품 관리</a>
	<a href="orderList.jsp" class="menu ${fn:contains(adminUri, '/admin/order') ? 'active' : ''}">주문 관리</a>
	<a href="userList.jsp" class="menu ${fn:contains(adminUri, '/admin/user') ? 'active' : ''}">회원 관리</a>
	<a href="../index.jsp" class="menu to-user">사용자 화면으로 →</a>
</nav>
