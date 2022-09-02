import sys
import os
import boto3
import logging
from pathlib import Path
from botocore.exceptions import ClientError
from dotenv import load_dotenv
BASE_DIR = Path(__file__).resolve().parent.parent
ENV_FILE = os.path.join(BASE_DIR, '.env/aws.env')
load_dotenv(dotenv_path=ENV_FILE)
aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
s3 = boto3.client(
        's3',
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
        )

def upload_to_s3(file_name, bucket, object_name=None):
    if object_name is None:
        object_name = os.path.basename(file_name)
    try:
        response = s3.upload_file(file_name, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('Usage: {} <file_name> <bucket_name> <s3_key>'.format(sys.argv[0]))
        sys.exit(1)
    upload_to_s3(sys.argv[1], sys.argv[2], sys.argv[3])
