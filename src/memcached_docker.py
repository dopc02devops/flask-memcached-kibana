import subprocess

# Step 1: Check if memcached is running and find its PID
def check_memcached():
    try:
        result = subprocess.check_output("ps aux | grep memcached", shell=True, text=True)
        print("Current memcached processes:\n", result)
        return result
    except subprocess.CalledProcessError:
        print("No memcached process found.")
        return None


# Step 2: Kill the memcached process if it exists
def kill_memcached():
    output = check_memcached()
    if output:
        # Extract the PID (assuming the PID is the second item in the output)
        lines = output.splitlines()
        for line in lines:
            if 'memcached' in line:
                pid = int(line.split()[1])
                print(f"Killing memcached process with PID {pid}")
                subprocess.run(f"kill {pid}", shell=True, text=True)


# Step 3: Pull the latest Memcached image from Docker Hub
def pull_memcached_image():
    print("Pulling memcached image...")
    subprocess.run("docker pull memcached", shell=True, text=True)


# Step 4: Run Memcached in a Docker container
def run_memcached_container():
    print("Running Memcached container...")
    subprocess.run("docker run -d --name memcached -p 11211:11211 memcached", shell=True, text=True)


# Step 5: List running Docker containers to verify
def list_docker_containers():
    print("Listing running Docker containers...")
    result = subprocess.check_output("docker ps", shell=True, text=True)
    print(result)


if __name__ == "__main__":
    kill_memcached()
    pull_memcached_image()
    run_memcached_container()
    list_docker_containers()
