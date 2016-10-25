create or replace PACKAGE PA_DLY_BILNG_ADJSTMNT AS 
  /*********************************************************
  * History
  * Created by   : Schiff Gy
  * Date         : 25/10/2016
  * Description  : First created 
  ******************************************************/

  PROCEDURE SET_DLY_BILNG_ADJSTMNT(p_dly_bilng_id IN NUMBER,
                         p_new_bi24_units IN NUMBER,
                         p_user_id IN VARCHAR2,
                         p_stus OUT NUMBER);
                                  
  FUNCTION GET_DLY_BILNG_ADJSTMNT(p_mrkt_id IN NUMBER,
                        p_sls_perd_id IN NUMBER,
                        p_offr_perd_id IN NUMBER,
                        p_prcsng_dt IN DATE
                        ) RETURN OBJ_DLY_BILNG_ADJSTMNT_TABLE PIPELINED;                                

END PA_DLY_BILNG_ADJSTMNT;

create or replace PACKAGE BODY PA_DLY_BILNG_ADJSTMNT AS

  FUNCTION GET_DLY_BILNG_ADJSTMNT(p_mrkt_id IN NUMBER,
                        p_sls_perd_id IN NUMBER,
                        p_offr_perd_id IN NUMBER,
                        p_prcsng_dt IN DATE
                        ) RETURN OBJ_DLY_BILNG_ADJSTMNT_TABLE PIPELINED AS
-- TODO add optional input DLY_BILNG_ID_List as NUMBER_ARRAY and filtering by IN(DLY_BILNG_ID_List)                        
  CURSOR cc IS
    SELECT OBJ_DLY_BILNG_ADJSTMNT_LINE(
      DB.DLY_BILNG_ID,
      DB.FSC_CD,
      PA_MAPS_PUBLIC.get_fsc_desc(p_mrkt_id,p_offr_perd_id,DB.FSC_CD),
      DB.SKU_ID,
      S.LCL_SKU_NM,
      DB.SLS_PRC_AMT,
      DB.NR_FOR_QTY,
      DB.SLS_PRC_AMT/DB.NR_FOR_QTY,
--      'A',
      DECODE((SELECT 1 FROM dual WHERE
                EXISTS( SELECT SKU_PRC_AMT FROM MRKT_PERD_SKU_PRC MPSP
                   WHERE MPSP.MRKT_ID=p_mrkt_id AND MPSP.OFFR_PERD_ID=p_sls_perd_id
                    AND MPSP.SKU_ID=S.SKU_ID AND MPSP.PRC_LVL_TYP_CD='RP' )
                AND EXISTS( SELECT HOLD_COSTS_IND FROM SKU_COST SC 
                   WHERE SC.MRKT_ID=p_mrkt_id AND SC.OFFR_PERD_ID=p_offr_perd_id
                    AND SC.SKU_ID=S.SKU_ID AND COST_TYP='P')
                AND (PA_MAPS_PUBLIC.get_sls_cls_cd(p_offr_perd_id, p_mrkt_id, s.avlbl_perd_id,
                         s.intrdctn_perd_id, s.demo_ofs_nr, s.demo_durtn_nr, s.new_durtn_nr,
                         s.stus_perd_id, s.dspostn_perd_id, s.on_stus_perd_id)!='-1')),'1','A','N'),
	    DECODE((SELECT count(*) FROM OFFR_SKU_LINE OSL 
              WHERE OSL.OFFR_ID in( SELECT OFFR_ID FROM OFFR O
                                    WHERE O.MRKT_ID=p_mrkt_id
                                     AND O.VER_ID = 0
                                     AND O.OFFR_TYP='CMP'
                                     AND O.OFFR_PERD_ID =p_offr_perd_id)
               AND OSL.DLTD_IND NOT IN ('Y','y')
               AND OSL.SKU_ID=S.SKU_ID),0,'N','P'),
      DB.UNIT_QTY,
      DBAT.UNIT_QTY,
      DBAT.LAST_UPDT_USER_ID,
      DBAT.LAST_UPDT_TS) cline
    FROM DLY_BILNG DB
      LEFT JOIN MRKT_SKU S
        ON S.MRKT_ID=p_mrkt_id AND S.SKU_ID=DB.SKU_ID
      LEFT JOIN DLY_BILNG_ADJSTMNT DBAT
        ON DBAT.DLY_BILNG_ID=DB.DLY_BILNG_ID
    WHERE DB.MRKT_ID=p_mrkt_id AND DB.SLS_PERD_ID=p_sls_perd_id
      AND DB.OFFR_PERD_ID=p_offr_perd_id AND trunc(DB.PRCSNG_DT)=trunc(p_prcsng_dt)
--    ORDER BY DB.DLY_BILNG_ID,db.SKU_ID
    ;
  BEGIN

    FOR rec in cc LOOP
      pipe row(rec.cline);
    END LOOP; 
  END GET_DLY_BILNG_ADJSTMNT;
  
  PROCEDURE SET_DLY_BILNG_ADJSTMNT(p_dly_bilng_id IN NUMBER,
                         p_new_bi24_units IN NUMBER,
                         p_user_id IN VARCHAR2,
                         p_stus OUT NUMBER) AS
  /*********************************************************
  * INPUT p_new_bi24_units IS NULL handled as record has to be deleted
  *
  * Possible OUT Values
  * 0 - success
  * 2 - database error in DELETE, UPDATE or INSERT statements
  * 3 - Obligatory foreign keys (DLY_BILNG) not found
  ******************************************************/
    counter1 NUMBER;
  BEGIN
    SELECT count(*) INTO counter1 FROM DLY_BILNG WHERE DLY_BILNG_ID=p_dly_bilng_id;
    IF counter1>0 THEN
    -- p_new_bi24_units IS NULL, the record if exists
      IF p_new_bi24_units IS NULL THEN
        BEGIN
        SAVEPOINT before_delete;
          DELETE FROM DLY_BILNG_ADJSTMNT WHERE DLY_BILNG_ID=p_dly_bilng_id;
        EXCEPTION WHEN OTHERS THEN ROLLBACK TO before_delete; p_stus:=2;
        END;
    -- otherwise upsert using p_new_bi24_units
      ELSE
        BEGIN
        SAVEPOINT before_upsert; 		 
          MERGE INTO DLY_BILNG_ADJSTMNT trgt
            USING (SELECT p_dly_bilng_id t1 FROM dual) src
              ON (trgt.DLY_BILNG_ID=src.t1)
            WHEN MATCHED THEN
              UPDATE SET trgt.UNIT_QTY = p_new_bi24_units, trgt.LAST_UPDT_USER_ID=p_user_id
            WHEN NOT MATCHED THEN
              INSERT (DLY_BILNG_ID,UNIT_QTY,LAST_UPDT_USER_ID)
                VALUES (p_dly_bilng_id,p_new_bi24_units,p_user_id);
	       EXCEPTION WHEN OTHERS THEN ROLLBACK TO before_changes; p_stus:=2;
		     END;	
      END IF;
    ELSE p_STUS:=3;  
    END IF;
  END SET_DLY_BILNG_ADJSTMNT;
                                  
END PA_DLY_BILNG_ADJSTMNT;