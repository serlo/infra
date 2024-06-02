.PHONY: terraform_fmt
terraform_fmt:
	terraform fmt -recursive

.PHONY: terraform_deploy_staging
terraform_deploy_staging:
	make -C envs/staging/ terraform_apply

.PHONY: terraform_deploy_production
terraform_deploy_production:
	make -C envs/production/ terraform_apply

.PHONY: terraform_validate
terraform_validate:
	(cd envs/production && terraform validate)
	(cd envs/staging && terraform validate)
