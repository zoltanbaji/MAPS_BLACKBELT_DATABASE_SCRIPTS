CREATE TABLE CASH_VAL_RF_HIST 
(
  MRKT_ID NUMBER NOT NULL 
, SLS_PERD_ID NUMBER NOT NULL 
, CASH_VAL NUMBER(15, 2) NOT NULL
, R_FACTOR NUMBER(6, 4) 
, PRCSNG_DT DATE 
, LAST_UPDT_USER_ID VARCHAR2(35 BYTE) DEFAULT USER NOT NULL 
, LAST_UPDT_TS DATE DEFAULT SYSDATE NOT NULL 
, CONSTRAINT PK_CASH_VAL_RF_HIST PRIMARY KEY 
  (
    MRKT_ID 
  , SLS_PERD_ID 
  , LAST_UPDT_USER_ID 
  , LAST_UPDT_TS 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX PK_CASH_VAL_RF_HIST ON CASH_VAL_RF_HIST (MRKT_ID ASC, SLS_PERD_ID ASC, LAST_UPDT_USER_ID ASC, LAST_UPDT_TS ASC) 
      TABLESPACE &index_tablespace_name 
  )
  ENABLE 
) TABLESPACE &data_tablespace_name
;

COMMENT ON TABLE CASH_VAL_RF_HIST IS 'Cash Value and R Factor History';

COMMENT ON COLUMN CASH_VAL_RF_HIST.MRKT_ID IS 'Market ID';

COMMENT ON COLUMN CASH_VAL_RF_HIST.SLS_PERD_ID IS 'Target Sales Campaign';

COMMENT ON COLUMN CASH_VAL_RF_HIST.CASH_VAL IS 'Previous Cash Value';

COMMENT ON COLUMN CASH_VAL_RF_HIST.R_FACTOR IS 'Previous R factor';

COMMENT ON COLUMN CASH_VAL_RF_HIST.PRCSNG_DT IS 'Previous ''billing day''';

COMMENT ON COLUMN CASH_VAL_RF_HIST.LAST_UPDT_USER_ID IS 'Last updating user''s ID';

COMMENT ON COLUMN CASH_VAL_RF_HIST.LAST_UPDT_TS IS 'Timestamp of last update';

