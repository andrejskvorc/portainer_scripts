To install Portainer you can use `wget` or `curl` to download the script from GitHub and then run it. Here's the process using `wget`:

```bash
sudo apt update
sudo apt install -y wget
wget -O - https://raw.githubusercontent.com/andrejskvorc/portainer_scripts/main/portainer_install.sh
chmod +x portainer_install.sh
sudo ./portainer_install.sh
```

If you prefer using `curl`, follow these steps:

```bash
sudo apt update
sudo apt install -y curl
curl https://raw.githubusercontent.com/andrejskvorc/portainer_scripts/main/portainer_install.sh
chmod +x portainer_install.sh
sudo ./portainer_install.sh
```

Both sets of commands will first update the package list and install the respective tool (`wget` or `curl`). Then, they will download the script from the provided URL, make it executable, and finally run the script.



To install Agent or Edge Agent you can use `wget` or `curl` to download the script from GitHub and then run it. Here's the process using `wget`:

```bash
sudo apt update
sudo apt install -y wget
wget https://raw.githubusercontent.com/andrejskvorc/portainer_scripts/main/portainer_node_install.sh
chmod +x portainer_node_install.sh
sudo ./portainer_node_install.sh
```

If you prefer using `curl`, follow these steps:

```bash
sudo apt update
sudo apt install -y curl
curl -O https://raw.githubusercontent.com/andrejskvorc/portainer_scripts/main/portainer_node_install.sh
chmod +x portainer_node_install.sh
sudo ./portainer_node_install.sh
```

Both sets of commands will first update the package list and install the respective tool (`wget` or `curl`). Then, they will download the script from the provided URL, make it executable, and finally run the script.
