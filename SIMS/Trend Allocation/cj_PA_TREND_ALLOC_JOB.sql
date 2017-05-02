﻿alter session set NLS_LANGUAGE='ENGLISH' NLS_TERRITORY='UNITED KINGDOM' NLS_CURRENCY='£' NLS_ISO_CURRENCY='UNITED KINGDOM' NLS_NUMERIC_CHARACTERS='.,' NLS_CALENDAR='GREGORIAN' NLS_DATE_FORMAT='DD-MON-RR' NLS_DATE_LANGUAGE='ENGLISH' NLS_SORT='BINARY' NLS_TIME_FORMAT='HH24.MI.SSXFF' NLS_TIMESTAMP_FORMAT='DD-MON-RR HH24.MI.SSXFF' NLS_TIME_TZ_FORMAT='HH24.MI.SSXFF TZR' NLS_TIMESTAMP_TZ_FORMAT='DD-MON-RR HH24.MI.SSXFF TZR' NLS_DUAL_CURRENCY='€' NLS_COMP='BINARY' NLS_LENGTH_SEMANTICS='BYTE' NLS_NCHAR_CONV_EXCP='FALSE';
begin
  --create
  DBMS_SCHEDULER.CREATE_JOB(job_name => 'PA_TREND_ALLOC_JOB',
                          job_type => 'STORED_PROCEDURE',
                          job_action => 'WEDEV.PA_TREND_ALLOC.PROCESS_JOBS_NEW_PERIODS',
                          start_date => TO_TIMESTAMP_TZ (to_char(trunc(sysdate, 'HH24')+1/24, 'YYYY-MM-DD HH24:MI:SS') || ' EST5EDT', 'YYYY-MM-DD HH:MI:SS TZR'),
                          auto_drop => false,
                          repeat_interval => 'FREQ=HOURLY;INTERVAL=1',
                          enabled => true);
end;
/
