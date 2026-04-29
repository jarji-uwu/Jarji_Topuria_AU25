import pytest
import yaml


def get_numbers_data(config_name):
    with open(config_name, 'r') as stream:
        config = yaml.safe_load(stream)
    return config


def add_numbers(a, b, c):
    if not all(isinstance(x, (int, float)) for x in [a, b, c]):
        raise TypeError("All parameters must be numeric")
    return a + b + c


data = get_numbers_data("config.yaml")


@pytest.mark.smoke
@pytest.mark.parametrize("case", data["cases"])
def test_add_numbers(case):
    a, b, c = case["input"]
    expected = case["expected"]
    assert add_numbers(a, b, c) == expected


@pytest.mark.critical
@pytest.mark.parametrize("inputs", data["invalid_cases"])
def test_add_invalid_types(inputs):
    with pytest.raises(TypeError):
        add_numbers(*inputs)