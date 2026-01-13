#session_1
from typing import List

def task_1(array: List[int], target: int) -> List[int]:
    seen = set()
    for x in array:
        complement = target - x
        if complement in seen:
            return [complement, x]
        seen.add(x)
    return []

if __name__ == "__main__":
    sample = [3, 4, -1, 10, 12]
    target = 2
    print(task_1(sample, target))  # -> [3, -1]
    pass


def task_2(number: int) -> int:
    sign = -1 if number < 0 else 1
    n = abs(number)
    rev = 0
    while n > 0:
        rev = rev * 10 + (n % 10)
        n //= 10
    return sign * rev
if __name__ == "__main__":
    sample = 130
    print(task_2(sample))
    pass



def task_3(array: List[int]) -> int:
    for x in array:
        val = abs(x)           
        idx = val - 1  
        if array[idx] < 0:
            return val
        array[idx] = -array[idx]
    return -1

if __name__ == "__main__":
    sample = [2, 1, 3, 4,2]
    print(task_3(sample)) 
    pass


def task_4(roman: str) -> int:
    """
    Convert a Roman numeral string to an integer.
    Assumes input contains only the characters I,V,X,L,C,D,M and is well-formed.
    """
    if not roman:
        return 0

    vals = {
        "I": 1,
        "V": 5,
        "X": 10,
        "L": 50,
        "C": 100,
        "D": 500,
        "M": 1000,
    }

    total = 0
    n = len(roman)
    for i, ch in enumerate(roman):
        v = vals[ch]
        # if next symbol exists and is larger, subtract current; otherwise add
        if i + 1 < n and vals[roman[i + 1]] > v:
            total -= v
        else:
            total += v
    return total

if __name__ == "__main__":
    sample = "XIX"
    print(task_4(sample))  # -> 19
    pass


def task_5(array: List[int]) -> int:
    if not array:
        raise ValueError("array must not be empty")
    smallest = array[0]
    for x in array[1:]:
        if x < smallest:
            smallest = x
    return smallest

if __name__ == "__main__":
    sample = [3, 4, -1, 10, 12]
    print(task_5(sample))
    pass