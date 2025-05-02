.PHONY: fmt validate lint scan
fmt:
	terraform fmt -recursive

validate:
	terraform validate

lint:
	tflint --recursive

scan:
	trivy config . \
	--exit-code 1 \
	--severity HIGH,CRITICAL \
	--skip-dirs .terraform,.terragrunt-cache,environments
