<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	// 이미 로그인했으면 메인으로
	if (session.getAttribute("LOGIN") != null) {
		response.sendRedirect("index.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>로그인 | 모닥</title>
<link rel="icon" type="image/png" href="images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<%-- 로그인 폼 - CHAPTER10/loginForm.jsp 방식 (userId, password를 login.jsp로) --%>
<main class="auth-wrap">
	<form class="auth-card" name="form1" method="post" action="login.jsp" onsubmit="return checkLogin(this)">
		<input type="hidden" name="returnUrl" value="<c:out value="${param.returnUrl}"/>">
		<div class="auth-title">
			<h1>로그인</h1>
			<p>주문하려면 로그인해 주세요.</p>
		</div>
		<div class="field">
			<label for="idfield">아이디</label>
			<input type="text" name="userId" id="idfield" class="input" autocomplete="username">
		</div>
		<div class="field">
			<label for="pwfield">비밀번호</label>
			<input type="password" name="password" id="pwfield" class="input" autocomplete="current-password">
		</div>
		<button type="submit" class="btn btn-forest btn-lg btn-block">로그인</button>
		<p class="auth-foot">아직 회원이 아니세요? <a href="registerForm.jsp">회원가입</a></p>
		<p class="auth-note">관리자 계정으로 로그인하면 관리자 화면으로 이동해요.</p>
	</form>
</main>

<%@ include file="common/footer.jsp" %>
<script type="text/javascript">
function checkLogin(frm) {
	if (frm.userId.value.trim() == "" || frm.password.value == "") {
		alert("아이디와 비밀번호를 입력해 주세요.");
		return false;
	}
	return true;
}
</script>
</body>
</html>
