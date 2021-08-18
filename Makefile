all: deps test

up:
	VAGRANT_EXPERIMENTAL=disks vagrant up

down:
	vagrant halt

test: up
	vagrant provision

deps:
	ansible-galaxy install -r requirements.yml

ssh:
	vagrant ssh
