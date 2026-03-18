# Repository Restructuring Proposal

## Objective
Refactor this repository into a clear, promotion-driven model where:

- `dev` is managed manually (AWS Console / direct Lambda deploys), **not** by Terraform.
- `uat` and `prod` are managed by Terraform only.
- Lambda promotion from `dev` to `uat/prod` is controlled through a generated JSON artifact and reviewed workflow.

---

## Current Structural Issues

Based on the existing layout, there are a few maintainability risks:

1. Environment patterns are mixed
   - Multiple environment roots exist (`environments/`, `terraform/.../dev`, `user_*` folders).
   - This makes ownership and deployment paths unclear.

2. Module duplication and overlap
   - There are both `modules/` and `terraform-modules/` trees.
   - Similar resource types are defined in multiple places, increasing drift risk.

3. Dev is treated like Terraform-managed infra
   - There are Terraform files for `dev`, while the intended operating model is manual dev.
   - This creates confusion about source of truth.

4. App and infra concerns are not separated consistently
   - Lambda code, terraform roots, and user-specific Terraform roots are split across several top-level directories.
   - Harder onboarding and harder CI/CD standardization.

---

## Target Operating Model

### Environments
- **dev**: Manual management in AWS Console / direct developer workflow.
- **uat**: Terraform-managed, promotion target.
- **prod**: Terraform-managed, promotion target.

### Promotion Principle
- `dev` remains experimental and fast-moving.
- `uat/prod` only receive reviewed, reproducible configuration and code.
- JSON artifact generated from dev Lambda metadata is used as promotion input (after validation and sanitization).

---

## Recommended Repository Structure

```text
.
├── environments/
│   ├── uat/
│   │   ├── backend.tf
│   │   ├── providers.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── uat.tfvars
│   └── prod/
│       ├── backend.tf
│       ├── providers.tf
│       ├── main.tf
│       ├── variables.tf
│       └── prod.tfvars
├── modules/                            # single shared module source
├── lambda-code/
│   ├── <function_name_1>/
│   │   └── <code files>
│   └── <function_name_2>/
│       └── <code files>
├── lambda-configs/
│   ├── generated/                      # JSON output from metadata-generator Lambda
│   └── sanitized/                      # reviewed JSON referenced by Terraform modules
├── scripts/
│   └── promotion/
│       ├── validate_manifest.py
│       ├── sanitize_manifest.py
│       └── map_manifest_to_tfvars.py
├── .github/workflows/
│   ├── promote-lambda-uat.yml
│   └── promote-lambda-prod.yml
└── docs/
    ├── architecture.md
    ├── promotion-process.md
    └── runbooks/
```

---

## What Should Be Changed (and Why)

1. Remove Terraform ownership of `dev`
   - **Change**: Stop applying Terraform to dev roots (`environments/dev`, `terraform/.../dev`, user-level dev tf roots).
   - **Why**: Aligns with your operating model and removes false expectations that dev is reproducible via Terraform.

2. Keep Terraform roots at repository root
   - **Change**: Keep `environments/` and `modules/` directly at repository root, with only `uat` and `prod` environment roots.
   - **Why**: One clear location for infra reduces cognitive load and pipeline complexity.

3. Keep only one module library
   - **Change**: Merge `modules/` and `terraform-modules/` into one standardized root-level `modules/`.
   - **Why**: Prevents duplicated logic and behavior drift across environments.

4. Separate application code from IaC
   - **Change**: Place Lambda code under root-level `lambda-code/`, with one folder per Lambda function.
   - **Why**: Improves ownership boundaries and makes deployment paths explicit.

5. Standardize promotion artifacts
   - **Change**: Store generated manifests under `lambda-configs/generated/` and reviewed versions under `lambda-configs/sanitized/`.
   - **Why**: Establishes auditable, deterministic inputs for `uat/prod` promotion.

6. Add manifest validation and sanitization gate
   - **Change**: Validate JSON schema and sanitize unsafe fields before Terraform consumes values.
   - **Why**: Prevents accidental promotion of secrets or dev-only configuration.

---

## Lambda Promotion Flow (dev -> uat/prod)

Your dev helper Lambda takes another Lambda name and emits a JSON payload like:

```json
{
  "FunctionName": "app-function-dev",
  "Runtime": "python3.12",
  "Handler": "app.lambda_handler",
  "MemorySize": 128,
  "Timeout": 10,
  "Environment": {
    "Variables": {
      "API_KEY": "798d9sa87d09a800909",
      "STAGE": "dev"
    }
  }
}
```

### Recommended Promotion Steps

1. Generate manifest in `dev`
   - Extract Lambda configuration and publish artifact to a controlled path (S3 or repo artifact location).

2. Validate manifest schema
   - Ensure required fields exist and data types are correct.
   - Reject malformed artifacts early.

3. Sanitize manifest
   - Strip or replace environment-specific and sensitive values:
     - `FunctionArn`, `Role`, `LastModified`, `Version`, `CodeSha256` (if environment-specific strategy is used)
     - Secret values such as `API_KEY` should not be promoted as plaintext.
   - Convert `STAGE=dev` to target environment stage (`uat`/`prod`) where appropriate.

4. Map manifest to Terraform input
   - Convert approved fields into Terraform variables (`*.tfvars` or generated module input JSON).
   - Keep runtime, handler, timeout, memory, architecture, and API mappings when valid.

5. Plan/apply in target environment
   - Run Terraform in `environments/uat` or `environments/prod`.
   - Require approval gates before apply (especially `prod`).

6. Post-deploy verification
   - Smoke test Lambda and API Gateway route integration in target environment.

---

## Field-Level Guidance for Manifest Consumption

### Safe to promote (typically)
- `Runtime`
- `Handler`
- `MemorySize`
- `Timeout`
- `Architectures`
- Relevant API route mappings (after target environment mapping)

### Review before promote
- `Environment.Variables` (never promote raw secrets)
- `Role` (must match target environment IAM role design)
- `ApiGatewayNames` / `ApiGatewayPaths` (must map to target API names/stages)

### Do not treat as desired-state config
- `FunctionArn`
- `LastModified`
- `Version`
- `CodeSize`
- `CodeSha256` (unless tied to immutable artifact promotion strategy)

---

## CI/CD Expectations After Refactor

1. Separate workflows for:
   - `uat` Terraform plan/apply
   - `prod` Terraform plan/apply (manual approval required)
   - Lambda promotion validation/sanitization

2. Branch protection:
   - PR-only merges to protected branches.
   - Required checks for manifest validation and Terraform plan.

3. Artifact traceability:
   - Promotion should link:
     - source dev Lambda reference
     - manifest version/hash
     - target environment
     - deployment run ID

---

## Migration Plan (Incremental)

1. Freeze new Terraform work in `dev` paths.
2. Choose a single Terraform module tree and migrate references.
3. Establish final `environments/{uat,prod}` roots at repository root.
4. Move Lambda code to `lambda-code/` (one folder per Lambda).
5. Implement manifest schema + sanitization scripts.
6. Update GitHub Actions to promotion-driven model.
7. Decommission obsolete folders after validation.

---

## Final Notes

- This approach keeps `dev` flexible while making `uat/prod` controlled and reproducible.
- The key success factor is treating the generated Lambda JSON as an **input artifact**, not as a direct apply payload.
- Secret handling must be externalized (SSM Parameter Store / Secrets Manager) before promotion to higher environments.
