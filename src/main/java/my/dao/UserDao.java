package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.User;
import my.util.JdbcUtil;

// 기존 UserDao를 이 사이트에 맞게 고침
// - phone(전화번호) 컬럼 추가
// - conn은 여기서 닫지 않고 JSP의 finally에서 닫는다 (한 화면에서 DAO를 여러 번 부를 수 있게)
// - checkPassword: 없는 아이디로 로그인하면 오류가 나던 문제 수정
// - 쓰지 않는 selectLike, update, deleteById는 뺌 (원본은 _backup_original 폴더)
// - 관리자 회원 목록에 회원별 주문 수 추가
public class UserDao {

	public void insert(Connection conn, User user)
			throws SQLException {
		PreparedStatement pstmt=null;
		try {
			pstmt = conn.prepareStatement
			("insert into user (userId,password,name,registerTime,phone) values(?,?,?,?,?)");
			pstmt.setString(1, user.getUserId());
			pstmt.setString(2, user.getPassword());
			pstmt.setString(3, user.getName());
			pstmt.setTimestamp(4, new Timestamp(user.getRegisterTime().getTime()));
			pstmt.setString(5, user.getPhone());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 이미 있는 아이디면 true
	public boolean idCheck(Connection conn, String userId)
			throws SQLException {
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement
			("select * from user where userId = ?");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			if (rs.next()){
				return true;
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return false;
	}

	public User selectById(Connection conn, String userId)
			throws SQLException {
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		User user = null;
		try {
			pstmt = conn.prepareStatement
			("select * from user where userId = ?");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			if (rs.next()){
				user = makeUser(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return user;
	}

	// password에는 SHA-256으로 바꾼 값을 넘긴다
	public boolean checkPassword(Connection conn, String userId, String password)
	throws SQLException{
		User user = selectById(conn, userId);
		if (user != null && user.getPassword().equals(password))
			return true;
		else
			return false;
	}

	public int selectCount(Connection conn) throws SQLException {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select count(*) from user");
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(stmt);
		}
	}

	// 회원 목록 (최근 가입한 회원이 위로) + 회원별 주문 수(6번째 컬럼)
	public List<User> selectList(Connection conn)
			throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<User> userList = new ArrayList<User>();
		try {
			pstmt = conn.prepareStatement
					("select u.*, (select count(*) from purchase p where p.userId = u.userId)"
							+ " from user u order by u.registerTime desc, u.userId");
			rs  = pstmt.executeQuery();
			while (rs.next()){
				User user = makeUser(rs);
				user.setOrderCount(rs.getInt(6));
				userList.add(user);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return userList;
	}

	// 컬럼 순서: userId, password, name, registerTime, phone
	private User makeUser(ResultSet rs) throws SQLException {
		User user = new User();
		user.setUserId(rs.getString(1));
		user.setPassword(rs.getString(2));
		user.setName(rs.getString(3));
		user.setRegisterTime(rs.getTimestamp(4));
		user.setPhone(rs.getString(5));
		return user;
	}
}
