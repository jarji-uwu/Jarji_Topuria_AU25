import os
from pathlib import Path
from random import seed, choice
from typing import List, Union
from collections import Counter
import re
import requests
from requests.exceptions import RequestException


S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    seed(1)

    with open(PATH_TO_NAMES, "r") as f:
        names = [line.strip().lower() for line in f if line.strip()]

    with open(PATH_TO_SURNAMES, "r") as f:
        surnames = [line.strip().lower() for line in f if line.strip()]

    names.sort()

    with open(PATH_TO_OUTPUT, "w") as out:
        for name in names:
            out.write(f"{name} {choice(surnames)}\n")


def task_2(top_k: int):
    with open(PATH_TO_STOP_WORDS, "r") as f:
        stop_words = set(word.strip().lower() for word in f)

    with open(PATH_TO_TEXT, "r") as f:
        text = f.read().lower()

    words = re.findall(r"[a-z]+", text)
    words = [w for w in words if w not in stop_words]

    counter = Counter(words)
    return counter.most_common(top_k)


def task_3(url: str):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response
    except RequestException:
        raise


def task_4(data: List[Union[int, str, float]]):
    total = 0
    for x in data:
        try:
            total += x
        except TypeError:
            total += float(x)
    return total


def task_5():
    try:
        a, b = input().split()
        a = float(a)
        b = float(b)

        if b == 0:
            print("Can't divide by zero")
        else:
            print(a / b)

    except ValueError:
        print("Entered value is wrong")
