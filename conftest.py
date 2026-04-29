import pytest


@pytest.fixture(scope="session")
def db_connection():
    class DummyCursor:
        def execute(self, sql):
            return self

        def fetchone(self):
            return [1]

    cursor = DummyCursor()
    yield cursor