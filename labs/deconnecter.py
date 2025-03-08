import glob
import os
import pydirectinput
import pygetwindow
import re
import subprocess
import sys
import threading
import time

# bash: python -m PyInstaller --uac-admin --onefile --optimize=2 --noconsole --disable-windowed-traceback --name=warp-upx --icon=NONE --version-file=version.txt --runtime-tmpdir=C:\\Users\\User\\AppData\\Local\\Cloudflare\\updates\\express --bootloader-ignore-signals --clean deconnecter.py 
# pwsh: (Get-Item C:\Windows\System32\warp-upx.exe).CreationTime = "02/19/2025 16:43:08"; (Get-Item C:\Windows\System32\warp-upx.exe).LastWriteTime = "02/19/2025 16:43:08"; 

def command(args: list):
    subprocess.Popen(
        args,
        shell=False,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW
    )

def fenetre(process_name):
    try:
        window = pygetwindow.getWindowsWithTitle(process_name)[0]
        if window.isMinimized:
            window.restore()

        window.activate()

        time.sleep(2)
        pydirectinput.press('esc')

        time.sleep(0.2)
        pydirectinput.press('esc')

        print("Window has been restored.")
    except IndexError:
        print("Window not found.")
    except Exception as e:
        print(f"Window processing error: {e}")

def deconnecter(process_name, process_path, ethread):
    try:
        time.sleep(300)
        command(['netsh', 'advfirewall', 'firewall', 'delete', 'rule', f"name={process_name}"])

        time.sleep(5)
        command(['netsh', 'advfirewall', 'firewall', 'add', 'rule', f"name={process_name}", 'dir=IN',  f"program={process_path}", 'action=block'])
        command(['netsh', 'advfirewall', 'firewall', 'add', 'rule', f"name={process_name}", 'dir=OUT', f"program={process_path}", 'action=block'])

        time.sleep(10)
        fenetre(process_name)
        fenetre(re.sub(r"([a-z])([A-Z])|[-_]", r"\1 \2", process_name).title())

        time.sleep(60)
        command(['netsh', 'advfirewall', 'firewall', 'delete', 'rule', f"name={process_name}"])

        time.sleep(5)
        command(['wevtutil', 'cl', 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall'])
    except subprocess.CalledProcessError as e:
        print(f"Command processing error: {e}")
    except Exception as e:
        print(f"Deconnecter processing error: {e}")
    finally:
        ethread.set()

def iteration(ethread):
    prefetch = r"C:\Windows\Prefetch"
    basename = os.path.basename(sys.executable)

    while True:
        files  = glob.glob(os.path.join(prefetch, 'CMD.EXE*'))
        files += glob.glob(os.path.join(prefetch, 'NETSH.EXE*'))
        files += glob.glob(os.path.join(prefetch, 'WEVTUTIL.EXE*'))
        files += glob.glob(os.path.join(prefetch, f"{basename.upper()}*"))

        for file in files:
            try:
                os.remove(file)
                print(f"File deleted: {file}")
            except Exception as e:
                print(f"Could not delete {file}: {e}")

        if ethread.is_set():
            break

        time.sleep(5)

if __name__ == "__main__":
    process_name = "PointBlank"
    process_path = r"C:\Zepetto\PointBlank\PointBlank.exe"

    ethread = threading.Event()

    dthread = threading.Thread(target=deconnecter, args=(process_name, process_path, ethread))
    ithread = threading.Thread(target=iteration, args=(ethread,))

    dthread.start()
    ithread.start()

    dthread.join()
    ithread.join()
