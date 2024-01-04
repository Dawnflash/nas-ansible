MITOGEN_VERSION=0.3.4
PIP_DEPS='ansible<7' passlib
PIP_CMD=pip3 -q --disable-pip-version-check

all: deps test

down:
	vagrant halt

up: mkdisk
	vagrant up --no-provision

test: up
	vagrant provision

mkdisk:
	test -f .vagrant/test_zdisk.vdi || VBoxManage createmedium disk --filename .vagrant/test_zdisk.vdi --size 1024

rmdisk:
	VBoxManage closemedium disk .vagrant/test_zdisk.vdi --delete

destroy: down
	vagrant destroy

recreate: destroy up
reload: down up

deps:
	${PIP_CMD} install --upgrade ${PIP_DEPS}
	ansible-galaxy install -r requirements.yml
	test -d ~/.ansible/mitogen-${MITOGEN_VERSION} || curl -sSL https://github.com/mitogen-hq/mitogen/archive/refs/tags/v${MITOGEN_VERSION}.tar.gz | tar xz -C ~/.ansible
	ln -sfn mitogen-${MITOGEN_VERSION} ~/.ansible/mitogen-current

ssh:
	vagrant ssh

deploy-local:
	ansible-playbook -l nas.local -i inventories/nas/inventory.yml nas.yml

deploy:
	ansible-playbook -l nas -i inventories/nas/inventory.yml nas.yml
