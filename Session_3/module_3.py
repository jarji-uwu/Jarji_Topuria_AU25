import time
from functools import wraps

# Task 1
def task_1(exp):
    def power(x):
        return x ** exp
    return power


# Task 2
def task_2(*args, **kwargs):
    for v in args:
        print(v)
    for v in kwargs.values():
        print(v)


# Task 3
def helper(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        print("Hi, friend! What's your name?")
        result = func(*args, **kwargs)
        print("See you soon!")
        return result
    return wrapper


@helper
def task_3(name):
    print(f"Hello! My name is {name}.")


# Task 4
def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        run_time = time.time() - start
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        return result
    return wrapper


@timer
def task_4():
    time.sleep(4)


# Task 5
def task_5(matrix):
    return [list(row) for row in zip(*matrix)]


# Optional Task 6
def task_6(s):
    balance = 0
    for ch in s:
        if ch == '(':
            balance += 1
        elif ch == ')':
            balance -= 1
        if balance < 0:
            return False
    return balance == 0
