import pytest
import yaml


def load_config():
    with open("config_sql.yaml") as f:
        return yaml.safe_load(f)


data = load_config()


@pytest.mark.smoke
@pytest.mark.parametrize("test_case", data["tests"][:3])
def test_smoke_queries(db_connection, test_case):
    db_connection.execute(test_case["sql"])
    result = db_connection.fetchone()[0]
    assert result == test_case["expected"]


@pytest.mark.critical
@pytest.mark.parametrize("test_case", data["tests"])
def test_critical_queries(db_connection, test_case):
    db_connection.execute(test_case["sql"])
    result = db_connection.fetchone()[0]
    assert result == test_case["expected"]