# 모닥 (MODAK) · 캠핑용품 쇼핑몰

웹프로그래밍응용 텀프로젝트 (팀장 오민석 · 팀원 이성민)

5개 카테고리(텐트·타프 / 침낭·매트 / 캠핑 가구 / 버너·조리 / 랜턴·조명)의 캠핑용품을
장바구니에 담아 주문하는 JSP 쇼핑몰입니다.

- 재고 관리: 품절·품절 임박 표시, 주문할 때 재고 차감(동시 주문에도 음수 안 됨), 취소하면 재고 복구
- 금액은 항상 서버에서 DB 가격으로 다시 계산
- 새로고침해도 중복 주문 안 됨
- 관리자: 상품 등록·수정·삭제(사진 업로드), 주문 상태 변경, 회원 목록

> 상품명·브랜드·사진은 모두 가상의 예시입니다.

## 개발 환경

| 항목 | 버전 |
| --- | --- |
| Eclipse | Enterprise Java and Web (Dynamic Web Project) |
| Java | 21 |
| Tomcat | 9.0 (`javax.servlet`) |
| MySQL | 8.0 |

## 처음 받아서 실행하기

1. **코드 받기**
   ```
   cd C:\Users\<내 사용자 이름>\eclipse-workspace
   git clone <이 저장소 주소> campmall
   ```
2. **DB 만들기**: HeidiSQL에서 `db/schema.sql` 실행(F9) → 이어서 `db/seed.sql` 실행
   - `campmall` DB가 새로 만들어집니다. (schema.sql 은 campmall DB만 지우고 다시 만듦)
3. **DB 접속 설정**: `src/main/java/pool.jocl.example` 을 같은 폴더에 `pool.jocl` 로 복사하고,
   `내_MySQL_비밀번호` 를 자기 MySQL root 비밀번호로 바꾸기
   - `pool.jocl` 은 GitHub에 올라가지 않습니다(각자 PC마다 따로).
4. **Eclipse로 가져오기**: File → Import → General → Existing Projects into Workspace →
   `campmall` 폴더 선택 → Finish
5. **실행**: `campmall` 프로젝트 우클릭 → Run As → Run on Server → Tomcat v9.0 → Finish
   - 주소: <http://localhost:8080/campmall/>

### 테스트 계정 (seed.sql)

| 구분 | 아이디 | 비밀번호 |
| --- | --- | --- |
| 관리자 | `admin` | `admin123!` |
| 회원 | `user1` | `user123!` |

## 폴더 구성

```
campmall/
├─ src/main/java/my/      자바 코드 (model, dao, util)
├─ WebContents/           JSP 화면, css, images
│  ├─ admin/              관리자 화면
│  ├─ common/             헤더·푸터 등 공통 조각
│  └─ design/             Dreamweaver CS6용 HTML 디자인 파일 (README_드림위버.txt 참고)
└─ db/                    schema.sql (테이블), seed.sql (예시 데이터)
```

## 같이 수정하는 방법

작업 전에 항상 최신 코드를 먼저 받고, 끝나면 올립니다.

```
git pull                      # 1. 작업 시작 전: 친구가 올린 최신 코드 받기
# ... Eclipse에서 수정 ...
git add .
git commit -m "무엇을 바꿨는지 한 줄 설명"
git push                      # 2. 작업 끝: 내 수정 올리기
```

- 같은 파일의 같은 부분을 동시에 고치면 충돌(conflict)이 나니, 누가 어떤 화면을 맡을지 미리 나누세요.
- `git push` 가 거절되면 `git pull` 로 친구 수정을 먼저 받은 뒤 다시 `git push` 하세요.
- 명령어 대신 **GitHub Desktop** 프로그램이나 Eclipse의 **Team** 메뉴(EGit)로도 같은 작업을 할 수 있습니다.
