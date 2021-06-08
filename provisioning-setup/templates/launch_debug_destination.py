#!/home/admin/venv/bin/python3.7

import asyncio
import sys
import socket

from aiosmtpd.controller import Controller
from aiosmtpd.handlers import Debugging

# Get private IP
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
server_ip = s.getsockname()[0]
s.close()

# Configure port
port = 1025

# Launch Debugging server
handler = Debugging(sys.stdout)
controller = Controller(handler=handler, hostname=server_ip, port=port)
controller.start()
print(f"Running SMTP Debug Server on destination: ({server_ip}:{port})")
print("Waiting for emails...")
asyncio.get_event_loop().run_forever()
