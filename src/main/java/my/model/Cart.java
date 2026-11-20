package my.model;

import java.io.Serializable;

// 장바구니에 담은 상품 하나 - pro0928의 Cart.java(customer, movieId, amount) 형태
// 세션의 "CART" 속성(List<Cart>)에 담는다. 세션에는 productId와 amount만 믿고,
// 이름·가격·재고는 화면을 그릴 때마다 DB에서 다시 읽어 채운다.
public class Cart implements Serializable {
	private static final long serialVersionUID = 1L;

	private int productId;
	private int amount;

	// 화면 표시용 (DB에서 다시 읽어 채우는 값)
	private String name;
	private int price;
	private int stock;
	private String image;

	public Cart() {}

	public Cart(int productId, int amount) {
		super();
		this.productId = productId;
		this.amount = amount;
	}

	// DB에서 읽은 상품 정보로 화면 표시용 값을 채운다
	public void fill(Product product) {
		this.name = product.getName();
		this.price = product.getPrice();
		this.stock = product.getStock();
		this.image = product.getImage();
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

	public String getName() {
		return name;
	}

	public int getPrice() {
		return price;
	}

	public int getStock() {
		return stock;
	}

	public String getImage() {
		return image;
	}

	public int getSubtotal() {
		return price * amount;
	}

	// 담은 수량이 지금 재고보다 많은지 (화면 경고용)
	public boolean isOverStock() {
		return amount > stock;
	}

	// 수량 선택 최대값 = 재고와 10 중 작은 값
	public int getMaxAmount() {
		return Math.min(stock, Product.MAX_AMOUNT);
	}
}
