ifndef env_name
$(error variable env_name not set)
endif

export gcloud_env_name = serlo_$(env_name)

ifndef cloudsql_credential_filename
$(error variable cloudsql_credential_filename not set)
endif

.PHONY: terraform_init
terraform_init: 
	#remove secrets and load latest secret from gcloud
	rm -rf secrets
	gsutil -m cp -R gs://$(gcloud_env_name)_terraform/secrets/ .
	terraform get -update
	terraform init

.PHONY: terraform_plan
terraform_plan:
	terraform fmt -recursive
	terraform plan -var-file secrets/terraform-$(env_name).tfvars

.PHONY: terraform_apply
terraform_apply:
	# just make sure we know what we are doing
	terraform fmt -recursive
	terraform apply -var-file secrets/terraform-$(env_name).tfvars

.PHONY: terraform_destroy
terraform_destroy:
	# just make sure we know what we are doing
	terraform fmt -recursive
	terraform destroy -var-file secrets/terraform-$(env_name).tfvars

