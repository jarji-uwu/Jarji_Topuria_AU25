from itertools import product
from collections import defaultdict

# Task 1
def task_1(d1, d2):
    result = d1.copy()
    for k, v in d2.items():
        result[k] = result.get(k, 0) + v
    return result



# Task 2
def task_2():
    return {i: i * i for i in range(1, 16)}


# Task 3
def task_3(d):
    return [''.join(p) for p in product(*d.values())]


# Task 4
def task_4(d):
    if not d:
        return []
    return [k for k, _ in sorted(d.items(), key=lambda x: x[1], reverse=True)[:3]]


# Task 5
def task_5(pairs):
    result = defaultdict(list)
    for k, v in pairs:
        result[k].append(v)
    return dict(result)


# Task 6 (Optional)
def task_6(lst):
    seen = set()
    result = []
    for x in lst:
        if x not in seen:
            seen.add(x)
            result.append(x)
    return result


# Task 7
def task_7(strs):
    if not strs:
        return ""
    prefix = strs[0]
    for s in strs[1:]:
        while not s.startswith(prefix):
            prefix = prefix[:-1]
            if not prefix:
                return ""
    return prefix


# Task 8
def task_8(haystack, needle):
    if needle == "":
        return 0
    return haystack.find(needle)
