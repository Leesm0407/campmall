모닥(MODAK) 디자인 파일 - Dreamweaver CS6용
=====================================================

[처음 열 파일]  index.html  (메인 화면)

[Dreamweaver에서 여는 방법]
1. Dreamweaver CS6 > 사이트 > 새 사이트
2. 로컬 사이트 폴더:  C:\Users\14ZB95N\eclipse-workspace\campmall\WebContents\design\
3. 오른쪽 파일 패널에서 index.html 더블클릭
4. 위쪽 [디자인] 또는 [분할] 보기로 수정, 저장(Ctrl+S)
   - 브라우저로 미리 보기: F12
   - 페이지 안의 링크는 모두 .html 끼리 연결되어 있어서 클릭하며 둘러볼 수 있습니다.

[화면 파일]
  index.html                 메인 (배너, 카테고리, 인기 상품, 주문 방법)
  productList.html           전체 상품 목록
  productList_tent.html      카테고리별 목록 예시 (텐트·타프)
  productDetail.html         상품 상세 / 구매
  cart.html                  장바구니
  orderForm.html             주문서 작성
  myOrder.html               주문 내역
  orderDetail.html           주문 상세
  loginForm.html             로그인
  registerForm.html          회원가입
  admin_index.html           관리자 홈
  admin_productList.html     관리자 - 상품 관리
  admin_productForm.html     관리자 - 상품 등록·수정
  admin_orderList.html       관리자 - 주문 관리
  admin_orderDetail.html     관리자 - 주문 상세
  admin_userList.html        관리자 - 회원 관리

[그림]  모든 그림은 <img> 태그 → 디자인 보기에서 클릭 -> 속성 패널(Ctrl+F3)의 Src·W·H로 교체
  images\logo-mark.png        로고 (헤더용 88x88)
  images\modak-logo.png       로고 큰 그림 (512x512, 투명 배경)
  images\hero.jpg             메인 배너 (1920x768, 원본을 2.5:1로 잘라 왼쪽만 어둡게 한 것)
  images\banner-original.jpg  메인 배너 원본 사진 (1198x671, 자르기 전)
  images\products\*.png       상품 사진 (800x500, 가로:세로 16:10)
  images\icons\*.png          카테고리·안내 아이콘
  images\admin-nav-bg.png     관리자 왼쪽 메뉴 배경색 (세로 반복)

[스타일]  css\design.css
  - 원래 사이트(css\style.css)와 같은 디자인을 Dreamweaver CS6에서도 보이도록
    float 방식으로 다시 작성한 파일입니다. 색상표는 파일 맨 위 주석 참고.

[주의]
  - 이 폴더는 "디자인 확인·수정용"입니다. 상품·주문 내용은 예시 데이터이고,
    로그인·장바구니·주문 같은 기능은 동작하지 않습니다.
  - 실제로 동작하는 사이트는 상위 폴더(WebContents)의 .jsp 파일입니다.
    여기서 바꾼 디자인을 실제 사이트에도 적용하려면 같은 이름의 .jsp 파일
    (관리자 화면은 admin\ 폴더)에서 같은 부분을 고쳐 주세요.
