create or replace TYPE OBJ_CASH_VAL_MANTNC_LINE as object
( SLS_PERD_ID number(8),
     CASH_VAL number(15,2),
     SCT_R_FACTOR number(6,4),
     UPDT_IND varchar2(35),
     LAST_UPDT_TS date,
     LAST_UPDT_USER_ID varchar2(35)
);

create or replace TYPE OBJ_CASH_VAL_MANTNC_TABLE IS TABLE OF OBJ_CASH_VAL_MANTNC_LINE;

create or replace TYPE OBJ_SKU_BIAS_MANTNC_LINE as object
( FSC_CD number(8),
     PROD_DESC_TXT varchar2(100),
     SKU_ID number(8),
     LCL_SKU_NM varchar2(150),
	 ACT_IND char(1),
	 PLN_IND char(1),
     BIAS_PCT number(6,2),
     CREAT_TS date,
     CREAT_USER_ID varchar2(35),
     LAST_UPDT_TS date,
     LAST_UPDT_USER_ID varchar2(35)
);

create or replace TYPE OBJ_SKU_BIAS_MANTNC_TABLE IS TABLE OF OBJ_SKU_BIAS_MANTNC_LINE;

create or replace TYPE FS_MRKT_PRFL_BNCHMRK_DATA AS OBJECT
    ( BNCHMRK_PRFL_CD number(7),
      DFALT_IND char(1)
    );
/  
create or replace TYPE FS_MRKT_PRFL_BNCHMRK_DTA_TABLE IS TABLE OF FS_MRKT_PRFL_BNCHMRK_DATA;
/
create or replace TYPE FS_MRKT_PRFL_BNCHMRK_LINE AS object
   ( MRKT_ID number,
     PRFL_CD number(7,0),
     EFF_PERD_ID number,
     BENCHMARK_DATA FS_MRKT_PRFL_BNCHMRK_DTA_TABLE,
     CREAT_USR_ID varchar2(35),
     CREAT_TS date,
     LAST_UPDT_USR_ID varchar2(35),
     LAST_UPDT_TS date
     );
/