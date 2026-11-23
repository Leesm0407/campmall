<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 주문 상태 변경 (주문 접수 / 배송 준비 / 배송 중 / 배송 완료 / 취소)
	// 취소로 바꾸면 재고를 되돌리고, 이미 취소된 주문은 바꾸지 않는다 (트랜잭션)
	request.setCharacterEncoding("utf-8");
	int purchaseId = 0;
	try {
		purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
	} catch (NumberFormatException e) {}
	String status = request.getParameter("status");
	String filter = request.getParameter("filter");   // 보고 있던 상태별 보기로 돌아가기 위해
	boolean fromDetail = "detail".equals(request.getParameter("from"));
	String msg = null;

	if (!Purchase.isStatus(status)) {
		msg = "상태 값이 올바르지 않아요.";
	} else {
		Connection conn = ConnectionProvider.getConnection();
		try {
			conn.setAutoCommit(false);
			PurchaseDao dao = new PurchaseDao();
			String now = dao.selectStatusForUpdate(conn, purchaseId);   // 주문 행을 잠그고 지금 상태를 읽는다
			String no = "O-" + String.format("%04d", purchaseId);
			if (now == null) {
				msg = "찾는 주문이 없어요.";
			} else if ("취소".equals(now)) {
				msg = "이미 취소된 주문은 상태를 바꿀 수 없어요.";
			} else if (now.equals(status)) {
				msg = no + " 주문은 이미 '" + status + "' 상태예요.";
			} else {
				dao.updateStatus(conn, purchaseId, status);
				if ("취소".equals(status)) {
					ProductDao pDao = new ProductDao();
					for (PurchaseItem item : dao.selectItems(conn, purchaseId)) {
						pDao.increaseStock(conn, item.getProductId(), item.getAmount());   // 재고 되돌리기
					}
					msg = no + " 주문을 취소하고 재고를 되돌렸어요.";
				} else {
					msg = no + " 주문을 '" + status + "' 상태로 바꿨어요.";
				}
			}
			conn.commit();
		} catch (SQLException e) {
			e.printStackTrace();
			JdbcUtil.rollback(conn);
			msg = "상태를 바꾸지 못했어요. 잠시 후 다시 시도해 주세요.";
		} finally {
			JdbcUtil.close(conn);
		}
	}
	String back = "orderList.jsp";
	if (fromDetail) {
		back = "orderDetail.jsp?purchaseId=" + purchaseId;
	} else if (Purchase.isStatus(filter)) {
		back += "?status=" + java.net.URLEncoder.encode(filter, "UTF-8");
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>주문 관리 | 모닥</title>
</head>
<body>
<script>
	alert("<%= msg %>");
	location.href = "<%= back %>";
</script>
</body>
</html>
