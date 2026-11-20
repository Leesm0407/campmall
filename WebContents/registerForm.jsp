<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>회원가입 | 노지마켓</title>
<link rel="icon" type="image/svg+xml" href="images/logo-mark.svg">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="common/header.jsp" %>

<%-- 회원가입 폼 - CHAPTER10/register.jsp 방식 (아이디 중복 확인 팝업 + 비밀번호 규칙 검사) --%>
<main class="auth-wrap">
	<form class="auth-card wide" name="fr" method="post" action="register.jsp" onsubmit="return checkForm(this)">
		<input type="hidden" name="idChecked" value="N">
		<div class="auth-title">
			<h1>회원가입</h1>
			<p>가입하고 캠핑 장비를 간편하게 주문하세요.</p>
		</div>
		<div class="field">
			<label for="idfield">아이디</label>
			<div class="input-row">
				<input type="text" name="userId" id="idfield" class="input" maxlength="20" placeholder="영문·숫자 4~20자" autocomplete="username">
				<button type="button" class="btn btn-gray" onclick="winopen()">중복 확인</button>
			</div>
		</div>
		<div class="field">
			<label for="pwfield">비밀번호</label>
			<input type="password" name="password" id="pwfield" class="input" placeholder="8자 이상, 문자·숫자·특수문자 포함" autocomplete="new-password">
		</div>
		<div class="field">
			<label for="pwfield2">비밀번호 확인</label>
			<input type="password" name="password2" id="pwfield2" class="input" autocomplete="new-password">
		</div>
		<div class="field">
			<label for="namefield">이름</label>
			<input type="text" name="name" id="namefield" class="input" maxlength="30">
		</div>
		<div class="field">
			<label for="phonefield">전화번호</label>
			<input type="tel" name="phone" id="phonefield" class="input" maxlength="13" placeholder="010-1234-5678">
		</div>
		<button type="submit" class="btn btn-forest btn-lg btn-block">가입하기</button>
		<p class="auth-foot">이미 회원이세요? <a href="loginForm.jsp">로그인</a></p>
	</form>
</main>

<%@ include file="common/footer.jsp" %>
<script type="text/javascript">
// 아이디 중복 확인 팝업 열기
function winopen() {
	var id = document.fr.userId.value.trim();
	if (!/^[A-Za-z0-9]{4,20}$/.test(id)) {
		alert("아이디는 영문과 숫자로 4~20자 입력해 주세요.");
		document.fr.userId.focus();
		return;
	}
	window.open("joinIdCheck.jsp?userId=" + encodeURIComponent(id), "idcheck", "width=460,height=380");
}
// 중복 확인 후에 아이디를 바꾸면 다시 확인하게 한다
document.fr.userId.addEventListener("input", function () {
	document.fr.idChecked.value = "N";
});
function checkPasswordPattern(str) {
	var pattern1 = /[0-9]/;                    // 숫자
	var pattern2 = /[a-zA-Z]/;                 // 문자
	var pattern3 = /[~!@#$%^&*()_+|<>?:{}]/;   // 특수문자
	if (!pattern1.test(str) || !pattern2.test(str) || !pattern3.test(str) || str.length < 8) {
		alert("비밀번호는 8자리 이상, 문자·숫자·특수문자를 모두 포함해야 합니다.");
		return false;
	}
	return true;
}
function checkForm(frm) {
	if (frm.idChecked.value != "Y") {
		alert("아이디 중복 확인을 해 주세요.");
		return false;
	}
	var pw = frm.password.value;
	var pw2 = frm.password2.value;
	if (!checkPasswordPattern(pw)) {
		frm.password.focus();
		return false;
	}
	if (pw != pw2) {
		alert("비밀번호가 일치하지 않습니다.");
		frm.password2.focus();
		return false;
	}
	if (frm.name.value.trim() == "") {
		alert("이름을 입력해 주세요.");
		frm.name.focus();
		return false;
	}
	if (!/^[0-9-]{9,13}$/.test(frm.phone.value.trim())) {
		alert("전화번호를 숫자와 -로 입력해 주세요. 예) 010-1234-5678");
		frm.phone.focus();
		return false;
	}
	return true;
}
</script>
</body>
</html>
