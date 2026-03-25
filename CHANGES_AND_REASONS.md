# Change Summary

This file explains the major changes in the diff in simple terms: **what changed**, **why it changed**, and **what practical benefit we get**.

## 1) Reposittory layout was reorganized

### What changed
- Terraform execution roots were consolidated into clearer top-level folders:
  - `environments/` for environment-level roots
  - `stacks/` for stack-specific deployables
- Old stack directories were renamed:
  - `user_glue` -> `stacks/glue`
  - `user_lambda` -> `stacks/lambda`
  - `user1` -> `stacks/s3`
- Old dev root under `terraform/dccc/application1/dev` was migrated to `environments/dev`.
- Lambda source code folders were moved from `lambda-files/...` to `lambda-code/...`.
- Config folders were formalized:
  - `lambda-configs/generated/` for raw generated manifests
  - `lambda-configs/sanitized/` for reviewed/safe manifests

### Why this was done
- The previous structure had multiple naming patterns and locations, which made it easy to run Terraform from the wrong place.
- Centralizing roots and stacks reduces guesswork and makes responsibilities clearer.
- Separating raw vs sanitized Lambda config gives a safe boundary before anything is promoted to higher environments.

### Practical benefit
- Faster onboarding and less "where do I run this?" confusion.
- Lower risk of accidental changes in CI/CD and manual runs.

## 2) CI/CD workflows were updated for the new structure

### What changed
- Workflow triggers were updated from `user*/**` to `stacks/**`.
- Workflow working directories that pointed to old Terraform paths now point to `environments/dev`.
- `terraform-prod.yml` now uses the correct prod var file path (`vars/prod.tfvars`) during apply.
- A new manual workflow was added: `.github/workflows/terraform-import.yml`
  - supports `plan`, `apply`, and `import_then_plan`
  - validates inputs and Terraform root paths
  - supports optional `deploy_modules` and `tfvars_file`
  - runs multi-line Terraform imports
  - uploads pre/post import state snapshots as artifacts

### Why this was done
- CI/CD still referenced old folder names and path patterns.
- Different stack types need different argument files, so generic logic was not enough.
- Import operations are high-impact; they need a controlled and auditable process.

### Practical benefit
- Pipelines now follow the real repository layout.
- Safer and more reliable plan/apply behavior across stack types.
- Better traceability for state import operations.

## 3) `environments/dev` is now a complete Terraform root

### What changed
- `environments/dev/main.tf` now includes module calls for `ec2`, `s3`, and `rds`.
- `environments/dev/variables.tf` was added with required input definitions.
- `environments/dev/dev.tfvars` was moved and cleaned.
- `provider.tf`, `outputs.tf`, and `version.tf` were moved into `environments/dev`.


### Why this was done
- The refactor goal is to run dev from a clear environment root instead of legacy paths.

### Practical benefit
- One obvious place to run `terraform init/plan/apply` for dev.
- Cleaner module selection and easier troubleshooting.

## 4) Module usage was consolidated into `modules/`

### What changed
- Active module code from `terraform-modules/*` was moved into `modules/*`.
  - EC2 implementation files moved to `modules/ec2`
  - RDS implementation files moved to `modules/rds`
  - duplicate legacy module files were removed
- `modules/rds` was expanded with concrete implementation and fuller variable set.
- `modules/s3` was reshaped to a standard + glacier bucket model, including matching outputs/variables.
- New module path `modules/api-gateway` was introduced, and old `modules/api_gateway` was removed.

### Why this was done
- Two module trees (`modules/` and `terraform-modules/`) create drift and inconsistency.
- Consolidation creates one canonical source for each reusable component.
- API Gateway naming/path cleanup aligns module naming with current conventions.

### Practical benefit
- Fewer duplicate definitions to maintain.
- Lower risk of applying from stale module code.

## 5) Large cleanup removed unused templates and dead paths

### What changed
- Many empty or placeholder module files were deleted (README stubs, empty IAM/locals/variables, etc.).
- Old unused Terraform files in legacy paths were removed, including unused datalake tfvars placeholders.

### Why this was done
- Placeholder-only content increases noise but provides little operational value.
- Keeping dead paths around makes future changes riskier because engineers may edit the wrong files.

### Practical benefit
- Smaller, cleaner repository with less accidental maintenance burden.

## 6) Lambda config promotion artifacts were introduced

### What changed
- Added generated and sanitized Lambda manifest examples:
  - `lambda-configs/generated/app-function-dev.json`
  - `lambda-configs/sanitized/app-function-uat.json`
  - `lambda-configs/sanitized/app-function-prod.json`

### Why this was done
- Generated config can contain noisy or environment-specific values.
- Sanitized config acts as an approved input for promotion flows.

### Practical benefit
- Safer promotion from dev to uat/prod with fewer accidental config leaks or drift.