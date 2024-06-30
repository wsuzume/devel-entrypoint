# devel-entrypoint
Docker container entrypoint for development environment.

This startup script allows you to run commands as a specified user by defining the user's information in environment variables when executing commands such as docker container run.

This script is inspired by the official Jupyter startup script and reuses some of its code, but it includes the following improvements:

* The only change made to the container is creating init.sh in /usr/local/bin.
* It can be easily installed in the container via the Dockerfile.
* The specified user will be used if it already exists in the container, and will only be created if it does not exist.

This script is only compatible with Debian-based base images.

# Install
Simply add the following script to the `Dockerfile` of the image where you want to add the user switching functionality:

```Dockerfile
RUN git clone https://github.com/wsuzume/devel-entrypoint.git \
    && cd devel-entrypoint \
    && /bin/bash install.sh
```

However, to run the above script, `git` and `ca-certificates` are required, and `sudo` is needed to execute `init.sh`. If these tools are not installed, add the following script beforehand:

```Dockerfile
RUN apt-get update --yes \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends \
        sudo git ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
```

Refer to the `example` folder for an installation example.

# Usage
To enable the functionality, the user running the container must be root. Then, specify the following environment variables when starting the Docker container.

| Environment Variable | Function | Default Value |
| :---: | :---: | :---: |
| `INIT_USER` | User name | `morgan` |
| `INIT_UID` | User ID | `1000` |
| `INIT_GROUP` | Group name | (Same as `INIT_USER` if a non-existent GID is specified) |
| `INIT_GID` | Group ID | `100` |
| `GRANT_SUDO` | Grant sudo privileges (added if "yes" or "1") | - |

For example, if you want to start with the same user ID and group ID as the host, try running the following command:

```
docker container run -it --rm -e INIT_UID=`id -u` -e INIT_GID=`id -g` your_image init.sh
```

If you have any commands you want to run, append them after `init.sh`. For example, if you run the following command, you should get an output like this:

```
$ docker container run -it --rm -e INIT_UID=`id -u` -e INIT_GID=`id -g` your_image init.sh id
Entered init.sh with args: id
Create specified group: 'morgan' (5000)
Create specified user: 'morgan' (5000)
Running as morgan: id
uid=5000(morgan) gid=5000(morgan) groups=5000(morgan),100(users)
```