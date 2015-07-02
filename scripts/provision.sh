# Download extra packages to permanent storage
tce-load -w bash.tcz rsync.tcz
sudo cp -R /mnt/sda1/tmp/tce/optional /var/lib/boot2docker/tce

# bootsync.sh
cat <<'SCRIPT' | sudo tee /var/lib/boot2docker/bootsync.sh
# vagrant key
sudo rm -f /home/docker/.ssh/authorized_keys2
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" | sudo tee -a /home/docker/.ssh/authorized_keys

# install extra packages
sudo su -c "tce-load -i /var/lib/boot2docker/tce/*.tcz" docker


# docker-compose
sudo cp -f /var/lib/boot2docker/bin/docker-compose /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
SCRIPT
sudo chmod +x /var/lib/boot2docker/bootsync.sh

# Disable DOCKER_TLS
sudo  sed -i 's/DOCKER_TLS=.*/DOCKER_TLS=no/' /var/lib/boot2docker/profile
sudo  sed -i 's/2376/2375/' /var/lib/boot2docker/profile