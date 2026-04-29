import time
import pytest


@pytest.fixture(scope="session", autouse=True)
def track_suite_time():
    start = time.time()
    yield
    end = time.time()
    print(f"\nTOTAL SUITE TIME: {end - start:.2f} seconds")


@pytest.fixture(autouse=True)
def track_test_time(request):
    if request.node.name == "test_add_negative_and_positive_numbers":
        yield
        return

    start = time.time()
    yield
    end = time.time()
    print(f"\nTEST {request.node.name} TIME: {end - start:.2f} seconds")


def add_numbers(a, b):
    return a + b


def test_add_two_positive_numbers():
    time.sleep(2)
    assert add_numbers(3, 5) == 8


def test_add_two_negative_numbers():
    time.sleep(3)
    assert add_numbers(-3, -5) == -8


def test_add_negative_and_positive_numbers():
    time.sleep(10)
    assert add_numbers(-3, 5) == 2