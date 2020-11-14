#!/bin/sh
ANSIBLE_SSH_CONTROLPATH="${1}"
ANSIBLE_SSH_HOSTNAME="${2}"
for SSH_CONTROLPATH_OPTION in ${ANSIBLE_SSH_CONTROLPATH}; do 
   if [ -S ${SSH_CONTROLPATH_OPTION} ]; then
		ssh -O exit -o ControlPath=${SSH_CONTROLPATH_OPTION} ${ANSIBLE_SSH_HOSTNAME}
		count=0
		while (true); do 
			if [ ${count} -gt 5 ]; then
				echo "ERROR: Failed to wait for ssh multiplexer to stop: ${SSH_CONTROLPATH_OPTION} still exists"; \
				exit 32
			else 
				if [ -S ${SSH_CONTROLPATH_OPTION} ]; then 
					count=$((count+1))
					sleep 1
				else 
					break
				fi
			fi
		done
   else
		echo "INFO: no ansible ssh control path at ${SSH_CONTROLPATH_OPTION}"
   fi
done
for SSH_CONTROLPATH_OPTION in ${ANSIBLE_SSH_CONTROLPATH}; do
	if [ -S ${SSH_CONTROLPATH_OPTION} ]; then 
		echo "ERROR: ansible ssh control path option ${SSH_CONTROLPATH_OPTION} still exist: make sure ansible_ssh_ControlPath in posix-users/defaults/main.yml matches control_path settings in ansible.cfg";
	fi;
done;
