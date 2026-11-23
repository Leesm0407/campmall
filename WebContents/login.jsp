<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="user" class="my.model.User"/>
<jsp:setProperty property="*" name="user"/>
<%
	// 로그인 처리 - CHAPTER10/login.jsp 방식
	// checkPassword로 확인 → session에 LOGIN(아이디) 저장 → admin이면 관리자 화면으로
	String returnUrl = request.getParameter("returnUrl");
	boolean login = false;
	User member = null;
	if (user.getUserId() != null && user.getPassword() != null) {
		Connection conn = ConnectionProvider.getConnection();
		try {
			UserDao dao = new UserDao();
			login = dao.checkPassword(conn, user.getUserId().trim(), HashUtil.sha256(user.getPassword()));
			if (login) {
				member = dao.selectById(conn, user.getUserId().trim());
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			JdbcUtil.close(conn);
		}
	}
	if (login) {
		session.setAttribute("LOGIN", member.getUserId());
		session.setAttribute("NAME", member.getName());
		// 로그인 전에 보던 화면이 있으면 그 화면으로 (이 사이트 주소일 때만)
		if (returnUrl != null && returnUrl.startsWith(request.getContextPath() + "/") && !returnUrl.startsWith("//")) {
			response.sendRedirect(returnUrl);
		} else if (member.getUserId().equals("admin")) {
			response.sendRedirect("admin/index.jsp");
		} else {
			response.sendRedirect("index.jsp");
		}
		return;
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>로그인 | 모닥</title>
</head>
<body>
<script type="text/javascript">
	alert("아이디 또는 비밀번호가 맞지 않아요.");
	history.go(-1);
</script>
</body>
</html>
