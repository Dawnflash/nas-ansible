all: deps test

down:
	vagrant halt

up: mkdisk
	vagrant up --no-provision

test: mkdisk
	vagrant up --provision

mkdisk:
	test -f .vagrant/test_zdisk.vdi || VBoxManage createmedium disk --filename .vagrant/test_zdisk.vdi --size 1024

rmdisk:
	VBoxManage closemedium disk .vagrant/test_zdisk.vdi --delete

destroy: down
	vagrant destroy

recreate: destroy up
reload: down up

deps:
	ansible-galaxy install -r requirements.yml

ssh:
	vagrant ssh
