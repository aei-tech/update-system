# update-system

Script to update all packages, including snap and flatpak, on the distribution on which the script is executed.
It searches for the files /etc/lsb-release or (if not available) /etc/os-release and greps for the OS in the file. Based on that, the commands belonging to update the system are executed.

## Execution

- Script has to executed without additional parameters and as nun root user

```bash

python3 ./update-system.py

```

- sudo is used for privilege escalation
-- if needed change variable PRIVILEGE from sudo to any other
