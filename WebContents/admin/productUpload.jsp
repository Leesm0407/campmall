<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.io.*,java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 상품 등록 - CHAPTER10/movieupload.jsp 방식 (cos 라이브러리 MultipartRequest로 사진 업로드)
	// 사진은 먼저 임시 폴더에 받고, 사진 파일이 맞을 때만 images/products 폴더로 옮긴다
	String savePath = application.getRealPath("/images/products");   // 지금 실행 중인 서버의 상품 사진 폴더
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
		String upload = multi.getFilesystemName("image");   // 임시 폴더에 저장된 파일 이름 (사진을 안 골랐으면 null)
		int price = -1;
		int stock = -1;
		try {
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
			if (upload != null) new File(tempDir, upload).delete();   // 올라온 파일은 지운다
		} else if (upload != null) {
			image = UploadUtil.moveImage(tempDir, upload, savePath);   // 사진이 아니면 null (임시 파일은 지워짐)
			if (image == null) msg = "사진은 png, jpg, gif, webp 파일만 올릴 수 있어요.";
		}

		if (msg == null) {
			Product product = new Product(name.trim(), category, price, stock, image, description, new java.util.Date());
			Connection conn = ConnectionProvider.getConnection();
			try {
				ProductDao dao = new ProductDao();
				dao.insert(conn, product);
				ok = true;
				msg = "상품을 등록했어요.";
			} catch (SQLException e) {
				e.printStackTrace();
				msg = "등록하지 못했어요. 입력값을 확인해 주세요.";
			} finally {
				JdbcUtil.close(conn);
			}
		}
	} catch (IOException e) {   // 파일이 5MB보다 크면 여기로 온다
		msg = "사진은 5MB 이하만 올릴 수 있어요.";
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>상품 등록 | 노지마켓</title>
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
