CREATE OR REPLACE
PACKAGE BODY XGS$_LOG AS

  procedure save_error_XGS$ (LN_LOG_APL_ID IN NUMBER, lv_errm IN VARCHAR2, p_apl_message IN VARCHAR2 ) is PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO xgs$_log_apl (
                log_curr_timestamp,
                log_level,
                apl_module,
                apl_message
            ) VALUES (
                current_timestamp,
                l_fatal,
                'XGS$_LOG', 'LOG_APL_ID['|| LN_LOG_APL_ID|| ']' || lv_errm || ' ' || p_apl_message
            ); 
            COMMIT;
  EXCEPTION
                WHEN OTHERS THEN            
                    dbms_output.put_line('XGS$_LOG.save_error_XGS$' || lv_errm || ' ' || p_apl_message);
            COMMIT;
                
  END save_error_XGS$;

  procedure save_log (p_log_level in varchar2
    , p_apl_module in varchar2
    , p_apl_message in varchar2
    , p_apl_method_actual in varchar2
    , p_apl_method_parent in varchar2
    
    , p_unit_owner in varchar2
    , p_unit_name in varchar2
    , p_unit_line in number
    , p_unit_caller in varchar2
    
    , p_error_call_stack in varchar2
    , p_error_stack in varchar2
    , p_error_back_trace in varchar2
    , p_blob in blob
    , p_clob in clob
    , p_xml in XMLTYPE ) is 
  PRAGMA AUTONOMOUS_TRANSACTION;
    lv_errm         VARCHAR2(32000);
    LN_LOG_APL_ID   NUMBER;
  begin
    LN_LOG_APL_ID:= -1000;
        INSERT INTO xgs$_log_apl (
        
        log_curr_timestamp,
        log_level,
        
        apl_module,
        apl_message,
        apl_method_actual,
        apl_method_parent,
        
        unit_owner,
        unit_name,
        unit_line,
        unit_caller,
        
        error_call_stack,
        error_stack,
        error_back_trace,
        
        log_db_context,
        log_db_sid,
        log_db_timestamp_tz,
        log_user_terminal,
        log_user_os_user,
        log_user_ip_user

    ) VALUES (
        
        current_timestamp,
        p_log_level,
        
        p_apl_module,
        p_apl_message,
        p_apl_method_actual,
        p_apl_method_parent,
        
        p_unit_owner,
        p_unit_name,
        p_unit_line,
        p_unit_caller,
        
        p_error_call_stack,
        p_error_stack,
        p_error_back_trace,
        
        g_context_name,
        to_char(sys_context('USERENV','SID')),
        current_timestamp,
        sys_context('USERENV','TERMINAL'),
        'OS:[' || sys_context('USERENV','OS_USER') 
              || ']:[' || v('USER_ID') || '] APEX[' || sys_context('APEX$SESSION', 'APP_USER') ||']',
        sys_context('userenv', 'ip_address')
        
    )  RETURNING LOG_APL_ID INTO LN_LOG_APL_ID;
    IF ( p_blob is not NULL or p_clob is not null or p_xml is not null ) THEN
        BEGIN
            INSERT INTO xgs$_log_lob (
                log_apl_id,
                log_clob,
                log_blob,
                log_xml
                
            ) VALUES (
                LN_LOG_APL_ID,
                p_clob,
                p_blob,
                p_xml
            );
            
            EXCEPTION
                WHEN OTHERS THEN
                    save_error_XGS$ (LN_LOG_APL_ID , SQLERRM , p_apl_message );
        END;
    END IF;
    COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
            save_error_XGS$ (LN_LOG_APL_ID , SQLERRM , p_apl_message );
            
  end save_log;

  PROCEDURE LOG(p_log_level in VARCHAR, MSG IN VARCHAR2) AS
      oname     VARCHAR2(100);
      pname     VARCHAR2(2000);
      lnumb     VARCHAR2(2000);
      callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (p_log_level
    , pname    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , NULL    , NULL    , NULL    
    , NULL    , NULL    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1001, SQLERRM , MSG ); 
  END LOG;

  PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2) AS
     oname     VARCHAR2(100);
      pname     VARCHAR2(2000);
      lnumb     VARCHAR2(2000);
      callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (p_log_level
    , MODULE    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , NULL    , NULL    , NULL    
    , NULL    , NULL    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1002, SQLERRM , MSG ); 
  END LOG;

  PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_BLOB IN BLOB) AS
     oname     VARCHAR2(100);
      pname     VARCHAR2(2000);
      lnumb     VARCHAR2(2000);
      callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (p_log_level
    , MODULE    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , NULL    , NULL    , NULL    
    , LOG_BLOB    , NULL    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1003, SQLERRM , MSG ); 
  END LOG;

  PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_CLOB IN CLOB) AS
     oname     VARCHAR2(100);
      pname     VARCHAR2(2000);
      lnumb     VARCHAR2(2000);
      callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (p_log_level
    , MODULE    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , NULL    , NULL    , NULL    
    , NULL    , LOG_CLOB    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1004, SQLERRM , MSG ); 
  END LOG;

  PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_XML  IN XMLTYPE) AS
     oname     VARCHAR2(100);
      pname     VARCHAR2(2000);
      lnumb     VARCHAR2(2000);
      callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (p_log_level
    , MODULE    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , NULL    , NULL    , NULL    
    , NULL    , NULL    , LOG_XML);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1005, SQLERRM , MSG ); 
  END LOG;

  PROCEDURE ERROR   (MSG  IN VARCHAR2) AS
     oname     VARCHAR2(100);
     pname     VARCHAR2(2000);
     lnumb     VARCHAR2(2000);
     callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (l_error
    , pname    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , dbms_utility.format_call_stack,  dbms_utility.format_error_stack, dbms_utility.format_error_backtrace    
    , NULL    , NULL    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1006, SQLERRM , MSG ); 
  END ERROR;

  PROCEDURE ERROR   (MSG  IN VARCHAR2, DATA_BLOB IN BLOB) AS
     oname     VARCHAR2(100);
     pname     VARCHAR2(2000);
     lnumb     VARCHAR2(2000);
     callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (l_error
    , pname    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , dbms_utility.format_call_stack,  dbms_utility.format_error_stack, dbms_utility.format_error_backtrace    
    , DATA_BLOB    , NULL    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1007, SQLERRM , MSG ); 
  END ERROR;

  PROCEDURE ERROR   (MSG  IN VARCHAR2, TXT_CLOB IN CLOB) AS
     oname     VARCHAR2(100);
     pname     VARCHAR2(2000);
     lnumb     VARCHAR2(2000);
     callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (l_error
    , pname    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , dbms_utility.format_call_stack,  dbms_utility.format_error_stack, dbms_utility.format_error_backtrace    
    , NULL    , TXT_CLOB    , NULL);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1008, SQLERRM , MSG );
  END ERROR;

  PROCEDURE ERROR   (MSG  IN VARCHAR2, TXT_XML IN XMLTYPE) AS
     oname     VARCHAR2(100);
     pname     VARCHAR2(2000);
     lnumb     VARCHAR2(2000);
     callr     VARCHAR2(2000);
  BEGIN
    owa_util.who_called_me(oname, pname, lnumb, callr);
    save_log (l_error
    , pname    , MSG    
    , oname || '.' || pname    , NULL
    , oname    , pname    , lnumb    , callr
    , dbms_utility.format_call_stack,  dbms_utility.format_error_stack, dbms_utility.format_error_backtrace    
    , NULL    , NULL    , TXT_XML);
  EXCEPTION
        WHEN OTHERS THEN
           save_error_XGS$ (-1009, SQLERRM , MSG );
  END ERROR;

END XGS$_LOG;