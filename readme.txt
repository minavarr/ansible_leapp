IMPORTANT: 

- Currently the missing metadata is NOT included and must be included seperately in the ~/files directory if the client systems have no access to the public internet. Review the logic around this step and adjust according to your use case.

- These are guidelines, we wouldn't expect this to work without modification everywhere. Adjustment will be necessary depending on the environment.

This is a collection of Ansible playbooks intended to upgrade a baseline RHEL 7.9 system to RHEL 8.6 utilizing LEAPP, an Ansible control node and Satellite. The playbooks are grouped into "*_task_only.yaml" varieties intended to be run with the "master.yaml" playbook. The remaining playbooks are standalone versions of the various tasks.

Instructions for use:

1) Ensure the following variables are set:

     ~/ansible_leapp/ansible.cfg

        [defaults]
        inventory = inventory
        remote_user = <username_here>
        executable = /bin/bash
        use_persistent_connections = true

        [privilege_escalation]
        become_allow_same_user = true

2) Ensure you populate your Inventory file with the adequate entries for the servers you are attempting to LEAPP upggrade. This should be located at:

    ~/ansible_leapp/inventory

3) You will need to SSH to each of the machines from the control node manually in order to accept the various RSA tokens if this has never been done before with the intended upgrade user.

4) The process is intentionally grouped into 3 stages: pre-upgrade, upgrade and post-upgrade. Adjust the inventory file and hosts entries as necessary. Please carefully review the information presented at each interval before proceeding.

The 3 stages are called with the following commands on the control node:

    a) ansible-playbook -k master.yaml --tags "recommended_step_1"
    b) ansible-playbook -k master.yaml --tags "recommended_step_2"
    c) ansible-playbook -k master.yaml --tags "recommended_step_3"

Logs for the LEAPP upgrade process can be located at /var/log/leapp on each server that is being upgraded along with the answerfile required by the process if it has been generated.

It is important to remember that these playbooks are generated against a vanilla baseline image of RHEL 7.9. Please review the output from the preupgrade assesment carefully to help determine how it may affect your running applications and custom packages.

Overview of Stage tasks:

    1) Pre-Upgrade:
        Automatic Remediation:
        a) OS version check
        b) Check for pata_acpi
        c) Remove pata_acpi kernel module if found
        d) Check for correct permit_root_login entry in /etc/ssh/sshd_config
        e) Add appropriate permit_root_login if necessary
        f) Check for correct permit_root_login entry in /etc/ssh/sshd_config
        g) Restart sshd if changes were made to sshd_config
        h) Check for the existence of an answerfile
        i) Prompt to review answerfile if it exists or create an appropriate baseline one if it doesn't.

        Preparation:
        a) OS version check
        b) Enable RHEL 7 repositories
        c) Unset the release version in subscription-manager
        d) Update the OS
        e) Reboot the system (if updates applied)
        f) Install LEAPP packages
        g) Check for metadata directory and appropriate answerfile
        h) Create directory for metadata if missing
        i) Copy the metadata over if missing
        j) Second check for appropriate answerfile
        k) Run leapp preupgrade assesment

    2) Upgrade:
        a) OS version check
        b) Run leap upgrade
        c) Prune /var/lib/sss/db/*.ldb
        d) Reboot system

    3) Post-Upgrade:
        a) OS version check
        b) Set alternatives python3 > /usr/bin/python
        c) Set SELinux to enforcing
        d) Remove el7 packages
        e) Remove remaining LEAPP packages
        f) Remove exclude packages from /etc/dnf/dnf.conf
        g) Enable Satellite Client Tools Repository for RHEL 8
        h) Install katello-agent
        i) Reboot system (to apply SELinux policy)
