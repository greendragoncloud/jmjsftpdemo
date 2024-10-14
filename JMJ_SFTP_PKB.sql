CREATE OR REPLACE PACKAGE BODY jmj_sftp_pkg AS

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
      ,p_response          OUT CLOB) IS

  BEGIN

    APEX_JSON.initialize_clob_output;
    APEX_JSON.open_object;
     APEX_JSON.write('operation', 'GET');
     APEX_JSON.write('sftp_file'  ,CASE
                                     WHEN p_sftp_folder IS NULL
                                       THEN p_sftp_filename
                                       ELSE p_sftp_folder || '/' || p_sftp_filename
                                   END);
     APEX_JSON.write('object_name',CASE
                                     WHEN p_oci_object_folder IS NULL
                                       THEN JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET_OUTBOUND_FOLDER || '/' || p_oci_object_name
                                       ELSE p_oci_object_folder|| '/' || p_oci_object_name
                                    END);
     APEX_JSON.write('bucket'     ,JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET);
     APEX_JSON.write('user'       ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_USER);
     APEX_JSON.write('host'       ,JMJ_SFTP_CONSTANTS_PKG.GC_HOSTNAME);
     APEX_JSON.write('secret'     ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_SSH_SECRET_OCID);
    APEX_JSON.close_object;

    p_response := fun_jmj_sftp_demo(APEX_JSON.get_clob_output);
    APEX_JSON.free_output;

  END;

  PROCEDURE clob_to_sftp
       (p_content           IN CLOB
       ,p_sftp_folder       IN VARCHAR2 DEFAULT NULL
       ,p_sftp_filename     IN VARCHAR2
       ,p_response          OUT CLOB) IS
  BEGIN
    DBMS_CLOUD.PUT_OBJECT(
       credential_name => JMJ_SFTP_CONSTANTS_PKG.GC_OCI_KEY,
       object_uri      => JMJ_SFTP_CONSTANTS_PKG.GC_OCI_OBJECT_BASE_URL    || '/n/' || 
                          JMJ_SFTP_CONSTANTS_PKG.GC_OCI_NAMESPACE          || '/b/' || 
                          JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET                 || '/o/' ||
                          JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET_OUTBOUND_FOLDER || '/' ||
                          p_sftp_filename,
       contents        => apex_util.clob_to_blob( p_clob => p_content, p_charset => 'AL32UTF8' ) ); 
    oci_file_to_sftp
      (p_sftp_folder       => p_sftp_folder
      ,p_sftp_filename     => p_sftp_filename
      ,p_oci_object_name   => p_sftp_filename
      ,p_response          => p_response);
  END;
       
  PROCEDURE sftp_file_to_oci
      (p_sftp_folder       IN VARCHAR2 DEFAULT NULL
      ,p_sftp_filename     IN VARCHAR2
      ,p_oci_object_folder IN VARCHAR2 DEFAULT NULL
      ,p_oci_object_name   IN VARCHAR2
      ,p_response          OUT CLOB) IS
    v_return CLOB;
  BEGIN

    APEX_JSON.initialize_clob_output;
    APEX_JSON.open_object;
     APEX_JSON.write('operation', 'PUT');
     APEX_JSON.write('sftp_file'  ,CASE WHEN p_sftp_folder IS NULL
                                     THEN p_sftp_filename
                                     ELSE p_sftp_folder || '/' || p_sftp_filename
                                   END);
     APEX_JSON.write('object_name',CASE WHEN p_oci_object_folder IS NULL
                                     THEN JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET_INBOUND_FOLDER
                                             || '/' || p_oci_object_name
                                      ELSE p_oci_object_folder|| '/' || p_oci_object_name
                                    END);
     APEX_JSON.write('bucket'     ,JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET);
     APEX_JSON.write('user'       ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_USER);
     APEX_JSON.write('host'       ,JMJ_SFTP_CONSTANTS_PKG.GC_HOSTNAME);
     APEX_JSON.write('secret'     ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_SSH_SECRET_OCID);
    APEX_JSON.close_object;

    p_response := fun_jmj_sftp_demo(APEX_JSON.get_clob_output);
    APEX_JSON.free_output;

  END;

  PROCEDURE sftp_file_to_clob
      (p_sftp_folder     IN VARCHAR2
      ,p_sftp_filename   IN VARCHAR2
      ,p_content         OUT CLOB
      ,p_response        OUT CLOB) IS
  BEGIN
    sftp_file_to_oci
      (p_sftp_folder       => p_sftp_folder
      ,p_sftp_filename     => p_sftp_filename
      ,p_oci_object_name   => p_sftp_filename
      ,p_response          => p_response);
    p_content := TO_CLOB(DBMS_CLOUD.GET_OBJECT(
       credential_name => JMJ_SFTP_CONSTANTS_PKG.GC_OCI_KEY,
       object_uri      => JMJ_SFTP_CONSTANTS_PKG.GC_OCI_OBJECT_BASE_URL    || '/n/' || 
                          JMJ_SFTP_CONSTANTS_PKG.GC_OCI_NAMESPACE          || '/b/' || 
                          JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET                 || '/o/' ||
                          JMJ_SFTP_CONSTANTS_PKG.GC_BUCKET_INBOUND_FOLDER  || '/' ||
                          p_sftp_filename)); 
  END;

  PROCEDURE list_files
      (p_sftp_folder     IN VARCHAR2
      ,p_sftp_pattern    IN VARCHAR2
      ,p_response        OUT CLOB) IS

  BEGIN

    APEX_JSON.initialize_clob_output;
    APEX_JSON.open_object;
     APEX_JSON.write('operation'       ,'LIST');
     APEX_JSON.write('list_directory'  ,p_sftp_folder);
     APEX_JSON.write('list_pattern'    ,p_sftp_pattern);
     APEX_JSON.write('user'            ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_USER);
     APEX_JSON.write('host'            ,JMJ_SFTP_CONSTANTS_PKG.GC_HOSTNAME);
     APEX_JSON.write('secret'          ,JMJ_SFTP_CONSTANTS_PKG.GC_SFTP_SSH_SECRET_OCID);
    APEX_JSON.close_object;

    p_response := fun_jmj_sftp_demo(APEX_JSON.get_clob_output);

    APEX_JSON.free_output;

  END;

  FUNCTION file_list_as_array(p_response IN CLOB) 
  RETURN filename_table_type PIPELINED IS
    l_response_body CLOB;
    l_file_list     JSON_ARRAY_T;
  BEGIN
    l_response_body := LTRIM(RTRIM(JSON_QUERY(p_response,'$[0].RESPONSE_BODY' returning varchar2 pretty),'"'),'"');
    IF l_response_body IS NULL THEN
      NULL; -- No filenames to parse
    ELSE
      l_file_list := JSON_ARRAY_T.parse(l_response_body);
      FOR i IN 0 .. l_file_list.get_size -1 LOOP
        PIPE ROW (l_file_list.get_string(i));
      END LOOP;
    END IF;
    RETURN; -- Single point of return
  END;

END jmj_sftp_pkg;
/