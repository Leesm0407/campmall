<%@ page pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- 상품 카드 하나 : <c:forEach var="p" items="${list}"> 안에서 include 한다 (index.jsp, productList.jsp) --%>
<div class="product-card ${p.soldOut ? 'sold-out' : ''}">
	<a href="productDetail.jsp?productId=${p.productId}" class="product-photo ${empty p.image ? 'empty' : ''}">
		<c:if test="${not empty p.image}">
		<img src="images/products/${p.image}" alt="<c:out value="${p.name}"/>" onerror="this.parentNode.classList.add('empty')">
		</c:if>
		<span class="no-photo"><img src="images/icons/no-photo.svg" width="56" height="56" alt=""><span>사진 준비 중</span></span>
		<span class="photo-badges">
			<c:if test="${p.soldOut}"><span class="badge-stock out">품절</span></c:if>
			<c:if test="${p.lowStock}"><span class="badge-stock low">품절 임박</span></c:if>
		</span>
	</a>
	<div class="product-body">
		<span class="badge-cat">${p.category}</span>
		<h3><a href="productDetail.jsp?productId=${p.productId}"><c:out value="${p.name}"/></a></h3>
		<p class="product-meta">누적 판매 ${p.sold}개<c:if test="${p.lowStock}"> · ${p.stock}개 남음</c:if></p>
		<div class="product-bottom">
			<span class="price"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</span>
			<c:choose>
				<c:when test="${p.soldOut}">
					<button type="button" class="btn btn-disabled" disabled>품절</button>
				</c:when>
				<c:otherwise>
					<form action="cartAdd.jsp" method="post">
						<input type="hidden" name="productId" value="${p.productId}">
						<input type="hidden" name="amount" value="1">
						<button type="submit" class="btn btn-outline" aria-label="<c:out value="${p.name}"/> 장바구니에 담기">담기</button>
					</form>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>
