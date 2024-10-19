# Docker Installation Script

This script automates the installation of Docker-CE, Docker-Compose, NGinX Proxy Manager, Navidrome, Speedtest, and Portainer-CE on various Linux distributions.

## Supported Operating Systems

- CentOS 7 and 8
- Debian 10/11/12 (Buster / Bullseye / Bookworm)
- Ubuntu 18.04 (Bionic)
- Ubuntu 20.04 / 21.04 / 22.04 (Focal / Hirsute / Jammy)
- Arch Linux

## Prerequisites

- Ensure you have `whiptail` installed for the menu interface.
- The script requires `sudo` privileges to install packages and manage services.

## Features

- **Docker-CE**: Installs Docker Community Edition.
- **Docker-Compose**: Installs Docker Compose for managing multi-container Docker applications.
- **NGinX Proxy Manager**: Sets up a reverse proxy with a user-friendly interface.
- **Navidrome**: Installs a self-hosted music server.
- **Speedtest**: Sets up a recurring internet speed test with Grafana visualization.
- **Portainer-CE**: Installs a web-based Docker management interface.

## Usage

1. Clone the repository or download the `dockerscripts.sh` file.
2. Make the script executable:
   ```bash
   chmod +x dockerscripts.sh
   ```
3. Run the script:
   ```bash
   ./dockerscripts.sh
   ```
4. Follow the on-screen instructions to select your operating system and the applications you wish to install.

## Installation Process

- The script will detect your operating system and prompt you to select the applications you want to install.
- It checks for existing installations of Docker and Docker-Compose and skips installation if they are already present.
- For each selected application, the script will download necessary files and configure the system accordingly.

## Notes

- Ensure your system is up-to-date before running the script.
- You may need to log out and back in to apply changes to user groups (e.g., adding the user to the Docker group).

## Troubleshooting

- Check the `~/docker-script-install.log` file for detailed logs if you encounter any issues during installation.

## License

This script is open-source and available under the MIT License. Feel free to modify and distribute it as needed.
