-- 오라클 9일차 고급쿼리

-- ===============================고급쿼리=====================================
-- 1. TOP-N 분석
-- 2. WITH 구문
-- 3. 계층형 쿼리(Hierarchical Query)
-- 4. 윈도우 함수

-- 1. TOP-N 분석
-- 특정 컬럼에서 가장 큰 N개의 값 또는 가장 작은 N개의 값을 구해야 할 경우 사용
-- 예시) 가장 적게 팔린 제품 10가지는? 회사에서 가장 소득이 높은 사람 3명은?
SELECT MAX(SALARY), MIN(SALARY) FROM EMPLOYEE; -- 얘네는 최댓값, 최솟값 구하는것
SELECT SALARY FROM EMPLOYEE WHERE SALARY IS NOT NULL ORDER BY 1 DESC;
SELECT ROWNUM, SALARY FROM EMPLOYEE WHERE ROWNUM < 11; -- 행으로 넘버링 할 수 있어서 WHERE ROWNUM을 통해 범위를 지정해서 뽑는것이 가능

SELECT ROWNUM, SALARY FROM EMPLOYEE WHERE SALARY IS NOT NULL ORDER BY 2 DESC;
-- 순서가 먼저 매겨진 후에 ORDER BY가 되서 순서가 뒤죽박죽이 되었다.
-- 해결방법 : 정렬(ORDER BY) 후 순서(ROWNUM)를 매기도록 하자!
SELECT ROWNUM, E.* FROM
(SELECT SALARY FROM EMPLOYEE WHERE SALARY IS NOT NULL ORDER BY 1 DESC) E -- ORDER BY 한것 자체를 하나의 테이블로 본다.
WHERE ROWNUM < 11;
-- FROM 뒤에 적은 서브쿼리 : 인라인 뷰(익명의 뷰)

-- 1.1 ROWNUM, ROWID
-- 테이블을 생성하면 자동으로 만들어짐
-- ROWID : 테이블의 특정 레코드를 랜덤하게 접근하기 위한 논리적인 주소값
-- ROWNUM : 각 행에 대한 일련번호, 오라클에서 내부적으로 부여하는 컬럼

-- @실습문제1
-- D5부서에서 연봉 TOP3의 전체정보를 출력하세요
SELECT ROWNUM, E.* FROM -- 여기서 ROWNUM 자동생성되기 때문에 생략가능, 즉 SELECT E.* FROM 도 문제없음.
(SELECT * FROM EMPLOYEE WHERE DEPT_CODE = 'D5' ORDER BY SALARY DESC) E
WHERE ROWNUM < 4;

-- @실습문제2
-- 부서별 급여평균 TOP3 부서의 부서코드와 부서명, 평균급여를 출력하세요
SELECT * FROM
(SELECT DEPT_CODE, DEPT_TITLE, FLOOR(AVG(SALARY)) "AVG SAL"
FROM EMPLOYEE 
JOIN DEPARTMENT ON DEPT_ID = DEPT_CODE
GROUP BY DEPT_CODE, DEPT_TITLE
ORDER BY 3 DESC)
WHERE ROWNUM < 4;

-- 4위에서 6위 구하기
SELECT * FROM
(SELECT ROWNUM RNUM, E.* FROM
(SELECT DEPT_CODE, DEPT_TITLE, FLOOR(AVG(SALARY)) "AVG SAL"
FROM EMPLOYEE 
JOIN DEPARTMENT ON DEPT_ID = DEPT_CODE
GROUP BY DEPT_CODE, DEPT_TITLE
ORDER BY 3 DESC) E)
-- WHERE RNUM >= 4 AND RNUM <= 6;
WHERE RNUM BETWEEN 4 AND 6;

-- 2. WITH
-- 서브쿼리에 이름을 붙여주고 인라인뷰로 사용시 서브쿼리의 이름을 FROM절에 기술할 
-- 수 있음. 같은 서브쿼리가 여러번 사용될 경우 중복 작성을 피할 수 있고 실행속도도
-- 빨라지는 장점이 있음.
-- 사용방법
-- WITH 서브쿼리명 AS (서브쿼리)
-- SELECT * FROM (서브쿼리명)

-- 예제) 급여 TOP 5인 직원의 전체정보를 출력하시오
WITH TOP5_SAL AS
(SELECT * 
FROM EMPLOYEE 
WHERE SALARY IS NOT NULL 
ORDER BY SALARY DESC)
SELECT * FROM TOP5_SAL
WHERE ROWNUM < 6;

-- @실습문제1
-- D5부서에서 연봉 TOP3의 전체정보를 출력하세요
WITH TOP3_SAL AS
(SELECT *
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'
ORDER BY SALARY DESC)
SELECT * FROM TOP3_SAL
WHERE ROWNUM < 4;

-- @실습문제2
-- 부서별 급여평균 TOP3 부서의 부서코드와 부서명, 평균급여를 출력하세요
WITH TOP3_AVGSAL AS
(SELECT DEPT_CODE, DEPT_TITLE, FLOOR(AVG(SALARY)) "AVG SAL"
FROM EMPLOYEE 
JOIN DEPARTMENT ON DEPT_ID = DEPT_CODE
GROUP BY DEPT_CODE, DEPT_TITLE
ORDER BY 3 DESC)
SELECT * FROM TOP3_AVGSAL
WHERE ROWNUM < 4;

-- 3. 계층형 쿼리
-- JOIN을 통해 수평적으로 기준컬럼을 연결시킨 것과는 달리 기준컬럼을 가지고
-- 수직적인 관계를 만듬
-- 예시) 조직도, 메뉴, 단답형 게시판 등 프랙탈 구조의 표현에 적합함
-- 오라클에서 사용되는 구문
-- 1. START WITH : 부모행(루트)를 지정
-- 2. CONNECT BY : 부모-자식관계를 지정
-- 3. PRIOR : START WITH절에서 제시한 부모행의 기준컬럼을 지정함.
-- 4. LEVEL : 의사컬럼(PSEUDO COLUMN), 계층정보를 나타내는 가상컬럼이며
-- SELECT, WHERE, ORDER BY에서 사용가능

-- 예제) 1명이라도 직원을 관리하는 매니저의 정보(사번, 이름, 매니저 아이디)를 출력하세요

SELECT EMP_ID, EMP_NAME, MANAGER_ID 
FROM EMPLOYEE E
WHERE EXISTS (
SELECT 1
FROM EMPLOYEE
WHERE MANAGER_ID = E.EMP_ID); --  상호연관 서브쿼리

SELECT EMP_ID, EMP_NAME, MANAGER_ID 
FROM EMPLOYEE E
START WITH EMP_ID = 200
CONNECT BY PRIOR EMP_ID = MANAGER_ID;

-- @실습예제1
-- MENU_TBL 테이블을 생성하는데 숫자인 NO 컬럼이 PRIMARY KEY로 있고, 문자로 크기가 100인
-- MENU_NAME 컬럼이 있고, 숫자로 된 PARENT_NO 이라고 하는 컬럼이 있음. 생성해주세요
CREATE TABLE MENU_TBL
( 
    NO NUMBER PRIMARY KEY,
    MENU_NAME VARCHAR2(100),
    PARENT_NO NUMBER
);
DESC MENU_TBL;
INSERT INTO MENU_TBL
VALUES(100, '주메뉴1', NULL);
DROP TABLE MENU_TBL;
INSERT INTO MENU_TBL
VALUES(1000, '서브메뉴A', 100);
INSERT INTO MENU_TBL
VALUES(1001, '상세메뉴A1', 1000);
INSERT INTO MENU_TBL
VALUES(1002, '상세메뉴A2', 1000);
INSERT INTO MENU_TBL
VALUES(1003, '상세메뉴A3', 1000);

INSERT INTO MENU_TBL
VALUES(200, '주메뉴2', NULL);
INSERT INTO MENU_TBL
VALUES(2000, '서브메뉴B', 200);

INSERT INTO MENU_TBL
VALUES(300, '주메뉴3', NULL);
INSERT INTO MENU_TBL
VALUES(3000, '서브메뉴C', 300);
INSERT INTO MENU_TBL
VALUES(3001, '상세메뉴C1', 3000);

SELECT * FROM MENU_TBL
START WITH PARENT_NO IS NULL
CONNECT BY PRIOR NO = PARENT_NO;

-- 4. 윈도우 함수
-- 4.1 RANK() OVER
-- 4.1.1 사용법 : RANK() OVER (ORDER BY 컬럼명 ASC || DESC)
-- 특정 컬럼 기준으로 랭킹을 부여함, 중복 순위 다음은 해당 갯수만큼 건너뛰고 반환함.
-- 예제) 회사의 연봉 순위를 출력하시오
SELECT ROWNUM "RANK", E.* FROM
(SELECT * 
FROM EMPLOYEE 
WHERE SALARY IS NOT NULL 
ORDER BY SALARY DESC) E;

-- WITH 로 서브쿼리 이름 지어주기
WITH RANK_SAL AS
(SELECT * 
FROM EMPLOYEE 
WHERE SALARY IS NOT NULL 
ORDER BY SALARY DESC)
SELECT ROWNUM "RANK", E.*FROM RANK_SAL E;

-- 순위함수 사용해보기
SELECT 
    RANK() OVER (ORDER BY SALARY DESC) "RANK"
    , EMP_NAME
    , SALARY 
FROM EMPLOYEE WHERE SALARY IS NOT NULL;

-- @실습문제1
-- 입사일이 빠른 순으로 순위를 정하여 출력하시오.
-- 이름, 입사일, 순위
SELECT 
      EMP_NAME "이름"
    , HIRE_DATE "입사일"
    , RANK() OVER (ORDER BY HIRE_DATE ASC) "순위"
FROM EMPLOYEE WHERE HIRE_DATE IS NOT NULL;

-- 4.2 DENSE_RANK() OVER
-- -> 중복 순위 상관없이 순차적으로 반환, 빠짐이 없이 빽빽한 순위를 부여함
SELECT EMP_NAME, SALARY, DENSE_RANK() OVER (ORDER BY SALARY DESC)
FROM EMPLOYEE;

-- @실습문제2
-- 기본급여의 등수가 1등부터 10등까지인 직원의 이름, 급여, 순위를 출력하세요
SELECT * FROM
(SELECT 
    EMP_NAME "이름"
    , SALARY "급여"
    , RANK() OVER (ORDER BY SALARY DESC) "순위"
FROM EMPLOYEE)
--WHERE ROWNUM < 11;
WHERE 순위 BETWEEN 1 AND 10;   -- 1번방법

SELECT 
    EMP_NAME "이름"
    , SALARY "급여"
    , RANK() OVER (ORDER BY SALARY DESC) "순위"
FROM EMPLOYEE
WHERE ROWNUM < 11;          -- 2번방법

WITH RANK_SAL AS
(SELECT 
    EMP_NAME "이름"
    , SALARY "급여"
    , RANK() OVER (ORDER BY SALARY DESC) "순위"
FROM EMPLOYEE)
SELECT * FROM RANK_SAL
WHERE 순위 BETWEEN 1 AND 10;    -- 3번방법








