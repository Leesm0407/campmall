<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="user" class="my.model.User"/>
<jsp:setProperty property="*" name="user"/>
<%
	// 회원가입 저장 - CHAPTER10/result.jsp 방식 (useBean으로 폼 값을 User에 담아 insert)
	String userId = user.getUserId() == null ? "" : user.getUserId().trim();
	String password = user.getPassword() == null ? "" : user.getPassword();
	String password2 = request.getParameter("password2");
	String name = user.getName() == null ? "" : user.getName().trim();
	String phone = user.getPhone() == null ? "" : user.getPhone().trim();

	// 브라우저 검사와 같은 규칙을 서버에서도 한 번 더 확인
	String msg = null;
	if (!userId.matches("[A-Za-z0-9]{4,20}")) msg = "아이디는 영문과 숫자로 4~20자 입력해 주세요.";
	else if (password.length() < 8 || !password.matches(".*[0-9].*") || !password.matches(".*[a-zA-Z].*")
			|| !password.matches(".*[^a-zA-Z0-9].*")) msg = "비밀번호는 8자 이상, 문자·숫자·특수문자를 모두 포함해야 해요.";
	else if (!password.equals(password2)) msg = "비밀번호가 일치하지 않아요.";
	else if (name.isEmpty() || name.length() > 30) msg = "이름을 입력해 주세요.";
	else if (!phone.matches("[0-9-]{9,13}")) msg = "전화번호를 숫자와 -로 입력해 주세요.";

	if (msg == null) {
		Connection conn = ConnectionProvider.getConnection();
		try {
			UserDao dao = new UserDao();
			if (dao.idCheck(conn, userId)) {
				msg = "이미 사용 중인 아이디예요.";
			} else {
				user.setUserId(userId);
				user.setName(name);
				user.setPhone(phone);
				user.setPassword(HashUtil.sha256(password));   // 비밀번호는 SHA-256으로 바꿔서 저장
				user.setRegisterTime(new java.util.Date());
				dao.insert(conn, user);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			msg = "가입하지 못했어요. 잠시 후 다시 시도해 주세요.";
		} finally {
			JdbcUtil.close(conn);
		}
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>회원가입 | 노지마켓</title>
</head>
<body>
<script>
<% if (msg == null) { %>
	alert("회원가입이 완료되었어요. 로그인해 주세요.");
	location.href = "loginForm.jsp";
<% } else { %>
	alert("<%= msg %>");
	history.go(-1);
<% } %>
</script>
</body>
</html>
