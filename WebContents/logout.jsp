<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 로그아웃 : 세션을 지우고 메인으로
	session.invalidate();
	response.sendRedirect("index.jsp");
%>
