# Ansible setup for a NAS server

Based on Debian.

Uses `ansible-galaxy` resources, run `make deps` to pull them before provisioning anything.

## Testing

Use the provided Makefile if you want.
`make` gets you started from zero, `make test` provisions a running VM.
Current Bullseye Vagrant box is lacking kernel headers and the kernel is outdated so the first provision will fail on ZFS modules.
Just reload and reprovision by `make down test`.

The setup uses a persistent disk to facilitate storage testing. Remove it with `make rmdisk`.

**Do not run vagrant destroy** or you'll lose your persistent disk. Use `make destroy` instead.

If you don't have it populated with a zpool yet, your provisioning will fail on ZFS checks. This is OK.
Reload and SSH in: `make reload ssh` and create your pool and datasets. To pass storage tests, all samba shares defined in [group_vars/nas.yml](group_vars/nas.yml) must be valid.
Storage tasks should pass now.

```
$ zpool create Master sdb
$ zfs create Master/Backup
...
```
