{
    "hostname": "v12n-photon4",
    "password":
        {
            "crypted": false,
            "text": "${admin_password}"
        },
    "disk": "/dev/sda",
    "partitions": [
                        {"mountpoint": "/", "size": 0, "filesystem": "ext4"},
                        {"mountpoint": "/boot", "size": 128, "filesystem": "ext4"},
                        {"mountpoint": "/root", "size": 128, "filesystem": "ext4"},
                        {"size": 128, "filesystem": "swap"}
                    ],
    "bootmode": "efi",
    "packages": [
        "minimal",
        "linux",
        "initramfs",
        "sudo",
        "vim",
        "cloud-utils",
        "openssl-c_rehash"
    ],
    "postinstall": [
        "#!/bin/sh",
        "useradd -m -G sudo ${build_username}",
        "echo \"${build_username}:${build_password}\" | chpasswd",
        "echo \"${build_username}  ALL=(ALL)  NOPASSWD:SETENV: ALL\" >> /etc/sudoers.d/${build_username}",
        "chage -I -1 -m 0 -M 99999 -E -1 ${admin_username}",
        "chage -I -1 -m 0 -M 99999 -E -1 ${build_username}",
        "iptables -A INPUT -p tcp --dport 22 -j ACCEPT",
        "iptables -A INPUT -p ICMP -j ACCEPT",
        "iptables -A OUTPUT -p ICMP -j ACCEPT",
        "iptables-save > /etc/systemd/scripts/ip4save",
        "systemctl restart iptables",
        "sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config",
        "systemctl restart sshd.service"
    ],
    "linux_flavor": "linux",
    "network": {
        "type": "dhcp"
    }    
}