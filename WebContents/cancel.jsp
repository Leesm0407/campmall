<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="common/loginCheck.jsp" %>
<%
	// 주문 취소 : 본인 주문이고 '주문 접수' 상태일 때만 '취소'로 바꾸고 재고를 되돌린다 (트랜잭션)
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	String msg = null;
	int purchaseId = 0;
	try {
		purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
	} catch (NumberFormatException e) {}

	Connection conn = ConnectionProvider.getConnection();
	try {
		conn.setAutoCommit(false);
		PurchaseDao dao = new PurchaseDao();
		Purchase purchase = dao.selectById(conn, purchaseId);
		if (purchase == null || !purchase.getUserId().equals(loginId)) {
			msg = "본인 주문만 취소할 수 있어요.";
		} else {
			// 주문 행을 잠그고 상태를 다시 읽는다 (관리자가 동시에 상태를 바꿔도 재고가 두 번 되돌아가지 않게)
			String status = dao.selectStatusForUpdate(conn, purchaseId);
			if (!"주문 접수".equals(status)) {
				msg = "주문 접수 상태일 때만 취소할 수 있어요.";
			} else {
				dao.updateStatus(conn, purchaseId, "취소");
				ProductDao pDao = new ProductDao();
				for (PurchaseItem item : dao.selectItems(conn, purchaseId)) {
					pDao.increaseStock(conn, item.getProductId(), item.getAmount());   // 재고 되돌리기
				}
				msg = "주문을 취소했어요.";
			}
		}
		conn.commit();
	} catch (SQLException e) {
		e.printStackTrace();
		JdbcUtil.rollback(conn);
		msg = "취소하지 못했어요. 잠시 후 다시 시도해 주세요.";
	} finally {
		JdbcUtil.close(conn);
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>주문 취소 | 모닥</title>
</head>
<body>
<script>
	alert("<%= msg %>");
	location.href = "myOrder.jsp";
</script>
</body>
</html>
