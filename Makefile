all: deps up test

up:
	VAGRANT_EXPERIMENTAL=disks vagrant up

down:
	vagrant halt

test:
	vagrant provision

deps:
	ansible-galaxy install -r requirements.yml

ssh:
	vagrant ssh
