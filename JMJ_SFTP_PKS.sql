CREATE OR REPLACE PACKAGE jmj_sftp_pkg AS

  ------------------------------------------------------------------------------- 
  -- NAME        : JMJ_SFTP_PKS.sql
  -- REVISION    : 1.0
  -- PURPOSE     : Package Spec
  -- 
  -- This package provides a set of tools to handle file transfers between an SFTP
  -- server and OCI, and also to convert and manage file contents within Oracle. 
  -- It uses APEX_JSON for JSON manipulation and DBMS_CLOUD for interactions with OCI.
  -- 
  -- REVISION HISTORY: 
  -- VER    DATE          AUTHOR        DESCRIPTION 
  -- =====  ===========   ============= ========================== 
  -- 1.0    14-Oct-2024   JMJ           Initial Version 
  ------------------------------------------------------------------------------- 

  PROCEDURE oci_file_to_sftp
      (p_sftp_folder       IN VARCHAR2 DEFAULT NULL
      ,p_sftp_filename     IN VARCHAR2
      ,p_oci_object_folder IN VARCHAR2 DEFAULT NULL
      ,p_oci_object_name   IN VARCHAR2
      ,p_response          OUT CLOB);

  PROCEDURE clob_to_sftp
       (p_content           IN CLOB
       ,p_sftp_folder       IN VARCHAR2 DEFAULT NULL
       ,p_sftp_filename     IN VARCHAR2
       ,p_response          OUT CLOB);

  PROCEDURE sftp_file_to_oci
      (p_sftp_folder       IN VARCHAR2 DEFAULT NULL
      ,p_sftp_filename     IN VARCHAR2
      ,p_oci_object_folder IN VARCHAR2 DEFAULT NULL
      ,p_oci_object_name   IN VARCHAR2
      ,p_response          OUT CLOB);

  PROCEDURE sftp_file_to_clob
      (p_sftp_folder     IN VARCHAR2
      ,p_sftp_filename   IN VARCHAR2
      ,p_content         OUT CLOB
      ,p_response        OUT CLOB);

  PROCEDURE list_files
      (p_sftp_folder     IN VARCHAR2
      ,p_sftp_pattern    IN VARCHAR2
      ,p_response        OUT CLOB);

  FUNCTION file_list_as_array(p_response IN CLOB) 
  RETURN filename_table_type PIPELINED;

END jmj_sftp_pkg;
/