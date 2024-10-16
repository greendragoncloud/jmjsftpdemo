CREATE OR REPLACE PACKAGE jmj_sftp_constants_pkg AS

  -- Target SFTP Credentials
  GC_HOSTNAME               CONSTANT VARCHAR2(240)   := '<MY HOST>';
  GC_SFTP_USER              CONSTANT VARCHAR2(100)   := '<MY USER>';
  GC_SFTP_SSH_SECRET_OCID   CONSTANT VARCHAR2(1000)  := '<MY SECRET OCID>';

  -- OCI Storage
  GC_OCI_KEY                CONSTANT VARCHAR2(100)   := 'OCI_KEY_CRED';
  GC_BUCKET                 CONSTANT VARCHAR2(1000)  := '<MY BUCKET>';
  GC_BUCKET_INBOUND_FOLDER  CONSTANT VARCHAR2(1000)  := 'inbound';
  GC_BUCKET_OUTBOUND_FOLDER CONSTANT VARCHAR2(1000)  := 'outbound';
  GC_OCI_NAMESPACE          CONSTANT VARCHAR2(100)   := '<MY NAMESPACE>';
  GC_OCI_OBJECT_BASE_URL    CONSTANT VARCHAR2(100)   := 'https://objectstorage.<MY REGION>.oraclecloud.com';

END jmj_sftp_constants_pkg;
/