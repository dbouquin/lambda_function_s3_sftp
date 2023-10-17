import boto3
import paramiko
import json
import io  

def get_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId="arn:aws:secretsmanager:us-east-1:724130249720:secret:SSH_KEY-W3FA4T")
    secret = json.loads(response['SecretString'])
    return secret
    
def lambda_handler(event, context):
    # Retrieve SSH key from Secrets Manager
    secret = get_secret()
    my_ssh_key = paramiko.RSAKey(file_obj=io.StringIO(secret['SSH_KEY']))

    # Initialize S3
    s3 = boto3.client('s3')

    # Parse S3 event to get bucket and file details
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Download the zipped file from S3
    s3_object = s3.get_object(Bucket=bucket, Key=key)
    zipped_file_data = s3_object['Body'].read()

    # Initialize SFTP connection using paramiko
    transport = paramiko.Transport(('inbound.roisolutions.net', 22))
    transport.connect(username='npca_dbouquin9335', pkey=my_ssh_key)
    sftp = paramiko.SFTPClient.from_transport(transport)

    # Upload the zipped file to the SFTP server root directory
    with sftp.open('filename.zip', 'wb') as f:
        f.write(zipped_file_data)

    # Close the SFTP connection
    sftp.close()
    transport.close()
