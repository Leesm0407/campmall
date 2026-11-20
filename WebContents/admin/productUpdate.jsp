<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.io.*,java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 상품 수정 - CHAPTER10/update.jsp 방식 (새 사진을 안 고르면 원래 사진 유지)
	String savePath = application.getRealPath("/images/products");
	if (savePath == null) savePath = UploadUtil.PROJECT_PRODUCT_IMAGE_DIR;
	File tempDir = new File((File) application.getAttribute("javax.servlet.context.tempdir"), "upload");
	tempDir.mkdirs();

	String msg = null;
	boolean ok = false;
	try {
		MultipartRequest multi = new MultipartRequest(request, tempDir.getPath(), UploadUtil.MAX_SIZE, "utf-8", new DefaultFileRenamePolicy());
		String name = multi.getParameter("name");
		String category = multi.getParameter("category");
		String description = multi.getParameter("description");
		String upload = multi.getFilesystemName("image");
		int productId = 0;
		int price = -1;
		int stock = -1;
		try {
			productId = Integer.parseInt(multi.getParameter("productId"));
			price = Integer.parseInt(multi.getParameter("price"));
			stock = Integer.parseInt(multi.getParameter("stock"));
		} catch (NumberFormatException e) {}

		if (name == null || name.trim().isEmpty() || name.trim().length() > 100) msg = "상품 이름을 100자 이내로 입력해 주세요.";
		else if (!Product.isCategory(category)) msg = "카테고리를 골라 주세요.";
		else if (price < 100 || price > 10000000) msg = "가격은 100원 ~ 1,000만 원 사이로 입력해 주세요.";
		else if (stock < 0 || stock > 9999) msg = "재고는 0 ~ 9,999개 사이로 입력해 주세요.";
		else if (description != null && description.length() > 1000) msg = "상품 설명은 1,000자 이내로 입력해 주세요.";

		String image = null;
		if (msg != null) {
			if (upload != null) new File(tempDir, upload).delete();
		} else if (upload != null) {
			image = UploadUtil.moveImage(tempDir, upload, savePath);
			if (image == null) msg = "사진은 png, jpg, gif, webp 파일만 올릴 수 있어요.";
		}

		if (msg == null) {
			Connection conn = ConnectionProvider.getConnection();
			try {
				ProductDao dao = new ProductDao();
				Product product = dao.selectById(conn, productId);
				if (product == null) {
					msg = "찾는 상품이 없어요.";
				} else {
					product.setName(name.trim());
					product.setCategory(category);
					product.setPrice(price);
					product.setStock(stock);
					product.setDescription(description);
					if (image != null) {   // 새 사진을 올렸을 때만 바꾼다
						product.setImage(image);
					}
					dao.update(conn, product);
					ok = true;
					msg = "상품 정보를 수정했어요.";
				}
			} catch (SQLException e) {
				e.printStackTrace();
				msg = "수정하지 못했어요. 입력값을 확인해 주세요.";
			} finally {
				JdbcUtil.close(conn);
			}
		}
	} catch (IOException e) {
		msg = "사진은 5MB 이하만 올릴 수 있어요.";
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>상품 수정 | 노지마켓</title>
</head>
<body>
<script>
	alert("<%= msg %>");
<% if (ok) { %>
	location.href = "productList.jsp";
<% } else { %>
	history.go(-1);
<% } %>
</script>
</body>
</html>
