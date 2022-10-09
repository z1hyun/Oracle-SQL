
/* 문제 : 이전영업일과 익일영업일이 휴무일이 아닌 데이터를 찾아야한다 */

/* 달력 테이블생성 CREATE문) */
CREATE TABLE YMD(
 	SLRCAL_YMD VARCHAR(8),	 /*기준영업일*/
 	BFR_BIZN_YMD VARCHAR(8), /*이전영업일*/
 	NEXT_BIZN_YMD VARCHAR(8),/*익일영업일*/
 	HLDY_SECD CHAR(1) /*영업유무코드*/
);

SELECT * FROM YMD;
/* 달력테이블에 데이터 넣기  다중INSERT문 사용*/

INSERT ALL
	INTO YMD VALUES ('20221001', '20220931', '20221002' , '1')
	INTO YMD VALUES ('20221002', '20221001', '20221003' , '1') /*익영업일 일자가 휴무인 데이터*/
	INTO YMD VALUES ('20221003', '20221002', '20221004' , '2') 
	INTO YMD VALUES ('20221004', '20221002', '20221005' , '1') /*익영업일 일자가 휴무인 데이터*/
	INTO YMD VALUES ('20221005', '20221004', '20221006' , '2')
	INTO YMD VALUES ('20221006', '20221005', '20221007' , '1') /*이전영업일 일자가 휴무인 데이터*/
	INTO YMD VALUES ('20221007', '20221006', '20221008' , '1')
	INTO YMD VALUES ('20221008', '20221007', '20221009' , '1') /*익영업일 일자가 휴무인 데이터*/
	INTO YMD VALUES ('20221009', '20221007', '20221013' , '2')
	INTO YMD VALUES ('20221010', '20221007', '20221013' , '2')
	INTO YMD VALUES ('20221011', '20221007', '20221013' , '2')
	INTO YMD VALUES ('20221012', '20221007', '20221013' , '2')
	INTO YMD VALUES ('20221013', '20221012', '20221014' , '1') /* 이전영업일 일자가 휴무인 데이터*/
SELECT * 
	FROM DUAL;
	
COMMIT;

/* 1. 기준일자가 평일인 데이터를 찾는다 */
SELECT SLRCAL_YMD 
FROM YMD
WHERE HLDY_SECD = '1'

/* 2. YMD테이블에서 서브쿼리를 사용하여 이전영업일과 익일영업일이 평일이 아닌 데이터를 찾는다 */
SELECT * FROM YMD 
WHERE BFR_BIZN_YMD NOT IN (SELECT SLRCAL_YMD FROM YMD WHERE HLDY_SECD = '1') OR NEXT_BIZN_YMD NOT IN (SELECT SLRCAL_YMD FROM YMD WHERE HLDY_SECD = '1');


/* 쿼리가 반복되는게 많은거 같아서 이럴때는 WITH절을 사용해보고 싶어졌다 */

/* WITH절은 반복되는 서브쿼리가 있을때 사용한다고 본것같은데......
   하튼 이거는 서브쿼리를 테이블처럼 만들어서 사용할 수 있을것같아서 만들었다.*/
WITH errorYmd AS (
	SELECT SLRCAL_YMD FROM YMD WHERE HLDY_SECD = '1'
)
SELECT * FROM errorYmd;


/* 근데 어떻게 사용해야하는지 모르겠다 하는방법맏 오류난다.  다음에 알아보도록 하자 */

/*  내가 기존에 문제를 잘못 해석해서 나는 영업일 기준으로 올바른 이전영업일과 익영업일을 찾으란건줄 알았는데 아니였다 
	그래도 내가 찾아본 방법을 적어보겠음 */



SELECT A.SLRCAL_YMD , B.BFR_BIZN_YMD , C.NEXT_BIZN_YMD
FROM YMD A, 
(
 SELECT MAX(SLRCAL_YMD) AS BFR_BIZN_YMD FROM YMD WHERE HLDY_SECD = '1' AND SLRCAL_YMD < '20221006'
) B 
, (SELECT SLRCAL_YMD AS NEXT_BIZN_YMD FROM YMD WHERE HLDY_SECD = '1' AND SLRCAL_YMD > '20221006' AND ROWNUM = 1 ORDER BY NEXT_BIZN_YMD ASC
)C 
WHERE A.SLRCAL_YMD = '20221006'

/* 일단은 올바른 이전영업일과 익영업일을 가져오긴 했는데 과장님께서 이전영업일은 MAX를 썼는데 왜 익영업일은 MIN을 사용할 생각을 안했냐하셨다.. 그러게요.. 한번 고쳐보겠습니다..! */
SELECT A.SLRCAL_YMD , B.BFR_BIZN_YMD , C.NEXT_BIZN_YMD
FROM YMD A, 
(
 SELECT MAX(SLRCAL_YMD) AS BFR_BIZN_YMD FROM YMD WHERE HLDY_SECD = '1' AND SLRCAL_YMD < '20221006'
) B 
, (SELECT MIN(SLRCAL_YMD) AS NEXT_BIZN_YMD FROM YMD WHERE HLDY_SECD = '1' AND SLRCAL_YMD > '20221006'
)C 
WHERE A.SLRCAL_YMD = '20221006'
/* 위에거랑 조회되는 값이 똑같음 */

/*이건 문제를 이해 잘못해서 나온결과이긴 한데 이걸로도 찾아보려고 하는데 내가 저 날짜값을 1개로만 무조건 주게되어있어서 여러건의 데이터는 안나올것같음. 화요일에 다시 물어봐야지~~~~ */
