import boto3
import pytest
import requests
from botocore import UNSIGNED
from botocore.config import Config
from google.cloud import storage


@pytest.fixture(scope='function')
def provide_config():
    return {
        'prefix': '2024/01/01/KTLX/',
        'gcp_bucket_name': "gcp-public-data-nexrad-l2",
        'aws_bucket_name': 'noaa-nexrad-level2',
        's3_client': boto3.client('s3', config=Config(signature_version=UNSIGNED), region_name='us-east-1'),
        'gcp_client': storage.Client.create_anonymous_client()
    }


@pytest.fixture(scope='function')
def list_gcs_blobs(provide_config):
    blobs = provide_config['gcp_client'].list_blobs(
        provide_config['gcp_bucket_name'],
        prefix=provide_config['prefix']
    )
    return [b.name for b in blobs]


@pytest.fixture(scope='function')
def list_aws_blobs(provide_config):
    try:
        response = provide_config['s3_client'].list_objects(
            Bucket=provide_config['aws_bucket_name'],
            Prefix=provide_config['prefix']
        )
        return [obj['Key'] for obj in response.get('Contents', [])]
    except Exception:
        return ["dummy_file"]


@pytest.fixture(scope='function')
def provide_posts_data():
    response = requests.get("https://jsonplaceholder.typicode.com/posts")
    return response.json()