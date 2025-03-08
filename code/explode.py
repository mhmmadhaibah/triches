import builtins
import ctypes
import os
import psutil
import time

# Override
def print(*args, sep=" ", end="\n", file=None, flush=False, delay=None):
    builtins.print(*args, sep=sep, end=end, file=file, flush=flush); delay and time.sleep(delay)

def procid(process_name):
    for proc in psutil.process_iter(['pid', 'name']):
        if proc.info['name'] == process_name:
            return proc.pid
    return None

def inject(handle, address, string, length):
    buffer = ctypes.create_string_buffer(string, length)
    wbytes = ctypes.c_size_t(0)

    if ctypes.windll.kernel32.WriteProcessMemory(handle, address, buffer, len(buffer), ctypes.byref(wbytes)):
        return wbytes.value
    return None

def expose(handle, address, length):
    buffer = ctypes.create_string_buffer(length)
    rbytes = ctypes.c_size_t(0)

    if ctypes.windll.kernel32.ReadProcessMemory(handle, address, buffer, len(buffer), ctypes.byref(rbytes)):
        return buffer.raw[:rbytes.value].decode(errors='ignore')
    return None

def explode(process_name, targets_path):
    pid = procid(process_name)
    if pid is None:
        print("FAIL! Process not found.")
        return

    handle = ctypes.windll.kernel32.OpenProcess(0x1F0FFF, False, pid)
    with open(targets_path, 'r') as targets:
        for target in targets:
            try:
                parts = target.split()
                if '):' not in target or len(parts) < 2:
                    print(f"FAIL! Invalid format: {repr(target)}.", delay=0.5)
                    continue

                address, length = int(parts[0], 16), int(parts[1].strip(':()'))
                if length < 1:
                    print(f"FAIL! Invalid length: {repr(target)}.", delay=0.5)
                    continue

                number = (inject(handle, address, (b"\x00" * length), length) or 0)
                string = (expose(handle, address, length) or '').replace('\x00', '')

                colour = {number < length: '93', number < 1: '91'}.get(True, '92')
                print(f"\033[{colour}mOK! Memory cleared at address {hex(address)} ({number}/{length}): {repr(string)}.\033[0m")
            except ValueError as e:
                print(f"FAIL! Error parsing {repr(target)}: {e}.", delay=0.5)
            except Exception as e:
                print(f"FAIL! Error processing {repr(target)}: {e}.", delay=0.5)

    ctypes.windll.kernel32.CloseHandle(handle)

if __name__ == "__main__":
    process_name = "PointBlank.exe"
    targets_path = os.path.join(os.path.dirname(__file__), "targets.txt")

    explode(process_name, targets_path)
