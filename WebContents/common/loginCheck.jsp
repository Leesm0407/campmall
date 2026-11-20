<%@ page pageEncoding="UTF-8"%>
<%
	// 로그인이 필요한 화면 맨 위에 include 한다.
	// 로그인하지 않았으면 로그인 화면으로 보내고, 로그인 후에는 지금 보던 화면으로 돌아오게 한다.
	if (session.getAttribute("LOGIN") == null) {
		String backUrl = request.getRequestURI();
		if (request.getQueryString() != null) {
			backUrl += "?" + request.getQueryString();
		}
		response.sendRedirect(request.getContextPath() + "/loginForm.jsp?returnUrl="
				+ java.net.URLEncoder.encode(backUrl, "UTF-8"));
		return;
	}
%>
