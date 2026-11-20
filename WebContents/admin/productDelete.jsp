<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 상품 삭제 - CHAPTER10/delete.jsp 방식. 주문 기록이 있는 상품은 지우지 않는다
	request.setCharacterEncoding("utf-8");
	int productId = 0;
	try {
		productId = Integer.parseInt(request.getParameter("productId"));
	} catch (NumberFormatException e) {}
	String msg = null;

	Connection conn = ConnectionProvider.getConnection();
	try {
		PurchaseDao pDao = new PurchaseDao();
		ProductDao dao = new ProductDao();
		if (dao.selectById(conn, productId) == null) {
			msg = "찾는 상품이 없어요.";
		} else if (pDao.countByProduct(conn, productId) > 0) {
			msg = "주문 기록이 있는 상품은 삭제할 수 없어요. 재고를 0으로 바꾸면 품절로 표시돼요.";
		} else {
			dao.deleteById(conn, productId);
			msg = "상품을 삭제했어요.";
		}
	} catch (SQLException e) {
		e.printStackTrace();
		msg = "삭제하지 못했어요. 잠시 후 다시 시도해 주세요.";
	} finally {
		JdbcUtil.close(conn);
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>상품 삭제 | 노지마켓</title>
</head>
<body>
<script>
	alert("<%= msg %>");
	location.href = "productList.jsp";
</script>
</body>
</html>
