<%@ page pageEncoding="UTF-8"%>
<%
	// 관리자 화면 맨 위에 include 한다.
	// 로그인하지 않았으면 로그인 화면으로, 일반 회원이면 메인으로 보낸다. (관리자 = 아이디가 admin)
	if (session.getAttribute("LOGIN") == null) {
		String backUrl = request.getRequestURI();
		if (request.getQueryString() != null) {
			backUrl += "?" + request.getQueryString();
		}
		response.sendRedirect(request.getContextPath() + "/loginForm.jsp?returnUrl="
				+ java.net.URLEncoder.encode(backUrl, "UTF-8"));
		return;
	}
	if (!"admin".equals(session.getAttribute("LOGIN"))) {
		out.println("<script>alert('관리자만 볼 수 있는 화면이에요.'); location.href='"
				+ request.getContextPath() + "/index.jsp';</script>");
		return;
	}
%>
