-- Step 1: sign into AWS
-- Create an IAM role = snowflake_role with AmazonS3FullAccess

-- Step 2: Create a storage integration object
-- DO NOT RERUN THIS after you sucessfully create the integration
-- Re-running creates a new external ID
-- See: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
/*
 CREATE STORAGE INTEGRATION snowflake_s3_integration
   TYPE = EXTERNAL_STAGE
   STORAGE_PROVIDER = 'S3'
   ENABLED = TRUE
   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::724130249720:role/snowflake_role'
   STORAGE_ALLOWED_LOCATIONS = ('s3://dbouquin1-snowflake-test/');
*/

-- show configs
-- use STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID to populate "trust relationships" tied to "snowflake_role"
DESC INTEGRATION snowflake_s3_integration;

-- Trust relationships:
/*
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::497075275374:user/ql2a0000-s"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalID": "YZB80796_SFCRole=2_E9w6OZlyZhsslwFQ+cRhdiWu7AQ="
                }
            }
        }
    ]
}
*/

-- create stage
USE SCHEMA WEALTH_SCREENING.public;

CREATE OR REPLACE STAGE my_s3_stage
  STORAGE_INTEGRATION = snowflake_s3_integration
  URL = 's3://dbouquin1-snowflake-test/'
  FILE_FORMAT = (TYPE = CSV);


-- Copy data from RAW_ROI_EXPORT table to the stage
-- FIELD_OPTIONALLY_ENCLOSED_BY needed to handle blanks
COPY INTO @my_s3_stage/raw_roi_export
FROM WEALTH_SCREENING.public.RAW_ROI_EXPORT
FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
OVERWRITE = TRUE; 

-- List the files in the stage to confirm
LIST @my_s3_stage/;