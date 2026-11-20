package my.model;

import java.util.Date;

// 상품 (product 테이블) - 기존 Movie.java 형태
public class Product {

	// 카테고리 5개 (화면의 탭·메뉴, 관리자 폼, 서버 검사에서 모두 이 목록을 쓴다)
	public static final String[] CATEGORIES = {"텐트·타프", "침낭·매트", "캠핑 가구", "버너·조리", "랜턴·조명"};
	// 재고가 이 값 이하(1개 이상)이면 '품절 임박'으로 표시
	public static final int LOW_STOCK = 3;
	// 한 상품을 한 번에 살 수 있는 최대 수량
	public static final int MAX_AMOUNT = 10;

	private int productId;
	private String name;
	private String category;
	private int price;
	private int stock;
	private String image;
	private String description;
	private Date registerTime;

	// 판매 수량 (DB 컬럼 아님, 취소 제외 주문 수량 합계 - 인기순 정렬·화면 표시용)
	private int sold;

	public Product() {}

	public Product(String name, String category, int price, int stock,
			String image, String description, Date registerTime) {
		super();
		this.name = name;
		this.category = category;
		this.price = price;
		this.stock = stock;
		this.image = image;
		this.description = description;
		this.registerTime = registerTime;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public int getStock() {
		return stock;
	}

	public void setStock(int stock) {
		this.stock = stock;
	}

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Date getRegisterTime() {
		return registerTime;
	}

	public void setRegisterTime(Date registerTime) {
		this.registerTime = registerTime;
	}

	public int getSold() {
		return sold;
	}

	public void setSold(int sold) {
		this.sold = sold;
	}

	// 화면에서 ${product.soldOut}, ${product.lowStock}, ${product.maxAmount}로 쓴다
	public boolean isSoldOut() {
		return stock <= 0;
	}

	public boolean isLowStock() {
		return stock > 0 && stock <= LOW_STOCK;
	}

	// 수량 선택 최대값 = 재고와 10 중 작은 값
	public int getMaxAmount() {
		return Math.min(stock, MAX_AMOUNT);
	}

	// 카테고리 이름이 정해진 5개 중 하나인지
	public static boolean isCategory(String category) {
		if (category == null) return false;
		for (String c : CATEGORIES) {
			if (c.equals(category)) return true;
		}
		return false;
	}
}
