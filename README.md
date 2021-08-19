# Ansible setup for a NAS server

Based on Debian.

Uses `ansible-galaxy` resources, run `make deps` to pull them before provisioning anything.

## Testing

Use the provided Makefile if you want.
`make` gets you started from zero, `make test` provisions a VM.

Current Bullseye Vagrant box is lacking kernel headers and the kernel is outdated so the first provision will fail on ZFS modules.
Just reload and reprovision by `make reload test`.

The setup uses a persistent disk to facilitate storage testing. Remove it with `make rmdisk`.

**Do not run `vagrant destroy`** before `vagrant halt` or you'll lose your persistent disk. Use `make destroy` instead.

If you don't have it populated with a zpool yet, your provisioning will fail on ZFS checks. This is OK.
Reload and SSH in: `make reload ssh` and create your pool and datasets. To pass storage tests, all samba shares defined in [group_vars/all.yml](group_vars/all.yml) must be valid mounted ZFS datasets.
Storage tasks should pass afterwards.

```
$ zpool create Master sdb
$ zfs create Master/Backup
...
```
