ifndef env_name
$(error variable env_name not set)
endif

export gcloud_env_name = serlo_$(env_name)

ifndef cloudsql_credential_filename
$(error variable cloudsql_credential_filename not set)
endif

.PHONY: terraform_init
terraform_init: terraform_download_secrets
	terraform get -update
	terraform init

.PHONY: terraform_plan
terraform_plan: terraform_download_secrets terraform_plan_without_downloading_secrets

.PHONY: terraform_plan_without_downloading_secrets
terraform_plan_without_downloading_secrets:
	terraform fmt -recursive
	terraform plan -var-file secrets/terraform-$(env_name).tfvars

.PHONY: terraform_apply
terraform_apply: terraform_download_secrets terraform_apply_without_downloading_secrets

.PHONY: terraform_apply_without_downloading_secrets
terraform_apply_without_downloading_secrets:
	terraform fmt -recursive
	terraform apply -var-file secrets/terraform-$(env_name).tfvars

.PHONY: terraform_destroy
terraform_destroy:
	terraform fmt -recursive
	terraform destroy -var-file secrets/terraform-$(env_name).tfvars

.PHONY: terraform_download_secrets
terraform_download_secrets:
	rm -rf secrets
	gsutil -m cp -R gs://$(gcloud_env_name)_terraform/secrets/ .

secrets_path = secrets/terraform-$(env_name).tfvars

.PHONY: terraform_upload_tfvars
terraform_upload_tfvars:
	@echo You are about to change the terraform secrets of $(env_name) environment, continue? [y/n]
	@read line; if [ $$line = "y" ]; then gsutil cp $(secrets_path) gs://$(gcloud_env_name)_terraform/$(secrets_path) ; fi
