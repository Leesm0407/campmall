<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="adminCheck.jsp" %>
<%
	// 상품 등록·수정 폼 - CHAPTER10/movieuploadform.jsp, updateForm.jsp 방식
	// ?productId= 가 있으면 수정, 없으면 등록
	request.setCharacterEncoding("utf-8");
	Product product = null;
	String idParam = request.getParameter("productId");
	if (idParam != null) {
		Connection conn = ConnectionProvider.getConnection();
		try {
			ProductDao dao = new ProductDao();
			product = dao.selectById(conn, Integer.parseInt(idParam));
		} catch (SQLException | NumberFormatException e) {
			e.printStackTrace();
		} finally {
			JdbcUtil.close(conn);
		}
	}
	boolean edit = (product != null);
%>
<c:set var="p" value="<%=product%>"/>
<c:set var="edit" value="<%=edit%>"/>
<c:set var="categories" value="<%=Product.CATEGORIES%>"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${edit ? '상품 수정' : '상품 등록'} | 모닥</title>
<link rel="icon" type="image/png" href="../images/logo-mark.png">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap">
<link rel="stylesheet" href="../css/style.css?v=20261123">
</head>
<body class="admin-body">
<%@ include file="sidebar.jsp" %>

<main class="admin-main">
	<div class="admin-top">
		<div>
			<h1>${edit ? '상품 수정' : '상품 등록'}</h1>
			<p>${edit ? '바꾼 내용은 바로 사용자 화면에 반영돼요.' : '등록한 상품은 바로 사용자 화면의 상품 목록에 보여요.'}</p>
		</div>
		<div class="admin-user">
			<span><b><c:out value="${sessionScope.NAME}"/></b>님</span>
			<a href="../logout.jsp" class="btn btn-gray">로그아웃</a>
		</div>
	</div>

	<form class="form-card" name="productForm" action="${edit ? 'productUpdate.jsp' : 'productUpload.jsp'}" method="post"
	      enctype="multipart/form-data" onsubmit="return checkProduct(this)">
		<c:if test="${edit}"><input type="hidden" name="productId" value="${p.productId}"></c:if>
		<div class="field full">
			<label for="p-name">상품 이름</label>
			<input id="p-name" class="input" type="text" name="name" maxlength="100" placeholder="솔바람 패밀리 돔 텐트 4~5인" value="<c:out value="${p.name}"/>">
		</div>
		<div class="field">
			<label for="p-cat">카테고리</label>
			<select id="p-cat" class="select" name="category">
				<c:forEach var="cat" items="${categories}">
				<option ${p.category == cat ? 'selected' : ''}>${cat}</option>
				</c:forEach>
			</select>
		</div>
		<div class="field">
			<label for="p-price">가격 (원)</label>
			<input id="p-price" class="input" type="number" name="price" min="100" max="10000000" step="100" placeholder="59000" value="${edit ? p.price : ''}">
		</div>
		<div class="field">
			<label for="p-stock">재고 (개)</label>
			<input id="p-stock" class="input" type="number" name="stock" min="0" max="9999" placeholder="10" value="${edit ? p.stock : ''}">
			<span class="help">0으로 하면 품절, 1~3개는 품절 임박으로 표시돼요.</span>
		</div>
		<div class="field">
			<label for="p-image">상품 사진</label>
			<input id="p-image" class="input" type="file" name="image" accept=".png,.jpg,.jpeg,.gif,.webp" style="padding-top: 11px;">
			<span class="help">png·jpg·gif·webp, 5MB 이하. 가로가 긴 사진(16:10)을 권장해요.</span>
			<c:if test="${edit && not empty p.image}">
			<span class="current-photo"><img src="../images/products/${p.image}" alt="">지금 사진: <c:out value="${p.image}"/><br>새 사진을 고르지 않으면 지금 사진을 그대로 써요.</span>
			</c:if>
		</div>
		<div class="field full">
			<label for="p-desc">상품 설명</label>
			<textarea id="p-desc" class="textarea" name="description" rows="5" maxlength="1000"><c:out value="${p.description}"/></textarea>
		</div>
		<div class="full button-row">
			<a href="productList.jsp" class="btn btn-gray">취소</a>
			<button type="submit" class="btn btn-forest">${edit ? '수정 저장' : '상품 등록'}</button>
		</div>
	</form>
</main>
<script type="text/javascript">
function checkProduct(frm) {
	if (frm.name.value.trim() == "") {
		alert("상품 이름을 입력해 주세요.");
		frm.name.focus();
		return false;
	}
	var price = parseInt(frm.price.value, 10);
	if (!(price >= 100 && price <= 10000000)) {
		alert("가격은 100원 ~ 1,000만 원 사이로 입력해 주세요.");
		frm.price.focus();
		return false;
	}
	var stock = parseInt(frm.stock.value, 10);
	if (!(stock >= 0 && stock <= 9999)) {
		alert("재고는 0 ~ 9,999개 사이로 입력해 주세요.");
		frm.stock.focus();
		return false;
	}
	var file = frm.image.files && frm.image.files[0];
	if (file) {
		if (!/\.(png|jpe?g|gif|webp)$/i.test(file.name)) {
			alert("사진은 png, jpg, gif, webp 파일만 올릴 수 있어요.");
			return false;
		}
		if (file.size > 5 * 1024 * 1024) {
			alert("사진은 5MB 이하만 올릴 수 있어요.");
			return false;
		}
	}
	return true;
}
</script>
</body>
</html>
