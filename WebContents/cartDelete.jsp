<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,my.model.*" %>
<%
	// 장바구니에서 상품 하나 빼기 (pro0928의 cartdelete.jsp는 전체 비우기였지만 여기서는 상품 하나씩)
	request.setCharacterEncoding("utf-8");
	int productId = 0;
	try {
		productId = Integer.parseInt(request.getParameter("productId"));
	} catch (NumberFormatException e) {}

	@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
	if (cart != null) {
		Iterator<Cart> it = cart.iterator();
		while (it.hasNext()) {
			if (it.next().getProductId() == productId) it.remove();
		}
	}
	response.sendRedirect("cart.jsp");
%>
