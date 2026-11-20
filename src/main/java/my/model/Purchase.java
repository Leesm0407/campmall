package my.model;

import java.util.Date;
import java.util.List;

// 주문 (purchase 테이블) - 기존 Purchase.java(pid, customer, movieId, amount, total, pdate)를
// 주문 한 건 + 주문 상품 여러 개(PurchaseItem) 구조로 바꿈
public class Purchase {

	// 주문 상태 (진행 순서대로) + 취소
	public static final String[] STATUSES = {"주문 접수", "배송 준비", "배송 중", "배송 완료", "취소"};
	// 배송비 규칙: 상품 합계가 FREE_DELIVERY 이상이면 무료, 아니면 DELIVERY_FEE
	public static final int FREE_DELIVERY = 50000;
	public static final int DELIVERY_FEE = 3000;

	private int purchaseId;
	private String userId;
	private String receiver;
	private String phone;
	private String address;
	private String memo;
	private int deliveryFee;
	private int total;          // 결제 금액 = 상품 합계 + 배송비
	private String status;
	private Date purchaseDate;

	// 목록·상세 화면에 같이 보여줄 값 (DB 컬럼 아님)
	private String userName;    // 주문한 회원 이름
	private String firstName;   // 첫 번째 상품 이름 ("OO 외 n건")
	private int itemCount;      // 주문 상품 종류 수
	private List<PurchaseItem> items;

	public Purchase() {}

	public Purchase(String userId, String receiver, String phone, String address, String memo,
			int deliveryFee, int total, String status, Date purchaseDate) {
		super();
		this.userId = userId;
		this.receiver = receiver;
		this.phone = phone;
		this.address = address;
		this.memo = memo;
		this.deliveryFee = deliveryFee;
		this.total = total;
		this.status = status;
		this.purchaseDate = purchaseDate;
	}

	// 상품 합계로 배송비 계산
	public static int deliveryFeeOf(int itemTotal) {
		return itemTotal >= FREE_DELIVERY ? 0 : DELIVERY_FEE;
	}

	public static boolean isStatus(String status) {
		if (status == null) return false;
		for (String s : STATUSES) {
			if (s.equals(status)) return true;
		}
		return false;
	}

	public int getPurchaseId() {
		return purchaseId;
	}

	public void setPurchaseId(int purchaseId) {
		this.purchaseId = purchaseId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getReceiver() {
		return receiver;
	}

	public void setReceiver(String receiver) {
		this.receiver = receiver;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getMemo() {
		return memo;
	}

	public void setMemo(String memo) {
		this.memo = memo;
	}

	public int getDeliveryFee() {
		return deliveryFee;
	}

	public void setDeliveryFee(int deliveryFee) {
		this.deliveryFee = deliveryFee;
	}

	public int getTotal() {
		return total;
	}

	public void setTotal(int total) {
		this.total = total;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Date getPurchaseDate() {
		return purchaseDate;
	}

	public void setPurchaseDate(Date purchaseDate) {
		this.purchaseDate = purchaseDate;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public int getItemCount() {
		return itemCount;
	}

	public void setItemCount(int itemCount) {
		this.itemCount = itemCount;
	}

	public List<PurchaseItem> getItems() {
		return items;
	}

	public void setItems(List<PurchaseItem> items) {
		this.items = items;
	}

	// 상품 합계 = 결제 금액 - 배송비 (화면 표시용)
	public int getItemTotal() {
		return total - deliveryFee;
	}
}
