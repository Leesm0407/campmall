package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Purchase;
import my.model.PurchaseItem;
import my.util.JdbcUtil;

// 주문(purchase, purchaseitem 테이블) DAO - 기존 PurchaseDao 형태를 따름
// conn은 여기서 닫지 않고, JSP의 finally에서 JdbcUtil.close(conn)으로 닫는다.
public class PurchaseDao {

	// 목록 화면용: 주문 + 주문한 회원 이름 + 첫 번째 상품 이름 + 상품 종류 수 (11~13번째 컬럼)
	private static final String SELECT_JOIN =
			"select o.*, u.name,"
			+ " (select p.name from purchaseitem i join product p on i.productId = p.productId"
			+ "   where i.purchaseId = o.purchaseId order by i.itemId limit 1),"
			+ " (select count(*) from purchaseitem i where i.purchaseId = o.purchaseId)"
			+ " from purchase o join user u on o.userId = u.userId";

	// 주문 저장. 새로 만들어진 주문 번호(purchaseId)를 돌려준다
	public int insert(Connection conn, Purchase purchase)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement
			("insert into purchase (userId,receiver,phone,address,memo,deliveryFee,total,status,purchaseDate)"
					+ " values(?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
			pstmt.setString(1, purchase.getUserId());
			pstmt.setString(2, purchase.getReceiver());
			pstmt.setString(3, purchase.getPhone());
			pstmt.setString(4, purchase.getAddress());
			pstmt.setString(5, purchase.getMemo());
			pstmt.setInt(6, purchase.getDeliveryFee());
			pstmt.setInt(7, purchase.getTotal());
			pstmt.setString(8, purchase.getStatus());
			pstmt.setTimestamp(9, new Timestamp(purchase.getPurchaseDate().getTime()));
			pstmt.executeUpdate();
			rs = pstmt.getGeneratedKeys();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	public void insertItem(Connection conn, PurchaseItem item)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement
			("insert into purchaseitem (purchaseId,productId,amount,price) values(?,?,?,?)");
			pstmt.setInt(1, item.getPurchaseId());
			pstmt.setInt(2, item.getProductId());
			pstmt.setInt(3, item.getAmount());
			pstmt.setInt(4, item.getPrice());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public Purchase selectById(Connection conn, int purchaseId)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Purchase purchase = null;
		try {
			pstmt = conn.prepareStatement(SELECT_JOIN + " where o.purchaseId = ?");
			pstmt.setInt(1, purchaseId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				purchase = makePurchase(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return purchase;
	}

	// 취소·상태 변경할 때 사용: 주문 행을 잠그고 상태만 가져온다 (트랜잭션 안에서만 의미 있음)
	// 사용자 취소와 관리자 취소가 동시에 와도 재고가 두 번 되돌아가지 않는다
	public String selectStatusForUpdate(Connection conn, int purchaseId)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select status from purchase where purchaseId = ? for update");
			pstmt.setInt(1, purchaseId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				return rs.getString(1);
			}
			return null;
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// 주문 상품 목록 (상품 이름·사진 포함)
	public List<PurchaseItem> selectItems(Connection conn, int purchaseId)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<PurchaseItem> list = new ArrayList<PurchaseItem>();
		try {
			pstmt = conn.prepareStatement
			("select i.*, p.name, p.image from purchaseitem i join product p on i.productId = p.productId"
					+ " where i.purchaseId = ? order by i.itemId");
			pstmt.setInt(1, purchaseId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				PurchaseItem item = new PurchaseItem();
				item.setItemId(rs.getInt(1));
				item.setPurchaseId(rs.getInt(2));
				item.setProductId(rs.getInt(3));
				item.setAmount(rs.getInt(4));
				item.setPrice(rs.getInt(5));
				item.setName(rs.getString(6));
				item.setImage(rs.getString(7));
				list.add(item);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 내 주문 내역 (최근 주문이 위로)
	public List<Purchase> selectByUser(Connection conn, String userId)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Purchase> list = new ArrayList<Purchase>();
		try {
			pstmt = conn.prepareStatement(SELECT_JOIN + " where o.userId = ? order by o.purchaseId desc");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makePurchase(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 주문 목록. status가 null이면 전체 (최근 주문이 위로)
	public List<Purchase> selectList(Connection conn, String status)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Purchase> list = new ArrayList<Purchase>();
		try {
			if (status == null) {
				pstmt = conn.prepareStatement(SELECT_JOIN + " order by o.purchaseId desc");
			} else {
				pstmt = conn.prepareStatement(SELECT_JOIN + " where o.status = ? order by o.purchaseId desc");
				pstmt.setString(1, status);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makePurchase(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 홈: 최근 주문 count건
	public List<Purchase> selectRecent(Connection conn, int count)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Purchase> list = new ArrayList<Purchase>();
		try {
			pstmt = conn.prepareStatement(SELECT_JOIN + " order by o.purchaseId desc limit ?");
			pstmt.setInt(1, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makePurchase(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	public void updateStatus(Connection conn, int purchaseId, String status)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update purchase set status = ? where purchaseId = ?");
			pstmt.setString(1, status);
			pstmt.setInt(2, purchaseId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 오늘 들어온 주문 수 (취소 제외)
	public int countToday(Connection conn) throws SQLException {
		return selectInt(conn, "select count(*) from purchase"
				+ " where status <> '취소' and date(purchaseDate) = curdate()", null);
	}

	// 배송 대기 주문 수 (주문 접수 + 배송 준비)
	public int countWaiting(Connection conn) throws SQLException {
		return selectInt(conn, "select count(*) from purchase where status in ('주문 접수', '배송 준비')", null);
	}

	// 상태별 주문 수
	public int countByStatus(Connection conn, String status) throws SQLException {
		return selectInt(conn, "select count(*) from purchase where status = ?", status);
	}

	// 이번 달 매출 = 이번 달 주문의 결제 금액 합계 (취소 제외)
	public int sumThisMonth(Connection conn) throws SQLException {
		return selectInt(conn, "select ifnull(sum(total), 0) from purchase where status <> '취소'"
				+ " and year(purchaseDate) = year(curdate()) and month(purchaseDate) = month(curdate())", null);
	}

	// 이 상품이 들어간 주문 기록 건수 (상품 삭제 전에 확인)
	public int countByProduct(Connection conn, int productId) throws SQLException {
		return selectInt(conn, "select count(*) from purchaseitem where productId = ?", productId);
	}

	// count(*) 같은 숫자 하나를 가져오는 공통 메서드 (? 값이 없으면 param에 null)
	private int selectInt(Connection conn, String sql, Object param)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement(sql);
			if (param != null) pstmt.setObject(1, param);
			rs = pstmt.executeQuery();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// join 결과 한 줄을 Purchase 객체로 바꾼다
	// 컬럼 순서: purchaseId, userId, receiver, phone, address, memo, deliveryFee, total, status, purchaseDate,
	//           회원 이름, 첫 상품 이름, 상품 종류 수
	private Purchase makePurchase(ResultSet rs) throws SQLException {
		Purchase p = new Purchase();
		p.setPurchaseId(rs.getInt(1));
		p.setUserId(rs.getString(2));
		p.setReceiver(rs.getString(3));
		p.setPhone(rs.getString(4));
		p.setAddress(rs.getString(5));
		p.setMemo(rs.getString(6));
		p.setDeliveryFee(rs.getInt(7));
		p.setTotal(rs.getInt(8));
		p.setStatus(rs.getString(9));
		p.setPurchaseDate(rs.getTimestamp(10));
		p.setUserName(rs.getString(11));
		p.setFirstName(rs.getString(12));
		p.setItemCount(rs.getInt(13));
		return p;
	}
}
