import os
import random

serials_path = os.path.join(os.path.dirname(__file__), 'serials.txt')
if os.path.exists(serials_path):
    with open(serials_path, 'r') as serials:
        existings = set(serials.read().split())
else:
    existings = set()

while True:
    sample = random.sample('ABCDEF', 4)
    result = f"9{random.randint(4, 9)}{sample[0]}{sample[1]}-{sample[2]}{random.randint(1, 9)}{sample[3]}{random.randint(1, 9)}"

    if result not in existings:
        break

with open(serials_path, 'a') as serials:
    serials.write(f"{result}\n")

print(f"Successfully Generated: {result}")
