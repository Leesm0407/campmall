package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Product;
import my.util.JdbcUtil;

// 상품(product 테이블) DAO - 기존 MovieDao 형태를 따름
// conn은 여기서 닫지 않고, JSP의 finally에서 JdbcUtil.close(conn)으로 닫는다.
public class ProductDao {

	// 목록 조회용: 상품 + 판매 수량(취소된 주문 제외)을 9번째 컬럼으로 함께 가져온다
	private static final String SELECT_WITH_SOLD =
			"select p.*, ifnull(s.sold, 0) from product p"
			+ " left join (select i.productId, sum(i.amount) sold from purchaseitem i"
			+ "   join purchase o on i.purchaseId = o.purchaseId"
			+ "   where o.status <> '취소' group by i.productId) s"
			+ " on p.productId = s.productId";

	// 기본 정렬: 카테고리 순서 → 등록 순서
	private static final String ORDER_DEFAULT =
			" order by field(p.category, '텐트·타프', '침낭·매트', '캠핑 가구', '버너·조리', '랜턴·조명'), p.productId";

	// 정렬 값 → order by 문. 정해진 값만 쓰고, 요청 값을 SQL에 직접 붙이지 않는다 (기존 selectOrder 문제 수정)
	public static String orderBy(String sort) {
		if ("popular".equals(sort)) return " order by ifnull(s.sold, 0) desc, p.productId";
		if ("low".equals(sort)) return " order by p.price, p.productId";
		if ("high".equals(sort)) return " order by p.price desc, p.productId";
		return ORDER_DEFAULT;
	}

	public void insert(Connection conn, Product product)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement
			("insert into product (name,category,price,stock,image,description,registerTime)"
					+ " values(?,?,?,?,?,?,?)");
			pstmt.setString(1, product.getName());
			pstmt.setString(2, product.getCategory());
			pstmt.setInt(3, product.getPrice());
			pstmt.setInt(4, product.getStock());
			pstmt.setString(5, product.getImage());
			pstmt.setString(6, product.getDescription());
			pstmt.setTimestamp(7, new Timestamp(product.getRegisterTime().getTime()));
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public Product selectById(Connection conn, int productId)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Product product = null;
		try {
			pstmt = conn.prepareStatement(SELECT_WITH_SOLD + " where p.productId = ?");
			pstmt.setInt(1, productId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				product = makeProduct(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return product;
	}

	// category가 null이면 전체. sort는 orderBy()에 정해진 값(popular, low, high)만 쓰고 나머지는 기본 정렬
	public List<Product> selectList(Connection conn, String category, String sort)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Product> list = new ArrayList<Product>();
		try {
			if (category == null) {
				pstmt = conn.prepareStatement(SELECT_WITH_SOLD + orderBy(sort));
			} else {
				pstmt = conn.prepareStatement(SELECT_WITH_SOLD + " where p.category = ?" + orderBy(sort));
				pstmt.setString(1, category);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeProduct(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 메인 화면 인기 상품: 판매 수량(취소 제외)이 많은 순으로 count개
	public List<Product> selectPopular(Connection conn, int count)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Product> list = new ArrayList<Product>();
		try {
			pstmt = conn.prepareStatement(SELECT_WITH_SOLD + orderBy("popular") + " limit ?");
			pstmt.setInt(1, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeProduct(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 홈: 재고가 적은 순으로 count개
	public List<Product> selectLowStock(Connection conn, int count)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Product> list = new ArrayList<Product>();
		try {
			pstmt = conn.prepareStatement(SELECT_WITH_SOLD + " order by p.stock, p.productId limit ?");
			pstmt.setInt(1, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeProduct(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	public void update(Connection conn, Product product)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement
			("update product set name=?, category=?, price=?, stock=?, image=?, description=?"
					+ " where productId=?");
			pstmt.setString(1, product.getName());
			pstmt.setString(2, product.getCategory());
			pstmt.setInt(3, product.getPrice());
			pstmt.setInt(4, product.getStock());
			pstmt.setString(5, product.getImage());
			pstmt.setString(6, product.getDescription());
			pstmt.setInt(7, product.getProductId());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 재고 줄이기 (주문할 때, 트랜잭션 안에서 사용)
	// 재고가 amount개 이상일 때만 줄이므로, 동시에 주문해도 재고가 0 밑으로 내려가지 않는다.
	// 줄였으면 1, 재고가 모자라면 0을 돌려준다.
	public int decreaseStock(Connection conn, int productId, int amount)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement
			("update product set stock = stock - ? where productId = ? and stock >= ?");
			pstmt.setInt(1, amount);
			pstmt.setInt(2, productId);
			pstmt.setInt(3, amount);
			return pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 재고 되돌리기 (주문 취소할 때, 트랜잭션 안에서 사용)
	public void increaseStock(Connection conn, int productId, int amount)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update product set stock = stock + ? where productId = ?");
			pstmt.setInt(1, amount);
			pstmt.setInt(2, productId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public void deleteById(Connection conn, int productId)
			throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from product where productId = ?");
			pstmt.setInt(1, productId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public int selectCount(Connection conn) throws SQLException {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select count(*) from product");
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(stmt);
		}
	}

	// 품절(재고 0) + 품절 임박(재고 1 ~ LOW_STOCK) 상품 수
	public int countLowStock(Connection conn) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select count(*) from product where stock <= ?");
			pstmt.setInt(1, Product.LOW_STOCK);
			rs = pstmt.executeQuery();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// ResultSet의 한 줄을 Product 객체로 바꾼다
	// 컬럼 순서: productId, name, category, price, stock, image, description, registerTime, 판매 수량
	private Product makeProduct(ResultSet rs) throws SQLException {
		Product product = new Product();
		product.setProductId(rs.getInt(1));
		product.setName(rs.getString(2));
		product.setCategory(rs.getString(3));
		product.setPrice(rs.getInt(4));
		product.setStock(rs.getInt(5));
		product.setImage(rs.getString(6));
		product.setDescription(rs.getString(7));
		product.setRegisterTime(rs.getTimestamp(8));
		product.setSold(rs.getInt(9));
		return product;
	}
}
