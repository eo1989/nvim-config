from capture import capture_locals

def sieve(max: int) -> list[int]:
    numbers = [1] * max
    for i in range(2, int(max**0.5) + 1):
        if numbers[i]:
            for j in range(i*i, max, i):
                numbers[j] = 0

    return [x for x in range(2, max) if numbers[x]]


result, f_locals = capture_locals(sieve)(30)
print("Result:", result)
print("F-locals:", f_locals)

assert f_locals["j"] == 24
