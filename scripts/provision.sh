#!/bin/sh

# Fail on errors
set -e

# Download extra packages to permanent storage
echo 'http://distro.ibiblio.org/tinycorelinux/' | sudo tee /opt/tcemirror
tce-load -w bash.tcz rsync.tcz
sudo cp -R /mnt/sda1/tmp/tce/optional /var/lib/boot2docker/tce

# Create bin directory for permanent storage of custom binaries
sudo mkdir -p /var/lib/boot2docker/bin
# Create permanent storage directories for host files
sudo mkdir -p /mnt/sda1/Users
sudo mkdir -p /mnt/sda1/cygdrive

# bootsync.sh
cat <<'SCRIPT' | sudo tee /var/lib/boot2docker/bootsync.sh
# vagrant key
sudo rm -f /home/docker/.ssh/authorized_keys2
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" | sudo tee -a /home/docker/.ssh/authorized_keys

# install extra packages
sudo su -c "tce-load -i /var/lib/boot2docker/tce/*.tcz" docker

# symlink custom binaries
sudo chmod -R +x /var/lib/boot2docker/bin
for i in /var/lib/boot2docker/bin/*; do
	sudo chmod +x $i
	sudo ln -sf $i /usr/local/bin/$(basename $i)
done

# This only works for interactive sessions, so using symlinking above instead...
# Add /var/lib/boot2docker/bin to PATH
#echo 'export PATH=/var/lib/boot2docker/bin:$PATH' | sudo tee -a /etc/profile

# Start nfs client utilities
sudo /usr/local/etc/init.d/nfs-client start

# Symlink permanent storage directories for host files
sudo ln -s /mnt/sda1/Users /Users
sudo ln -s /mnt/sda1/cygdrive /cygdrive
SCRIPT
sudo chmod +x /var/lib/boot2docker/bootsync.sh

# Disable DOCKER_TLS and make sure docker listens on 2375 and 2376 ports
sudo sed -i '/DOCKER_TLS=/c DOCKER_TLS=no' /var/lib/boot2docker/profile
sudo sed -i '/DOCKER_HOST=/c DOCKER_HOST="-H tcp://0.0.0.0:2375 -H tcp://0.0.0.0:2376"' /var/lib/boot2docker/profile

# Append Docker IP and DNS configuration to EXTRA_ARGS
sudo sed -i "/EXTRA_ARGS='/a --dns 172.17.42.1 --dns 8.8.8.8" /var/lib/boot2docker/profile
sudo sed -i "/EXTRA_ARGS='/a --bip=172.17.42.1/24" /var/lib/boot2docker/profile

# Enable SFTP		
echo "Subsystem sftp /usr/local/lib/openssh/sftp-server" | sudo tee -a /var/lib/boot2docker/ssh/sshd_config
