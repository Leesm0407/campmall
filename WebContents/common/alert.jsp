<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 안내 메시지를 alert로 보여주고 다른 화면으로 보내는 공통 화면 (기존 alert + location.href 방식)
	// 쓰는 쪽: request.setAttribute("msg", "..."); request.setAttribute("url", "...");
	//         pageContext.forward("/common/alert.jsp"); return;
	// 화면을 그리기 전에 바로 끝내야 할 때(없는 상품, 남의 주문 등) 쓴다.
	String msg = (String) request.getAttribute("msg");
	String url = (String) request.getAttribute("url");
	if (msg == null) msg = "잘못된 접근이에요.";
	if (url == null) url = request.getContextPath() + "/index.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>안내 | 모닥</title>
</head>
<body>
<script>
	alert("<%= msg %>");
	location.href = "<%= url %>";
</script>
</body>
</html>
