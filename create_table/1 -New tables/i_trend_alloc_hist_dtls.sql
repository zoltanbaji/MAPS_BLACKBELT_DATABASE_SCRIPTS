CREATE INDEX IX_TREND_ALLOC_HIST_DTLS ON TREND_ALLOC_HIST_DTLS (MRKT_ID ASC, SLS_PERD_ID ASC, SLS_TYP_ID ASC, BILNG_DAY ASC) 
TABLESPACE &index_tablespace_name;
