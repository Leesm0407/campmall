<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.dao.*,my.model.*,my.util.*"%>
<%
	// 아이디 중복 확인 팝업 - CHAPTER10/joinIdCheck.jsp 방식
	request.setCharacterEncoding("utf-8");
	String userId = request.getParameter("userId");
	if (userId == null) userId = "";
	userId = userId.trim();
	boolean valid = userId.matches("[A-Za-z0-9]{4,20}");   // 영문·숫자 4~20자
	boolean result = false;                                // 이미 있는 아이디면 true
	if (valid) {
		Connection conn = ConnectionProvider.getConnection();
		try {
			UserDao dao = new UserDao();
			result = dao.idCheck(conn, userId);
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			JdbcUtil.close(conn);
		}
	} else {
		userId = "";   // 형식이 틀린 값은 화면에 다시 쓰지 않는다
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>아이디 중복 확인 | 모닥</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css?v=20261123">
</head>
<body class="page-white">
<div class="popup">
	<h1>아이디 중복 확인</h1>
<% if (!valid) { %>
	<p class="result-no">아이디는 영문과 숫자로 4~20자 입력해 주세요.</p>
<% } else if (result) { %>
	<p class="result-no"><b><%= userId %></b>은(는) 이미 사용 중인 아이디예요.</p>
<% } else { %>
	<p class="result-ok"><b><%= userId %></b>은(는) 사용할 수 있는 아이디예요.</p>
	<button type="button" class="btn btn-forest btn-block" onclick="useId()">이 아이디 사용하기</button>
<% } %>
	<form action="joinIdCheck.jsp" method="get" name="wfr" class="input-row">
		<input type="text" name="userId" class="input" value="<%= userId %>" maxlength="20" aria-label="아이디">
		<button type="submit" class="btn btn-gray">다시 확인</button>
	</form>
</div>
<script type="text/javascript">
// 확인한 아이디를 회원가입 창(opener)에 넣고 팝업을 닫는다
function useId() {
	opener.document.fr.userId.value = "<%= userId %>";
	opener.document.fr.idChecked.value = "Y";
	window.close();
}
</script>
</body>
</html>
