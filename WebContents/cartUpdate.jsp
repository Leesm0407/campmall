<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 장바구니 수량 변경 : 재고와 10개 중 작은 값까지만 바꿀 수 있다 (재고는 DB에서 다시 확인)
	request.setCharacterEncoding("utf-8");
	int productId = 0;
	int amount = 0;
	try {
		productId = Integer.parseInt(request.getParameter("productId"));
		amount = Integer.parseInt(request.getParameter("amount"));
	} catch (NumberFormatException e) {}

	@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
	Cart found = null;
	if (cart != null) {
		for (Cart c : cart) {
			if (c.getProductId() == productId) found = c;
		}
	}

	String msg = null;
	if (found == null) {
		msg = "장바구니에 없는 상품이에요.";
	} else if (amount < 1 || amount > Product.MAX_AMOUNT) {
		msg = "수량은 1~" + Product.MAX_AMOUNT + "개 사이로 골라 주세요.";
	} else {
		Connection conn = ConnectionProvider.getConnection();
		try {
			ProductDao dao = new ProductDao();
			Product product = dao.selectById(conn, productId);
			if (product == null) {
				msg = "판매가 끝난 상품이에요. 장바구니에서 삭제해 주세요.";
			} else if (amount > product.getStock()) {
				msg = product.isSoldOut() ? "품절된 상품이에요. 장바구니에서 삭제해 주세요."
						: "재고가 부족해요. 최대 " + product.getStock() + "개까지 주문할 수 있어요.";
			} else {
				found.setAmount(amount);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			msg = "수량을 바꾸지 못했어요. 잠시 후 다시 시도해 주세요.";
		} finally {
			JdbcUtil.close(conn);
		}
	}
	if (msg == null) {
		response.sendRedirect("cart.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>장바구니 | 노지마켓</title>
</head>
<body>
<script>
	alert("<%= msg %>");
	location.href = "cart.jsp";
</script>
</body>
</html>
