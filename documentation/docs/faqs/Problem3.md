# c2d2cli container gives an invalid IP Address error

## Problem 
When running c2d2cli, docker gives an invalid IP Address error.
```bash
~/axelar/axelarate-community$ ./c2d2/c2d2cli.sh --version v0.3.0 Copying config.toml to /home/mirrormirage0/.c2d2cli docker: Error response from daemon: invalid IP address in add-host: "host-gateway". See 'docker run --help'
```

## Cause
Docker version is outdated

## Solution
Update docker to version 20 or higher
