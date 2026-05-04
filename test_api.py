def test_user_with_posts(provide_posts_data):
    user_posts = [p for p in provide_posts_data if p['userId'] == 3]
    assert len(user_posts) == 10


def test_data_is_presented_between_staging_raw(list_gcs_blobs, list_aws_blobs):
    assert len(list_gcs_blobs) > 0
    assert len(list_aws_blobs) > 0