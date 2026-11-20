package my.model;

// 주문 상품 (purchaseitem 테이블) - 기존 Purchase.java의 movieId, amount 부분을 따로 뺀 것
public class PurchaseItem {
	private int itemId;
	private int purchaseId;
	private int productId;
	private int amount;
	private int price;          // 주문 당시 1개 가격

	// 화면에 같이 보여줄 값 (product 테이블과 join 해서 가져옴)
	private String name;
	private String image;

	public PurchaseItem() {}

	public PurchaseItem(int purchaseId, int productId, int amount, int price) {
		super();
		this.purchaseId = purchaseId;
		this.productId = productId;
		this.amount = amount;
		this.price = price;
	}

	public int getItemId() {
		return itemId;
	}

	public void setItemId(int itemId) {
		this.itemId = itemId;
	}

	public int getPurchaseId() {
		return purchaseId;
	}

	public void setPurchaseId(int purchaseId) {
		this.purchaseId = purchaseId;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public int getAmount() {
		return amount;
	}

	public void setAmount(int amount) {
		this.amount = amount;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}

	// 금액 = 가격 x 수량
	public int getSubtotal() {
		return price * amount;
	}
}
