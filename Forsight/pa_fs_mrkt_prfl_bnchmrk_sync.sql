create or replace PACKAGE PA_FS_BNCHMRK_SYNC AS 
  /*********************************************************
  * History
  * Created by   : Schiff Gy
  * Date         : 12/10/2016
  * Description  : First created 
  ******************************************************/

  PROCEDURE SYNC_BNCHMRK(p_MRKT_ID IN number,
     p_PRFL_CD IN number,
     p_EFF_PERD_ID IN number,
     p_user_id IN VARCHAR2,
     p_BENCHMARK_DATA IN T_TBL_FS_BNCHMRK);

END PA_FS_BNCHMRK_SYNC;

create or replace PACKAGE BODY PA_FS_BNCHMRK_SYNC AS
  /*********************************************************
  * History
  * Created by   : Schiff Gy
  * Date         : 12/10/2016
  * Description  : First created
  * Depends on   : Type Number_Array
  ******************************************************/

  PROCEDURE SYNC_BNCHMRK(p_MRKT_ID IN number,
      p_PRFL_CD IN number,
      p_EFF_PERD_ID IN number,
      p_user_id IN VARCHAR2,
      p_BENCHMARK_DATA IN T_TBL_FS_BNCHMRK) AS
    p_data_count number :=p_BENCHMARK_DATA.count;
    used_bnchmrk_prfl_codes NUMBER_ARRAY:=NUMBER_ARRAY();
  BEGIN
-- If no benchmark_profile_code referred in input,
--   delete all records identified by market_id, profile_code and effective_period_id
--   then add a new record, where benchmark_profile_code is the same as the profile_code and the default_indicator is set to 'yes' ('Y')
    IF p_data_count=0 THEN
      DELETE FROM FS_MRKT_PRFL_BNCHMRK
        WHERE MRKT_ID=p_MRKT_ID AND PRFL_CD=p_PRFL_CD AND EFF_PERD_ID=p_EFF_PERD_ID;
      INSERT INTO FS_MRKT_PRFL_BNCHMRK(MRKT_ID,PRFL_CD,EFF_PERD_ID,BNCHMRK_PRFL_CD,DFALT_IND,CREAT_USER_ID,LAST_UPDT_USER_ID)
        VALUES (p_MRKT_ID,p_PRFL_CD,p_EFF_PERD_ID,p_PRFL_CD,'Y',p_user_id,p_user_id);
    ELSE
-- else insert new and modify the existing records if needed
      FOR i IN 1..p_data_count LOOP
        MERGE INTO FS_MRKT_PRFL_BNCHMRK trgt
          USING (SELECT p_MRKT_ID t_mrkt_id,p_PRFL_CD t_prfl_cd,p_EFF_PERD_ID t_eff_perd_id,
                        p_BENCHMARK_DATA(i).BNCHMRK_PRFL_CD BNCHMRK_PRFL_CD from dual) src
            ON (src.t_MRKT_ID=trgt.MRKT_ID AND src.t_PRFL_CD=trgt.PRFL_CD AND src.t_EFF_PERD_ID=trgt.EFF_PERD_ID
                                              AND src.BNCHMRK_PRFL_CD=trgt.BNCHMRK_PRFL_CD)
          WHEN MATCHED THEN
            UPDATE SET trgt.DFALT_IND = p_BENCHMARK_DATA(i).DFALT_IND, trgt.LAST_UPDT_USER_ID=p_user_id
              WHERE trgt.DFALT_IND!=p_BENCHMARK_DATA(i).DFALT_IND
          WHEN NOT MATCHED THEN
            INSERT (MRKT_ID,PRFL_CD,EFF_PERD_ID,BNCHMRK_PRFL_CD,DFALT_IND,CREAT_USER_ID,LAST_UPDT_USER_ID)
              VALUES (p_MRKT_ID,p_PRFL_CD,p_EFF_PERD_ID,src.BNCHMRK_PRFL_CD,p_BENCHMARK_DATA(i).DFALT_IND,p_user_id,p_user_id);        used_bnchmrk_prfl_codes.extend();
        used_bnchmrk_prfl_codes(used_bnchmrk_prfl_codes.count):=p_BENCHMARK_DATA(i).BNCHMRK_PRFL_CD;
      END LOOP;
--   then delete the records identified by market_id, profile_code, effective_period_id and benchmark_profile_code not mentioned in the input (p_parm).      
      DELETE FROM FS_MRKT_PRFL_BNCHMRK
        WHERE MRKT_ID=p_MRKT_ID AND PRFL_CD=p_PRFL_CD AND EFF_PERD_ID=p_EFF_PERD_ID
          AND BNCHMRK_PRFL_CD NOT IN (select column_value from table( used_bnchmrk_prfl_codes ));
    END IF;
    NULL;
  END SYNC_BNCHMRK;

END PA_FS_BNCHMRK_SYNC;