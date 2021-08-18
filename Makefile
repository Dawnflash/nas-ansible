all: deps test

down:
	vagrant halt

test:
	VAGRANT_EXPERIMENTAL=disks vagrant up --provision

deps:
	ansible-galaxy install -r requirements.yml

ssh:
	vagrant ssh
