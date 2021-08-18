# Ansible setup for a NAS server

Based on Debian.

Uses `ansible-galaxy` resources, run `ansible-galaxy -r requirements.yml` to pull them before provisioning anything.

## Testing

Use Vagrant to test functionality.

Set `VAGRANT_EXPERIMENTAL=disk` when spinning up the VM to get an extra disk to experiment with ZFS/shares upon.
