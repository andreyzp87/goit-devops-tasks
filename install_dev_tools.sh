#!/bin/bash


# Function for logging
log() {
  echo -e "[INFO] $1"
}

warn() {
  echo -e "[WARN] $1"
}

error() {
  echo -e "[ERROR] $1"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  error "Please run this script with sudo or as root"
  exit 1
fi

log "Starting installation of development tools..."

# Check and install Docker
if command -v docker &> /dev/null; then
  warn "Docker is already installed. Skipping..."
else
  log "Installing Docker using official installation script..."
  
  # Download and run the official Docker installation script
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  
  # Enable and start Docker service
  systemctl enable docker
  systemctl start docker
  
  # Clean up the installation script
  rm get-docker.sh
  
  log "Docker has been successfully installed"
fi

# Check and install Docker Compose
if command -v docker-compose &> /dev/null; then
  warn "Docker Compose is already installed. Skipping..."
else
  log "Installing Docker Compose..."
  
  # Install Docker Compose
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  
  log "Docker Compose has been successfully installed"
fi

# Check and install Python
PYTHON_VERSION_REQ="3.11"
if command -v python3 &> /dev/null; then
  PYTHON_VERSION_INS=$(python3 -c 'import sys; print(sys.version_info[0], sys.version_info[1], sep=".")')
  # Compare versions using Python itself for simplicity
  if python3 -c "import sys; exit(0 if sys.version_info >= (${PYTHON_VERSION_REQ//./, }) else 1)" 2>/dev/null; then
    warn "Python $PYTHON_VERSION_INS is already installed. Skipping..."
  else
    warn "Python $PYTHON_VERSION_INS is installed but version $PYTHON_VERSION_REQ or higher is required. Installing..."
    apt-get install -y python3
  fi
else
  log "Installing Python..."
  apt-get install -y python3
  log "Python has been successfully installed"
fi

# Check and install pip
if command -v pip3 &> /dev/null; then
  warn "pip is already installed. Skipping..."
else
  log "Installing pip..."
  apt-get install -y python3-pip
  log "pip has been successfully installed"
fi

# Check and install Django
if python3 -c "import django" &> /dev/null; then
  warn "Django is already installed. Skipping..."
else
  log "Installing Django..."
  apt-get install -y python3-django
  log "Django has been successfully installed via apt"
fi

log "All development tools have been successfully installed!"
log "Docker: $(docker --version)"
log "Docker Compose: $(docker-compose --version)"
log "Python: $(python3 --version)"
log "Django: $(python3 -m django --version)"

exit 0
