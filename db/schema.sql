-- =========================================================
-- 노지마켓(NOJI MARKET) 캠핑용품 쇼핑몰 데이터베이스 만들기
-- HeidiSQL에서 이 파일을 열고 전체 실행(F9) → 이어서 seed.sql 실행
-- 주의: 다시 실행하면 campmall DB를 지우고 새로 만든다. (다른 DB는 건드리지 않음)
-- =========================================================

SET NAMES utf8mb4;   -- 한글이 깨지지 않게 문자셋 지정
DROP DATABASE IF EXISTS campmall;
CREATE DATABASE campmall DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE campmall;

-- 회원 : 기존 web DB의 user 테이블(userId, password, name, registerTime) + 전화번호
--        관리자는 아이디가 admin인 회원
CREATE TABLE user (
	userId       VARCHAR(20) PRIMARY KEY,
	password     VARCHAR(64) NOT NULL,          -- SHA-256 해시(64자리 16진수)
	name         VARCHAR(30) NOT NULL,
	registerTime DATETIME,
	phone        VARCHAR(20)
);

-- 상품 : 기존 movie 테이블(movieId, title, maker, price, openDate, poster, freq) 형태
CREATE TABLE product (
	productId    INT AUTO_INCREMENT PRIMARY KEY,
	name         VARCHAR(100) NOT NULL,         -- 상품 이름 (브랜드는 모두 가상)
	category     VARCHAR(20)  NOT NULL,         -- 텐트·타프 / 침낭·매트 / 캠핑 가구 / 버너·조리 / 랜턴·조명
	price        INT          NOT NULL,         -- 판매 가격(원)
	stock        INT          NOT NULL DEFAULT 0,  -- 재고 (0이면 품절)
	image        VARCHAR(100),                  -- WebContents/images/products 폴더 안의 파일 이름
	description  VARCHAR(1000),
	registerTime DATETIME
);

-- 주문 : 기존 purchase 테이블(pid, customer, movieId, amount, total, pdate)을
--        주문(purchase) + 주문 상품(purchaseitem) 두 개로 나눔
CREATE TABLE purchase (
	purchaseId   INT AUTO_INCREMENT PRIMARY KEY,
	userId       VARCHAR(20)  NOT NULL,
	receiver     VARCHAR(30)  NOT NULL,         -- 받는 사람
	phone        VARCHAR(20)  NOT NULL,
	address      VARCHAR(200) NOT NULL,
	memo         VARCHAR(200),                  -- 배송 요청사항
	deliveryFee  INT          NOT NULL,         -- 배송비 (상품 합계 50,000원 이상 0원, 미만 3,000원)
	total        INT          NOT NULL,         -- 결제 금액 = 상품 합계 + 배송비
	status       VARCHAR(10)  NOT NULL DEFAULT '주문 접수',  -- 주문 접수 / 배송 준비 / 배송 중 / 배송 완료 / 취소
	purchaseDate DATETIME,                      -- 주문한 시각
	FOREIGN KEY (userId) REFERENCES user(userId)
);

CREATE TABLE purchaseitem (
	itemId       INT AUTO_INCREMENT PRIMARY KEY,
	purchaseId   INT NOT NULL,
	productId    INT NOT NULL,
	amount       INT NOT NULL,                  -- 수량
	price        INT NOT NULL,                  -- 주문 당시 1개 가격 (나중에 상품 가격이 바뀌어도 그대로)
	FOREIGN KEY (purchaseId) REFERENCES purchase(purchaseId),
	FOREIGN KEY (productId) REFERENCES product(productId)
);
