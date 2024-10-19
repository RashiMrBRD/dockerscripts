#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

installApps()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about OS Selection
    echo "We can install Docker-CE, Docker-Compose, NGinX Proxy Manager, and Portainer-CE."
    echo "Please select 'y' for each item you would like to install."
    echo "NOTE: Without Docker you cannot use Docker-Compose, NGinx Proxy Manager, or Portainer-CE."
    echo "       You also must have Docker-Compose for NGinX Proxy Manager to be installed."
    echo ""
    echo ""

    # Use whiptail to select the OS
    OS=$(whiptail --title "OS Selection" --menu "Choose your OS / distro:" 15 60 6 \
    "1" "CentOS 7 and 8" \
    "2" "Debian 10/11/12 (Buster / Bullseye / Bookworm)" \
    "3" "Ubuntu 18.04 (Bionic)" \
    "4" "Ubuntu 20.04 / 21.04 / 22.04 (Focal / Hirsute / Jammy)" \
    "5" "Arch Linux" \
    "6" "End this Installer" 3>&1 1>&2 2>&3)

    case $OS in
        1) echo "CentOS 7 and 8 selected";;
        2) echo "Debian 10/11/12 selected";;
        3) echo "Ubuntu 18.04 selected";;
        4) echo "Ubuntu 20.04 / 21.04 / 22.04 selected";;
        5) echo "Arch Linux selected";;
        6) exit ;;
        *) echo "Invalid selection, please try again..." ;;
    esac

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Docker-CE (y/n): " DOCK
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Docker-Compose (y/n): " DCOMP
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

    read -rp "NGinX Proxy Manager (y/n): " NPM
    read -rp "Navidrome (y/n): " NAVID
    read -rp "Speedtest - recurring internet speedtest (y/n): " SPDTST
    read -rp "Portainer-CE (y/n): " PTAIN

    if [[ "$PTAIN" == [yY] ]]; then
        echo ""
        echo ""
        PS3="Please choose either Portainer-CE or just Portainer Agent: "
        select _ in \
            " Full Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
            " Portainer Agent - Remote Agent to Connect from Portainer-CE" \
            " Nevermind -- I don't need Portainer after all."
        do
            PORT="$REPLY"
            case $REPLY in
                1) startInstall ;;
                2) startInstall ;;
                3) startInstall ;;
                *) echo "Invalid selection, please try again..." ;;
            esac
        done
    fi
    
    startInstall
}

checkDependencies() {
    echo -e "${CYAN}Checking for required dependencies...${RESET}"
    REQUIRED_PKG=("apt-transport-https" "ca-certificates" "curl" "gnupg" "lsb-release")
    for pkg in "${REQUIRED_PKG[@]}"; do
        if ! dpkg -l | grep -q "$pkg"; then
            echo -e "${YELLOW}Installing missing package: $pkg${RESET}"
            sudo apt-get install -y "$pkg" >> ~/docker-script-install.log 2>&1
        else
            echo -e "${GREEN}Package $pkg is already installed.${RESET}"
        fi
    done
}

show_progress() {
    local duration=$1
    local interval=1
    local elapsed=0
    local progress=0

    while [ $elapsed -lt $duration ]; do
        sleep $interval
        elapsed=$((elapsed + interval))
        progress=$(( (elapsed * 100) / duration ))
        printf "\rProgress: [%-50s] %d%%" $(printf "%0.s#" $(seq 1 $((progress / 2)))) $progress
    done
    printf "\n"
}

startInstall() 
{
    clear
    echo -e "${BLUE}#######################################################${RESET}"
    echo -e "${BLUE}###         Preparing for Installation              ###${RESET}"
    echo -e "${BLUE}#######################################################${RESET}"
    echo ""
    sleep 3s

    # Example usage of the progress bar
    echo "Starting installation process..."
    show_progress 10  # Simulate a 10-second task
    echo "Installation process completed."

    #######################################################
    ###           Install for Debian / Ubuntu           ###
    #######################################################

    if [[ "$OS" != "1" ]]; then
        checkDependencies  # Call the function to check dependencies

        echo -e "${YELLOW}    1. Installing System Updates... this may take a while...be patient.${RESET}"
        (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        # echo "    2. Install Prerequisite Packages..."
        # sleep 2s

        # sudo apt install apt-transport-https ca-certificates curl software-properties-common -y >> ~/docker-script-install.log 2>&1

        # if [[ "$DOCK" == [yY] ]]; then
        #     echo "    3. Retrieving Signing Keys for Docker... and adding the Docker-CE repository..."
        #     sleep 2s

        #     #### add the Debian 10 Buster key
        #     if [[ "$OS" == 2 ]]; then
        #         curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - >> ~/docker-script-install.log 2>&1
        #         sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" -y >> ~/docker-script-install.log 2>&1
        #     fi

        #     if [[ "$OS" == 3 ]] || [[ "$OS" == 4 ]]; then
        #         curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> ~/docker-script-install.log 2>&1

        #         sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y >> ~/docker-script-install.log 2>&1
        #     fi

        #     sudo apt update >> ~/docker-script-install.log 2>&1
        #     sudo apt-cache policy docker-ce >> ~/docker-script-install.log 2>&1

            echo "    2. Installing Docker-CE (Community Edition)..."
            sleep 2s

            #sudo apt install docker-ce -y >> ~/docker-script-install.log 2>&1

            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

                echo "- docker-ce version is now:"
            docker -v
            sleep 5s

            if [[ "$OS" == 2 ]]; then
                echo -e "${YELLOW}    3. Retrieving Signing Keys for Docker... and adding the Docker-CE repository...${RESET}"
                sleep 2s

                # Add the Debian 12 Bookworm key
                curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - >> ~/docker-script-install.log 2>&1
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" -y >> ~/docker-script-install.log 2>&1

                sudo apt update >> ~/docker-script-install.log 2>&1
                sudo apt-cache policy docker-ce >> ~/docker-script-install.log 2>&1
            fi
        # fi
    fi
        
    
    #######################################################
    ###              Install for CentOS 7 or 8          ###
    #######################################################
    if [[ "$OS" == "1" ]]; then
        if [[ "$DOCK" == [yY] ]]; then
            echo "    1. Updating System Packages..."
            sudo yum check-update >> ~/docker-script-install.log 2>&1

            echo "    2. Installing Docker-CE (Community Edition)..."

            sleep 2s
            (curl -fsSL https://get.docker.com/ | sh) >> ~/docker-script-install.log 2>&1

            echo "    3. Starting the Docker Service..."

            sleep 2s


            sudo systemctl start docker >> ~/docker-script-install.log 2>&1

            echo "    4. Enabling the Docker Service..."
            sleep 2s

            sudo systemctl enable docker >> ~/docker-script-install.log 2>&1
        fi
    fi

    #######################################################
    ###               Install for Arch Linux            ###
    #######################################################

    if [[ "$OS" == "5" ]]; then
        read -rp "Do you want to install system updates prior to installing Docker-CE? (y/n): " UPDARCH
        if [[ "UPDARCH" == [yY] ]]; then
            echo "    1. Installing System Updates... this may take a while...be patient."
            (sudo pacman -Syu) > ~/docker-script-install.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        else
            echo "    1. Skipping system update..."
            sleep 2s
        fi

        echo "    2. Installing Docker-CE (Community Edition)..."
            sleep 2s

            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

            echo "    - docker-ce version is now:"
            docker -v
            sleep 5s
    fi

    if [[ "$DOCK" == [yY] ]]; then
        # add current user to docker group so sudo isn't needed
        echo ""
        echo "  - Attempting to add the currently logged in user to the docker group..."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo "  - You'll need to log out and back in to finalize the addition of your user to the docker group."
        echo ""
        echo ""
        sleep 3s
    fi

    if [[ "$DCOMP" = [yY] ]]; then
        echo "############################################"
        echo "######     Install Docker-Compose     ######"
        echo "############################################"

        # install docker-compose
        echo ""
        echo "    1. Installing Docker-Compose..."
        echo ""
        echo ""
        sleep 2s

        ######################################
        ###     Install Debian / Ubuntu    ###
        ######################################        
        
        if [[ "$OS" != "1" ]]; then
            sudo apt install docker-compose -y >> ~/docker-script-install.log 2>&1
        fi

        ######################################
        ###        Install CentOS 7        ###
        ######################################

        if [[ "$OS" == "1" ]]; then
            sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> ~/docker-script-install.log 2>&1

            sudo chmod +x /usr/local/bin/docker-compose >> ~/docker-script-install.log 2>&1
        fi

        echo ""

        echo "- Docker Compose Version is now: " 
        docker-compose --version
        echo ""
        echo ""
        sleep 3s
    fi

    ##########################################
    #### Test if Docker Service is Running ###
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo "Giving the Docker service time to start..."
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

    if [[ "$NPM" == [yY] ]]; then
        echo "##########################################"
        echo "###     Install NGinX Proxy Manager    ###"
        echo "##########################################"
    
        # pull an nginx proxy manager docker-compose file from github
        echo "    1. Pulling a default NGinX Proxy Manager docker-compose.yml file."

        mkdir -p docker/nginx-proxy-manager
        cd docker/nginx-proxy-manager

        curl https://gitlab.com/bmcgonag/docker_installs/-/raw/main/docker_compose.nginx_proxy_manager.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        echo "    2. Running the docker-compose.yml to install and start NGinX Proxy Manager"
        echo ""
        echo ""

        if [[ "$OS" == "1" ]]; then
          docker-compose up -d
        fi

        if [[ "$OS" != "1" ]]; then
          sudo docker-compose up -d
        fi

        echo ""
        echo ""
        echo "    Navigate to your server hostname / IP address on port 81 to setup"
        echo "    NGinX Proxy Manager admin account."
        echo ""
        echo "    The default login credentials for NGinX Proxy Manager are:"
        echo "        username: admin@example.com"
        echo "        password: changeme"

        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$PORT" == "1" ]]; then
        echo "########################################"
        echo "###      Installing Portainer-CE     ###"
        echo "########################################"
        echo ""
        echo "    1. Preparing to Install Portainer-CE"
        echo ""
        echo ""

        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
        echo ""
        echo ""
        echo "    Navigate to your server hostname / IP address on port 9000 and create your admin account for Portainer-CE"

        echo ""
        echo ""
        echo ""
        sleep 3s
    fi

    if [[ "$PORT" == "2" ]]; then
        echo "###########################################"
        echo "###      Installing Portainer Agent     ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Portainer Agent"

        sudo docker volume create portainer_data
        sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
        echo ""
        echo ""
        echo "    From Portainer or Portainer-CE add this Agent instance via the 'Endpoints' option in the left menu."
        echo "       ####     Use the IP address of this server and port 9001"
        echo ""
        echo ""
        echo ""
        sleep 3s
    fi

    if [[ "$NAVID" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Navidrome         ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Navidrome"

        mkdir -p docker/navidrome
        cd docker/navidrome

        curl https://gitlab.com/bmcgonag/docker_installs/-/raw/main/docker_compose_navidrome.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        echo "    2. Running the docker-compose.yml to install and start Navidrome"
        echo ""
        echo ""

        if [[ "$OS" == "1" ]]; then
          docker-compose up -d
        fi

        if [[ "$OS" != "1" ]]; then
          sudo docker-compose up -d
        fi

        echo ""
        echo ""
        echo "    Navigate to your server hostname / IP address on port 4533 to setup"
        echo "    your new Navidrome admin account."
        echo ""      
        sleep 3s
        cd
    fi

    if [[ "$SPDTST" == [yY] ]]; then
        echo "###########################################"
        echo "###         Installing Speedtest        ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Speedtest"

        mkdir -p docker/docker-speedtest-grafana
        cd docker/docker-speedtest-grafana

        curl https://gitlab.com/bmcgonag/docker_installs/-/raw/main/docker-compose_speedtest_grafana.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        echo "    2. Running the docker-compose.yml to install and start Speedtest"
        echo ""
        echo ""

        if [[ "$OS" == "1" ]]; then
          docker-compose up -d
        fi

        if [[ "$OS" != "1" ]]; then
          sudo docker-compose up -d
        fi

        echo ""
        echo ""
        echo "    Navigate to your server hostname / IP address on port 3030 to view"
        echo "    Speedtest data as it collects over time."
        echo ""      
        sleep 3s
        cd
    fi

    exit 1
}

echo ""
echo ""

clear

# New ASCII art
echo -e "${BLUE}RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H R R A A SSSSSSSS H H${RESET}"
echo -e "${BLUE}  RRRR   AAAAA  SSSS  H   H  III  N   N  SSSS  TTTTT  AAAAA  L     L${RESET}"
echo -e "${BLUE}  R   R  A   A  S     H   H   I   NN  N  S        T    A   A  L     L${RESET}"
echo -e "${BLUE}  RRRR   AAAAA  SSSS  HHHHH   I   N N N   SSSS    T    AAAAA  L     L${RESET}"
echo -e "${BLUE}  R  R   A   A      S H   H   I   N  NN       S    T    A   A  L     L${RESET}"
echo -e "${BLUE}  R   R  A   A  SSSS  H   H  III  N   N  SSSS    T    A   A  LLLLL LLLLL${RESET}"
echo -e "${BLUE}iiii n n sssss ttttt a l i nn n s t a a l i n n n sss t aaaa l i n nn s t a a l iiii n n sssss t a a lllll${RESET}"
echo ""

# New OS detection section
echo -e "${CYAN}Detecting your operating system...${RESET}"
echo -e "${CYAN}----------------------------------${RESET}"
echo -e "${CYAN}OpSys:  $(lsb_release -i | awk -F: '{print $2}' | xargs)${RESET}"
echo -e "${CYAN}Desc:   $(lsb_release -d | awk -F: '{print $2}' | xargs)${RESET}"
echo -e "${CYAN}OSVer:  $(lsb_release -r | awk -F: '{print $2}' | xargs)${RESET}"
echo -e "${CYAN}CdNme:  $(lsb_release -c | awk -F: '{print $2}' | xargs)${RESET}"
echo ""

echo -e "${BLUE}------------------------------------------------${RESET}"
echo ""
echo "Please press Enter to continue and select the OS / distro you want to install it with."
read -rp "Press Enter to continue..."  # Wait for user to press Enter

installApps() {
    clear
    OS="$REPLY" ## <-- This $REPLY is about OS Selection
    echo "We can install Docker-CE, Docker-Compose, NGinX Proxy Manager, and Portainer-CE."
    echo "Please select 'y' for each item you would like to install."
    echo "NOTE: Without Docker you cannot use Docker-Compose, NGinx Proxy Manager, or Portainer-CE."
    echo "       You also must have Docker-Compose for NGinX Proxy Manager to be installed."
    echo ""
    echo ""

    # Use whiptail to select the OS
    OS=$(whiptail --title "OS Selection" --menu "Choose your OS / distro:" 15 60 6 \
    "1" "CentOS 7 and 8" \
    "2" "Debian 10/11/12 (Buster / Bullseye / Bookworm)" \
    "3" "Ubuntu 18.04 (Bionic)" \
    "4" "Ubuntu 20.04 / 21.04 / 22.04 (Focal / Hirsute / Jammy)" \
    "5" "Arch Linux" \
    "6" "End this Installer" 3>&1 1>&2 2>&3)

    case $OS in
        1) echo "CentOS 7 and 8 selected";;
        2) echo "Debian 10/11/12 selected";;
        3) echo "Ubuntu 18.04 selected";;
        4) echo "Ubuntu 20.04 / 21.04 / 22.04 selected";;
        5) echo "Arch Linux selected";;
        6) exit ;;
        *) echo "Invalid selection, please try again..." ;;
    esac

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Docker-CE (y/n): " DOCK
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Docker-Compose (y/n): " DCOMP
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

    read -rp "NGinX Proxy Manager (y/n): " NPM
    read -rp "Navidrome (y/n): " NAVID
    read -rp "Speedtest - recurring internet speedtest (y/n): " SPDTST
    read -rp "Portainer-CE (y/n): " PTAIN

    if [[ "$PTAIN" == [yY] ]]; then
        echo ""
        echo ""
        PS3="Please choose either Portainer-CE or just Portainer Agent: "
        select _ in \
            " Full Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
            " Portainer Agent - Remote Agent to Connect from Portainer-CE" \
            " Nevermind -- I don't need Portainer after all."
        do
            PORT="$REPLY"
            case $REPLY in
                1) startInstall ;;
                2) startInstall ;;
                3) startInstall ;;
                *) echo "Invalid selection, please try again..." ;;
            esac
        done
    fi
    
    startInstall
}

# Start the installation process
installApps
