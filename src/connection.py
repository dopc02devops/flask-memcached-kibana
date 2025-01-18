import os
from pymemcache.client import base
from logger import setup_logger as logger


class ConnectionManager:
    def __init__(self):
        self.OPERATING_SYSTEM = os.getenv("OPERATING_SYSTEM")
        self.MEMCACHED_HOST = os.getenv("MEMCACHED_HOST")
        self.memcached_client = None

    def connect_to_localhost_memcached(self):
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "docker":
                print("Detected Docker Compose environment.")
                print(f"Operating system: {self.OPERATING_SYSTEM}")
                logger().info(f"Connecting to Memcached at {self.OPERATING_SYSTEM}")

                try:
                    self.memcached_client = base.Client(("127.0.0.1", 11211))
                    logger().info(
                        f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                    print(f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                except Exception as e:
                    logger().error(f"Failed to connect to Memcached: {e}")
                    print(f"Error: {e}")
            else:
                print(f"Unsupported operating system: {self.OPERATING_SYSTEM}")
        else:
            print("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
            logger().warning("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
        return self.memcached_client
    def connect_to_docker_memcached(self):
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "docker":
                print("Detected Docker Compose environment.")
                print(f"Operating system: {self.OPERATING_SYSTEM}")
                logger().info(f"Connecting to Memcached at {self.OPERATING_SYSTEM}")

                try:
                    self.memcached_client = base.Client(("host.docker.internal", 11211))
                    logger().info(
                        f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                    print(f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                except Exception as e:
                    logger().error(f"Failed to connect to Memcached: {e}")
                    print(f"Error: {e}")
            else:
                print(f"Unsupported operating system: {self.OPERATING_SYSTEM}")
        else:
            print("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
            logger().warning("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
        return self.memcached_client

    def connect_to_kubernetes_memcached(self):
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "kubernetes":
                print("Detected Docker Compose environment.")
                print(f"Operating system: {self.OPERATING_SYSTEM}")
                logger().info(f"Connecting to Memcached at {self.OPERATING_SYSTEM}")

                try:
                    self.memcached_client = base.Client((self.MEMCACHED_HOST, 11211))
                    logger().info(
                        f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                    print(f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                except Exception as e:
                    logger().error(f"Failed to connect to Memcached: {e}")
                    print(f"Error: {e}")
            else:
                print(f"Unsupported operating system: {self.OPERATING_SYSTEM}")
        else:
            print("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
            logger().warning("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
        return self.memcached_client

    def connect_to_docker_compose_memcached(self):
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "docker-compose":
                print("Detected Docker Compose environment.")
                print(f"Operating system: {self.OPERATING_SYSTEM}")
                logger().info(f"Connecting to Memcached at {self.OPERATING_SYSTEM}")

                try:
                    self.memcached_client = base.Client((self.MEMCACHED_HOST, 11211))
                    logger().info(
                        f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                    print(f"Successfully connected to {self.OPERATING_SYSTEM}, client is: {self.memcached_client}")
                except Exception as e:
                    logger().error(f"Failed to connect to Memcached: {e}")
                    print(f"Error: {e}")
            else:
                print(f"Unsupported operating system: {self.OPERATING_SYSTEM}")
        else:
            print("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
            logger().warning("OPERATING_SYSTEM is not set. Skipping Memcached connection.")
        return self.memcached_client
