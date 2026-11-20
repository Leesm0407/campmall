<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="common/loginCheck.jsp" %>
<%
	// 주문 저장 - CHAPTER10/cartpurchase.jsp + purchase.jsp 방식
	// 금액은 브라우저에서 보낸 값을 쓰지 않고 DB 가격으로 다시 계산한다.
	// 트랜잭션 안에서 재고를 줄이고, 한 상품이라도 재고가 모자라면 rollback 한다.
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	if (!"POST".equals(request.getMethod())) {
		response.sendRedirect("cart.jsp");
		return;
	}
	String receiver = request.getParameter("receiver");
	String phone = request.getParameter("phone");
	String address = request.getParameter("address");
	String memo = request.getParameter("memo");
	receiver = receiver == null ? "" : receiver.trim();
	phone = phone == null ? "" : phone.trim();
	address = address == null ? "" : address.trim();
	memo = memo == null ? "" : memo.trim();

	String msg = null;
	String next = null;       // 실패했을 때 이동할 곳 (null이면 이전 화면)
	int purchaseId = 0;

	// 1) 입력값 확인 (주문서와 같은 규칙)
	if (receiver.isEmpty() || receiver.length() > 30) msg = "받는 사람을 입력해 주세요.";
	else if (!phone.matches("[0-9-]{9,13}")) msg = "전화번호를 숫자와 -로 입력해 주세요.";
	else if (address.length() < 5 || address.length() > 200) msg = "주소를 자세히 입력해 주세요.";
	else if (memo.length() > 200) msg = "요청사항은 200자 이내로 입력해 주세요.";

	// 2) 주문서에서 받은 한 번용 값 확인 (새로고침·두 번 누르기로 같은 주문이 두 번 들어오는 것 방지)
	List<Cart> items = new ArrayList<Cart>();
	if (msg == null) {
		synchronized (session) {
			String token = request.getParameter("token");
			Object saved = session.getAttribute("ORDER_TOKEN");
			@SuppressWarnings("unchecked") List<Cart> cart = (List<Cart>) session.getAttribute("CART");
			if (saved == null || !saved.equals(token)) {
				msg = "이미 처리된 주문이에요. 주문 내역을 확인해 주세요.";
				next = "myOrder.jsp";
			} else if (cart == null || cart.isEmpty()) {
				msg = "장바구니가 비어 있어요.";
				next = "cart.jsp";
			} else {
				session.removeAttribute("ORDER_TOKEN");
				items.addAll(cart);
			}
		}
	}

	// 3) 트랜잭션 : 재고 줄이기 → 주문 저장 → 주문 상품 저장
	if (msg == null) {
		// 여러 사람이 동시에 주문해도 서로 기다리다 멈추지 않게 상품 번호 순서로 처리한다
		items.sort((a, b) -> Integer.compare(a.getProductId(), b.getProductId()));
		Connection conn = ConnectionProvider.getConnection();
		try {
			conn.setAutoCommit(false);
			ProductDao dao = new ProductDao();
			PurchaseDao pDao = new PurchaseDao();
			List<PurchaseItem> saveItems = new ArrayList<PurchaseItem>();
			int itemTotal = 0;
			for (Cart c : items) {
				Product product = dao.selectById(conn, c.getProductId());
				if (product == null) {
					msg = "판매가 끝난 상품이 장바구니에 있어요. 장바구니를 확인해 주세요.";
					break;
				}
				// 재고가 주문 수량 이상일 때만 줄인다. 0줄이 바뀌었으면 재고 부족
				if (dao.decreaseStock(conn, c.getProductId(), c.getAmount()) == 0) {
					// 상품 이름은 alert("...") 안에 들어가므로 따옴표·꺾쇠를 바꿔 둔다
					msg = product.getName().replace("\\", "").replace("\"", "'").replace("<", "(").replace(">", ")")
							+ " 재고가 부족해요.";
					break;
				}
				itemTotal += product.getPrice() * c.getAmount();   // DB 가격으로 계산
				saveItems.add(new PurchaseItem(0, c.getProductId(), c.getAmount(), product.getPrice()));
			}
			if (msg != null) {
				conn.rollback();   // 이미 줄인 재고도 모두 되돌린다
				next = "cart.jsp";
			} else {
				int deliveryFee = Purchase.deliveryFeeOf(itemTotal);
				Purchase purchase = new Purchase(loginId, receiver, phone, address, memo.isEmpty() ? null : memo,
						deliveryFee, itemTotal + deliveryFee, "주문 접수", new java.util.Date());
				purchaseId = pDao.insert(conn, purchase);
				for (PurchaseItem item : saveItems) {
					item.setPurchaseId(purchaseId);
					pDao.insertItem(conn, item);
				}
				conn.commit();
			}
		} catch (SQLException e) {
			e.printStackTrace();
			JdbcUtil.rollback(conn);
			msg = "주문을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.";
			next = "cart.jsp";
		} finally {
			JdbcUtil.close(conn);
		}
	}

	// 4) 성공 : 장바구니 비우고 주문 내역으로 (redirect라서 새로고침해도 다시 주문되지 않는다)
	if (msg == null) {
		session.removeAttribute("CART");
		response.sendRedirect("myOrder.jsp?ordered=" + purchaseId);
		return;
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>주문 | 노지마켓</title>
</head>
<body>
<script>
	alert("<%= msg %>");
<% if (next == null) { %>
	history.go(-1);
<% } else { %>
	location.href = "<%= next %>";
<% } %>
</script>
</body>
</html>
