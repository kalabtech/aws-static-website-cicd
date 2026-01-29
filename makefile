# --- VARIABLES ---
TF_DIR      = ./infra
DOCS_DIR    = ./docs/obsidian
MOD_DIR     = ./modules
STATE_FILE  = dev.tfplan

.PHONY: all verify-identity init plan apply destroy state checkfiles check security prec prec-all docs help

# Default action
all: security fmt check plan

## --- AWS ---
verify-identity: ## Shows actual AWS profile
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text

## --- TERRAFORM COMMANDS ---

init: ## Initialize backend and plugins
	@echo "Initializing..."
	@cd $(TF_DIR) && terraform init

plan: ## Generate execution plan
	@echo "Generating plan..."
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	@cd $(TF_DIR) && terraform plan -out=$(STATE_FILE)

apply: ## Apply changes
	@echo "Applying changes..."
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	@echo "Destroying infrastructure..."
	@cd $(TF_DIR) && terraform apply $(STATE_FILE)

destroy: ## Destroy infrastructure
	@echo "Current AWS Identity:"
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	@echo "WARNING: You are about to destroy all infrastructure."
	@cd $(TF_DIR) && terraform destroy

state: ## Shows tfstate
	@echo "Current AWS Identity:"
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	@cd $(TF_DIR) && terraform state pull


## --- QUALITY AND SECURITY ---

checkfiles: ## Format and Validation Terraform code
	@echo "Formatting code..."
	@terraform fmt -recursive $(MOD_DIR)
	@terraform fmt -recursive $(TF_DIR)
	@echo "Validating code..."
	@cd $(TF_DIR) && terraform validate
	@cd $(TF_DIR) && terraform validate

check: ## Linting and syntax validation
	@echo "Running TFLint..."
	@tflint --chdir=$(TF_DIR) --init
	@tflint --chdir=$(TF_DIR)

security: ## Security scanning
	@echo "Scanning for vulnerabilities..."
	@tfsec $(TF_DIR)
	@checkov -d $(TF_DIR) --quiet

## --- PRE-COMMIT ---

prec: ## Run pre-commit on staged files only (fast check)
	@echo "Running pre-commit on staged files..."
	@pre-commit run

prec-all: ## Run pre-commit on all files (deep check)
	@echo "Running pre-commit on all files..."
	@pre-commit run --all-files

## --- DOCUMENTATION (OBSIDIAN) ---

docs: ## Generate automatic Markdown documentation for Obsidian
	@echo "Updating Obsidian documentation..."
	@terraform-docs markdown table $(TF_DIR) > $(DOCS_DIR)/infrastructure.md
	@echo "Documentation updated at $(DOCS_DIR)/infrastructure.md"

## --- UTILITIES ---

help: ## Show this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
