<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%
	// 장바구니 담기 - pro0928 CHAPTER10/putCart.jsp 방식 (세션에 Cart를 담는다)
	// 단, 번호 붙인 속성(movie1, movie2 ...) 대신 List<Cart> 하나("CART")에 담고, 재고는 DB에서 다시 확인한다.
	// 로그인하지 않아도 담을 수 있다. mode=buy(바로 구매)면 담은 뒤 장바구니로 이동한다.
	request.setCharacterEncoding("utf-8");
	int productId = 0;
	int amount = 0;
	try {
		productId = Integer.parseInt(request.getParameter("productId"));
		amount = Integer.parseInt(request.getParameter("amount"));
	} catch (NumberFormatException e) {}
	boolean buy = "buy".equals(request.getParameter("mode"));

	@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
	if (cart == null) {
		cart = new ArrayList<Cart>();
	}

	String msg = null;
	if (amount < 1 || amount > Product.MAX_AMOUNT) {
		msg = "수량은 1~" + Product.MAX_AMOUNT + "개 사이로 골라 주세요.";
	} else {
		Connection conn = ConnectionProvider.getConnection();
		try {
			ProductDao dao = new ProductDao();
			Product product = dao.selectById(conn, productId);
			if (product == null) {
				msg = "찾는 상품이 없어요.";
			} else if (product.isSoldOut()) {
				msg = "품절된 상품은 담을 수 없어요.";
			} else {
				// 같은 상품이 이미 있으면 수량을 더한다
				Cart found = null;
				for (Cart c : cart) {
					if (c.getProductId() == productId) found = c;
				}
				int inCart = (found == null) ? 0 : found.getAmount();
				int newAmount = inCart + amount;
				if (newAmount > product.getStock()) {
					msg = "재고가 부족해요. 남은 재고는 " + product.getStock() + "개"
							+ (inCart > 0 ? "이고, 장바구니에 이미 " + inCart + "개 담겨 있어요." : "예요.");
				} else if (newAmount > Product.MAX_AMOUNT) {
					msg = "한 상품은 최대 " + Product.MAX_AMOUNT + "개까지 담을 수 있어요. (장바구니에 " + inCart + "개)";
				} else if (found == null) {
					cart.add(new Cart(productId, amount));
				} else {
					found.setAmount(newAmount);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			msg = "장바구니에 담지 못했어요. 잠시 후 다시 시도해 주세요.";
		} finally {
			JdbcUtil.close(conn);
		}
	}
	if (msg == null) {
		session.setAttribute("CART", cart);
		if (buy) {   // 바로 구매 : 담은 뒤 장바구니로
			response.sendRedirect("cart.jsp");
			return;
		}
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>장바구니 담기 | 모닥</title>
</head>
<body>
<script>
<% if (msg == null) { %>
	if (confirm("장바구니에 담았어요. 장바구니로 이동할까요?")) {
		location.href = "cart.jsp";
	} else {
		history.go(-1);
	}
<% } else { %>
	alert("<%= msg %>");
	history.go(-1);
<% } %>
</script>
</body>
</html>
