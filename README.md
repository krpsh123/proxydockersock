# proxydockersock
Proxy for the docker.sock.

# Why?
To prevent local users from being included in the docker group.

# How?
We will provide each local user with his own docker.sock.
To do this, we will run one instance of this proxy server for each user.

# Help
proxydockersockd -h
```
USAGE:
    this_daemon [OPTION] --to_user user_name
OPTIONS:
    -h    print help and exit
    -v    print version and exit
    -d    debug mode
    -u    user_name (default 'prdocker')
    --docker_sock    path to docker.sock (default '/run/docker.sock')
    --to_user        user_name
        A socket is created using a template /run/docker_[%user_name%].sock
        After starting this daemon, you need to add 'export DOCKER_HOST=unix:///run/docker_[%user_name%].sock' in ~/.bashrc
    --show_acl             show acl for --to_user and exit
    --no_acl               disable acl
    --no_add_all_labels    tell this_daemon not to add any of his own labels.
        By default, labels are added when creating a container, image, volume, or network.
```

# Install
> The installation is described for Debian 12 (Bookworm).
> There should be no problems in other distributions, you just need to replace the package names.

installing dependencies
```sh
apt install lua5.3 lua-cqueues lua-posix lua-penlight lua-dkjson lua-http
```

creating a user from whom the daemon will work
```sh
useradd -r -d /opt/proxydockersock -m -s /sbin/nologin prdocker
```

getting the source code of the daemon (focus on the current release)
```sh
wget -O /tmp/proxydockersock_0.1.0.tar.gz https://github.com/krpsh123/proxydockersock/archive/refs/tags/0.1.0.tar.gz
```

unpacking the source code
```sh
tar -xvzf /tmp/proxydockersock_0.1.0.tar.gz --strip=1 -C /opt/proxydockersock
```

setting the files owner
```sh
chown -R prdocker:prdocker /opt/proxydockersock
```

creating a systemd unit
```sh
cat /opt/proxydockersock/proxydockersock@.service > /etc/systemd/system/proxydockersock@.service
```

# Example deployment for a local user 'larry'
enabling auto start and launching the daemon
```sh
systemctl enable proxydockersock@larry.service && systemctl start proxydockersock@larry.service
```
Now Larry can try
```sh
export DOCKER_HOST=unix:///run/docker_larry.sock && docker ps
```

# TODO
1. Http filtering extension to limit user actions with containers.
2. Creating a label (krpsh123.proxydockersock.owner=%user_name%) when creating a image.
