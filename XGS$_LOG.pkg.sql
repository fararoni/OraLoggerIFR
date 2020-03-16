create or replace PACKAGE XGS$_LOG AS 
  -- This project uses the following MIT License:
  -- The MIT License (MIT)
  -- Copyright (c) 2018 SeguriSoft

  -- GLOBAL VARIABLES
    g_context_name constant varchar2(35) := substr(sys_context('USERENV','CURRENT_SCHEMA'),1,23);
    g_debug_disabled constant varchar2(30) := 'OFF';
    g_debug_enabled constant varchar2(30)  := 'ON';

  -- Check Constraint Database: TRACE DEBUG INFO WARN ERROR FATAL
   L_TRACE  constant varchar2(30) := 'TRACE';
   L_DEBUG  constant varchar2(30) := 'DEBUG';
   L_INFO   constant varchar2(30) := 'INFO';
   L_WARN   constant varchar2(30) := 'WARN';
   L_ERROR  constant varchar2(30) := 'ERROR';
   L_FATAL  constant varchar2(30) := 'FATAL';
    
  -- GLOBAL SETTINGS
   g_set_log_level    constant varchar2(30) := 'TRACE';

    PROCEDURE LOG(p_log_level in VARCHAR, MSG IN VARCHAR2);
    PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2);
    PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_BLOB IN BLOB);
    PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_CLOB IN CLOB);
    PROCEDURE LOG(p_log_level in VARCHAR, MODULE IN VARCHAR2, MSG  IN VARCHAR2, LOG_XML  IN XMLTYPE);
    
    -- Métodos sobrecargados para guardar errores.
    PROCEDURE ERROR   (MSG  IN VARCHAR2);
    PROCEDURE ERROR   (MSG  IN VARCHAR2, DATA_BLOB IN BLOB);
    PROCEDURE ERROR   (MSG  IN VARCHAR2, TXT_CLOB IN CLOB);
    PROCEDURE ERROR   (MSG  IN VARCHAR2, TXT_XML IN XMLTYPE);
    
END XGS$_LOG;
