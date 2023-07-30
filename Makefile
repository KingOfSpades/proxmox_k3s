all: infra cluster test

infra:
	terraform -chdir=terraform init 
	terraform -chdir=terraform apply

cluster:
	ANSIBLE_CONFIG=ansible/ansible.cfg \
	ansible-playbook ansible/playbook_configure_k3s.yaml \
	--inventory ansible/hosts

test:
	KUBECONFIG=ansible/kubeconfig_k3s.yaml \
	kubectl apply -f tests/test-deployment

destroy:
	terraform -chdir=terraform destroy
