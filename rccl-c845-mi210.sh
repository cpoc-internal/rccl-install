#!/bin/bash
sudo apt update
sudo apt install binutils-dev wget gnupg2 shellinabox build-essential -y
# Create the directory for the key
sudo mkdir --parents --mode=0755 /etc/apt/keyrings

# Download the AMD GPU signing key
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
    gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Add the ROCm 6.x repository (or the specific version you require)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0/ jammy main" \
    | sudo tee /etc/apt/sources.list.d/rocm.list

sudo apt update

sudo apt install rocm-hip-sdk -y
sudo apt install rccl -y

echo 'export PATH=$PATH:/opt/rocm/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib' >> ~/.bashrc
source ~/.bashrc

ls /opt/rocm/lib | grep rccl



# Define the file path
GRUB_FILE="/etc/default/grub"

# Check if the script is being run with sudo/root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi

# 1. Back up the original file just in case
cp "$GRUB_FILE" "$GRUB_FILE.bak"

# 2. Replace the GRUB_CMDLINE_LINUX_DEFAULT line
# This looks for the line starting with the variable and replaces the whole line
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt"/' "$GRUB_FILE"

# 3. Update the GRUB bootloader to apply changes
update-grub

echo "GRUB configuration updated successfully."

git clone https://github.com/ROCm/rccl-tests.git
cd rccl-tests
make MPI=0 HIP_PATH=/opt/rocm
./build/all_reduce_perf -b 8 -e 10g -f 2 -g 4
