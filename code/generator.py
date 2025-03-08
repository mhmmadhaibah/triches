import os
import random

file_name = 'serials.txt'
file_path = os.path.join(os.path.dirname(__file__), file_name)

if os.path.exists(file_path):
    with open(file_path, 'r') as file:
        existing_serials = set(file.read().splitlines())
else:
    existing_serials = set()

while True:
    shuffled = random.sample('ABCDEF', 4)
    response = f"9{random.randint(4, 9)}{shuffled[0]}{shuffled[1]}-{shuffled[2]}{random.randint(1, 9)}{shuffled[3]}{random.randint(1, 9)}"

    if response not in existing_serials:
        break

with open(file_path, 'a') as file:
    file.write(response + '\n')

print(f"Successfully Generated: {response}")
