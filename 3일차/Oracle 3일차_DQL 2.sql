DESC EMPLOYEE;

-- 데이터를 조회한 결과를 Result Set 이라고 함
-- Result Set : SELECT 구문에 의해 반환된 행들의 집합
-- Result Set은 0개 이상의 행이 포함될 수 있음
-- Result Set은 특정한 기준에 의해 정렬될 수 있음
-- 특정 컬럼이나 특정 행을 조회할 수 있음
SELECT EMP_ID, EMP_NAME, EMP_NO FROM EMPLOYEE; -- 특정 컬럼만 조회하기
SELECT * FROM EMPLOYEE  -- 전체컬럼 조회하기 * 를 사용
--WHERE EMP_ID = '2000';      -- 특정행만 조회하기
                                   --  SELECT * FROM 테이블명 뒤에 WHERE 조건절을 쓴다.
--ORDER BY EMP_ID DESC;    -- 내림차순 정렬
ORDER BY EMP_ID ASC;       -- 오름차순 정렬(DEFAULT) 기본셋팅임

DESC EMPLOYEE;
-- 1.EMPLOYEE 테이블에서 이름,연봉, 총수령액(보너스포함),
--       실수령액(총 수령액-(월급*세금 3%))가 출력되도록 하시오.
SELECT * FROM EMPLOYEE;
SELECT EMP_NAME "이름", SALARY*12 AS 연봉
, SALARY*12+SALARY*NVL(BONUS,0) "총수령액"
, (SALARY*12+SALARY*NVL(BONUS,0)) - (SALARY*0.03) AS "실수령액"
FROM EMPLOYEE;
-- SALARY*12 : 월급*12개월 = 연봉, SALARY*BONUS : 보너스, SALARY*0.03 : 월급*세금3%
-- NVL : NULL 일때 0으로 처리하게 해주는 함수

-- 2. EMPLOYEE 테이블에서 이름, 근무 일수를 출력해보시오.
--    (SYSDATE를 사용하면 현재 시간 출력)
SELECT EMP_NAME AS "이름", HIRE_DATE "입사일", SYSDATE AS "오늘"
, ROUND(SYSDATE - HIRE_DATE) "근무일수" -- ROUND : 소수점 제거
FROM EMPLOYEE;
-- 3. EMPLOYEE 테이블에서 20년 이상 근속자의 이름,월급,보너스율 출력하시오
SELECT EMP_NAME "이름", SALARY " 월급", NVL(BONUS,0) AS "보너스율"
FROM EMPLOYEE WHERE ROUND(SYSDATE - HIRE_DATE) >= 7300; -- WHERE 조건절 뒤에도 계산식 사용가능
-- 20 * 365 = 7300

-- 1.EMPLOYEE 테이블에서 이름 끝이 연으로 끝나는 사원의 이름을 출력하시오
SELECT EMP_NAME FROM EMPLOYEE 
-- WHERE EMP_NAME 이 연으로 끝나는 것들만 조회
WHERE EMP_NAME LIKE '%연';
-- 2.EMPLOYEE 테이블에서 전화번호 처음 3자리가 010이 아닌 사원의 이름, 전화번호를 출력하시오
SELECT EMP_NAME, PHONE FROM EMPLOYEE 
-- WHERE PHONE 이 010으로 시작하지 않는 것들만 조회
WHERE PHONE NOT LIKE '010%';
-- 3.EMPLOYEE 테이블에서 메일주소의 's'가 들어가면서, DEPT_CODE가 D9 또는 D6이고 
-- 고용일이 90/01/01 ~ 00/12/01이면서, 월급이 270만원이상인 사원의 전체 정보를 출력하시오
SELECT * FROM EMPLOYEE 
WHERE EMAIL LIKE '%s%'
--AND (DEPT_CODE = 'D9' OR DEPT_CODE = 'D6')
AND (DEPT_CODE IN ('D9' , 'D6'))  -- 48줄과 동일
--AND (HIRE_DATE >= '90/01/01' AND HIRE_DATE <= '01/12/01')
AND HIRE_DATE BETWEEN '90/01/01' AND '01/12/01'  -- 50줄과 동일
AND SALARY >= 2700000;

-- 최종 실습 문제
-- 문제1. 
-- 입사일이 5년 이상, 10년 이하인 직원의 이름,주민번호,급여,입사일을 검색하여라
SELECT EMP_NAME "이름", EMP_NO "주민등록번호", SALARY "급여", HIRE_DATE AS 입사일
FROM EMPLOYEE
WHERE ROUND(SYSDATE - HIRE_DATE) >= 1825 AND ROUND(SYSDATE - HIRE_DATE) <= 3650;

-- 문제2.
-- 재직중이 아닌 직원의 이름,부서코드, 고용일, 근무기간, 퇴직일을 검색하여라 
--(퇴사 여부 : ENT_YN)
SELECT EMP_NAME "이름", DEPT_CODE "부서코드", HIRE_DATE "고용일", ROUND(ENT_DATE - HIRE_DATE) "근무기간",  ENT_DATE "퇴직일"
FROM EMPLOYEE
WHERE ENT_YN = 'Y';

-- 문제3.
-- 근속년수가 10년 이상인 직원들을 검색하여
-- 출력 결과는 이름,급여,근속년수(소수점X)를 근속년수가 오름차순으로 정렬하여 출력하라
-- 단, 급여는 50% 인상된 급여로 출력되도록 하여라.
SELECT EMP_NAME "이름", SALARY*1.5 "급여", CEIL((SYSDATE - HIRE_DATE)/365) "근속년수" -- CEIL : 올림. ROUND : 반올림 FLOOR : 버림
FROM EMPLOYEE
WHERE CEIL((SYSDATE - HIRE_DATE)/365) >= 10
-- ORDER BY CEIL((SYSDATE - HIRE_DATE)/365) ASC;  -- 1. 위에 "근속년수"안㎱만?이렇게 써야하고
-- ORDER BY 근속년수 ASC;                                -- 2. "근속년수" 이름을 붙였기때문에 이렇게 써도되고
ORDER BY 3 ASC;                                            -- 3. 세번째 컬럼을 기준으로 정렬하겠다는 뜻으로 이렇게 써도 된다.
-- 문제4.
-- 입사일이 99/01/01 ~ 10/01/01 인 사람 중에서 급여가 2000000 원 이하인 사람의
-- 이름,주민번호,이메일,폰번호,급여를 검색 하시오
SELECT EMP_NAME "이름", EMP_NO "주민번호", EMAIL "이메일", PHONE "전화번호", SALARY "급여"
FROM EMPLOYEE
WHERE HIRE_DATE BETWEEN '99/01/01' AND '10/01/01'
AND SALARY <= 2000000;
-- 문제5.
-- 급여가 2000000원 ~ 3000000원 인 여직원 중에서 4월 생일자를 검색하여 
-- 이름,주민번호,급여,부서코드를 주민번호 순으로(내림차순) 출력하여라
-- 단, 부서코드가 null인 사람은 부서코드가 '없음' 으로 출력 하여라.
SELECT EMP_NAME "이름", NVL(DEPT_CODE, '없음') "부서코드", EMP_NO "주민번호" -- NVL : null을 다른방식으로 표기하는 코드
FROM EMPLOYEE
WHERE SALARY BETWEEN 2000000 AND 3000000 -- 급여가 2백만 ~ 300만(BETWEEN은 포함임) 이고
AND EMP_NO LIKE '__04__-2%'  -- 여자 중에 04월 생일인 사람
ORDER BY EMP_NO DESC;
-- 문제6.
-- 남자 사원 중 보너스가 없는 사원의 오늘까지 근무일을 측정하여 
-- 1000일 마다(소수점 제외) 
-- 급여의 10% 보너스를 계산하여 이름,특별 보너스 (계산 금액) 결과를 출력하여라.
-- 단, 이름 순으로 오름 차순 정렬하여 출력하여라.
SELECT EMP_NAME "이름", SALARY "급여", FLOOR(FLOOR(SYSDATE-HIRE_DATE)*SALARY*0.1)/1000 "특별보너스"
FROM EMPLOYEE
WHERE (EMP_NO LIKE '%-1%' OR EMP_NO LIKE '%-3%') -- 주민번호 뒷자리 첫번째자리가 3인 2000년생 이후 남자에 대한 경우
AND BONUS IS NULL
ORDER BY 1 ASC;

-- extra1
-- EMPLOYEE 테이블에서 EMAIL ID 중 @ 앞자리가 5자리인 직원을 조회한다면?
SELECT * FROM EMPLOYEE
WHERE EMAIL LIKE '_____@%';

-- extra2
-- EMPLOYEE 테이블에서 EMAIL ID 중 '_' 앞자리가 3자리인 직원을 조회한다면?
SELECT * FROM EMPLOYEE
WHERE EMAIL LIKE '___\_%@%' ESCAPE '\'; 

-- 실습1
-- 관리자(MANAGER_ID)도 없고 부서 배치 (DEPT_CODE)도 받지 않은 직원의 이름 조회하시오
SELECT EMP_NAME, MANAGER_ID, DEPT_CODE FROM EMPLOYEE
WHERE MANAGER_ID IS NULL AND DEPT_CODE IS NULL;

-- 실습2
-- 부서배치를 받지 않았지만 보너스를 지급하는 직원 전체 정보 조회
SELECT * FROM EMPLOYEE
WHERE DEPT_CODE IS NULL AND BONUS IS NOT NULL;
