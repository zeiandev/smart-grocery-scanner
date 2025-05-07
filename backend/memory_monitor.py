# memory_monitor.py

import psutil
import threading
import time

# force Git to track this file

def log_memory_usage(interval=10):
    """Logs memory usage in MB at a regular interval."""
    process = psutil.Process()
    while True:
        mem = process.memory_info().rss / 1024 ** 2  # Convert bytes to MB
        print(f"[Memory Monitor] Memory used: {mem:.2f} MB")
        time.sleep(interval)

def start_memory_monitor():
    """Starts the memory logging in a background daemon thread."""
    monitor_thread = threading.Thread(target=log_memory_usage, daemon=True)
    monitor_thread.start()
