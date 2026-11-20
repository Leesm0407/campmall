<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 회원 관리 : 회원 목록 + 회원별 주문 수
	Connection conn = ConnectionProvider.getConnection();
	List<User> list = null;
	try {
		UserDao dao = new UserDao();
		list = dao.selectList(conn);
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
<title>회원 관리 | 노지마켓</title>
<link rel="icon" type="image/svg+xml" href="../images/logo-mark.svg">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>회원 관리</h1>
			<p>가입한 회원 ${list.size()}명</p>
		</div>
		<div class="admin-user">
			<span><b><c:out value="${sessionScope.NAME}"/></b>님</span>
			<a href="../logout.jsp" class="btn btn-gray">로그아웃</a>
		</div>
	</div>

	<div class="table-card">
		<table class="data-table compact">
			<thead>
				<tr>
					<th scope="col">아이디</th>
					<th scope="col">이름</th>
					<th scope="col">전화번호</th>
					<th scope="col">가입일</th>
					<th scope="col" class="right">주문 수</th>
					<th scope="col">구분</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="u" items="${list}">
				<tr>
					<td class="strong">${u.userId}</td>
					<td><c:out value="${u.name}"/></td>
					<td><c:out value="${u.phone}"/></td>
					<td><fmt:formatDate value="${u.registerTime}" pattern="yyyy-MM-dd HH:mm"/></td>
						<td class="right">${u.orderCount}건</td>
					<td><span class="${u.userId == 'admin' ? 'badge-cat' : 'status'}">${u.userId == 'admin' ? '관리자' : '회원'}</span></td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
</main>
</body>
</html>
