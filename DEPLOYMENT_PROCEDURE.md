# Lambda Promotion Procedure (Dev -> UAT -> Prod)

## Purpose
This document describes the standard promotion flow from the developer side, including where code/config changes go and how the CI/CD pipeline behaves.

## High-level ownership
- **Developer**: prepares function for promotion and commits Lambda code updates.
- **DevOps / Cloud Engineer**: updates Terraform and sanitized Lambda config for UAT/Prod deployments.

## Branch and pipeline behavior
- **`uat` branch push**: pipeline auto-runs with `environment=uat`, `action=apply`.
- **`master` branch push**: pipeline runs `prod` plan first, then waits for approval, then applies to `prod`.
- **Manual trigger (`workflow_dispatch`)**:
  - Any env/action can be selected.
  - If `environment=prod` and action is `apply` or `destroy`, workflow runs plan first, then waits for manual approval before execute.

## DEV -> UAT promotion (first-time Lambda onboarding)
1. Developer (in AWS Console, DEV account) runs the promotion helper Lambda manually named **metadata-generator** in Dev env.
2. Pass the Lambda **function name** to be promoted.
3. Helper Lambda generates config JSON in UAT branch, for example:
   - `lambda-configs/generated/app-function-dev.json`
4. Developer adds Lambda source code under `lambda-code/`:
   - Create folder with function name (if it does not exist).
   - Paste full Lambda code/files into that folder.
5. DevOps/Cloud Engineer prepares sanitized config for deployment:
   - Filter/transform generated config and place in `lambda-configs/sanitized/`.
6. DevOps/Cloud Engineer updates UAT Terraform to deploy the function:
   - Add/update resources/modules in `environments/uat/` (typically `main.tf` and related files).
   - Reference the Lambda code path and sanitized JSON config.
7. Commit to `uat` branch.
8. Pipeline auto-deploys to UAT (`apply`).

## Lambda code updates after first onboarding (UAT path)
Once Terraform wiring already exists, routine code updates are simpler:
1. Developer updates code in existing function folder under `lambda-code/`.
2. Commit to `uat` branch.
3. Pipeline automatically applies UAT changes.

## UAT -> PROD promotion
1. DevOps/Cloud Engineer prepares prod Terraform in `environments/prod/` for the function/infrastructure.
2. Merge `uat` branch into `master`.
3. On `master` push:
   - Pipeline executes prod **plan**.
   - Waits at manual approval gate.
   - After approval, pipeline performs prod **apply**.

## Manual production operations
For manual runs where `environment=prod`:
- `action=plan`: runs normally.
- `action=apply` or `action=destroy`: requires approval gate before execution.

## Notes
- Keep Lambda code and Terraform changes in sync (paths, handler, runtime, packaging expectations).
- Keep sanitized configs under `lambda-configs/sanitized/`; avoid using generated files directly for deployment without review/sanitization.
