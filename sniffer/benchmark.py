import time


class SnifferBenchmark:
    def __init__(self):
        self.start_time = time.time()
        self.packet_count = 0
        self.total_bytes = 0

    def record(self, packet_size: int):
        self.packet_count += 1
        self.total_bytes += packet_size

    def snapshot(self):
        elapsed = max(time.time() - self.start_time, 1e-6)

        return {
            "elapsed_seconds": round(elapsed, 2),
            "packet_count": self.packet_count,
            "total_bytes": self.total_bytes,
            "packets_per_second": round(self.packet_count / elapsed, 2),
            "bytes_per_second": round(self.total_bytes / elapsed, 2),
        }
