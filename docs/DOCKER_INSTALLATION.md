# Docker Installation Guide

Kind requires Docker to run Kubernetes clusters. Here's how to install it.

## Windows

### Option 1: Docker Desktop (Recommended)

1. **Download Docker Desktop**
   - Go to: https://www.docker.com/products/docker-desktop/
   - Download Docker Desktop for Windows

2. **Install Docker Desktop**
   - Run the installer
   - Enable WSL2 backend during installation
   - Restart your computer if prompted

3. **Configure Docker Desktop**
   - Start Docker Desktop
   - Go to Settings → General
   - ✅ Enable "Use the WSL 2 based engine"
   - Go to Settings → Resources → WSL Integration
   - ✅ Enable integration with your WSL2 distro (e.g., Ubuntu)
   - Click "Apply & Restart"

4. **Verify Installation**
   ```powershell
   # In PowerShell
   docker version
   docker ps
   ```

   ```bash
   # In WSL
   docker version
   docker ps
   ```

### Option 2: Docker Engine in WSL2 (Advanced)

If you prefer not to use Docker Desktop:

1. **Install Docker in WSL2 Ubuntu**
   ```bash
   # Update packages
   sudo apt-get update
   
   # Install prerequisites
   sudo apt-get install -y \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   
   # Add Docker's official GPG key
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   
   # Set up stable repository
   echo \
     "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   
   # Install Docker Engine
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   
   # Add your user to docker group
   sudo usermod -aG docker $USER
   
   # Start Docker
   sudo service docker start
   ```

2. **Auto-start Docker in WSL2**
   
   Add to `~/.bashrc` or `~/.zshrc`:
   ```bash
   # Start Docker daemon if not running
   if ! pgrep dockerd > /dev/null; then
       sudo service docker start
   fi
   ```

3. **Verify Installation**
   ```bash
   docker version
   docker ps
   ```

## Linux (Native)

### Ubuntu/Debian

```bash
# Update packages
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Log out and back in for group changes to take effect
```

### Fedora/RHEL/CentOS

```bash
# Install dnf-plugins-core
sudo dnf -y install dnf-plugins-core

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
```

## Verification

After installation, verify Docker is working:

```bash
# Check version
docker version

# Check Docker is running
docker ps

# Run test container
docker run hello-world
```

You should see:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Troubleshooting

### WSL: Cannot connect to Docker daemon

**Problem:** `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`

**Solution:**
1. Ensure Docker Desktop is running (Windows)
2. Check WSL integration is enabled in Docker Desktop settings
3. Or start Docker service in WSL: `sudo service docker start`

### Permission denied

**Problem:** `Got permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

### Docker Desktop not starting on Windows

**Problem:** Docker Desktop won't start or shows errors

**Solution:**
1. Ensure Hyper-V and WSL2 are enabled
2. Update Windows to latest version
3. Enable virtualization in BIOS
4. Run: `wsl --update`

### WSL2 not installed

**Problem:** Docker Desktop requires WSL2

**Solution:**
```powershell
# In PowerShell (Admin)
wsl --install
wsl --set-default-version 2

# Restart computer
```

## Next Steps

Once Docker is installed and running:

1. **Verify Docker works in WSL**
   ```bash
   wsl docker ps
   ```

2. **Continue with Kind cluster setup**
   ```bash
   # In WSL
   cd /mnt/c/s/GitHub/KubeCompass
   ./kind/create-cluster.sh cilium
   ```

3. **Install Cilium**
   ```bash
   # Install Cilium CLI (optional but recommended)
   CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
   curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz{,.sha256sum}
   sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
   sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
   rm cilium-linux-amd64.tar.gz{,.sha256sum}
   
   # Install Cilium in cluster
   cilium install
   ```

## Resources

- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker in WSL2](https://docs.docker.com/desktop/wsl/)
- [Kind Prerequisites](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries)

---

**Recommendation for Windows users:** Use Docker Desktop for the best WSL2 integration experience.
