# DCCC-DataDev-Steampunk
## Main Branch (Production)

### Purpose
This branch represents the **production-ready state** of both infrastructure and application code. It combines approved changes from both the `dev` and `terraform` branches that have passed testing and manual approval.

### Guidelines
  - Do Not commit directly to `main`
  - All changes must be made via Pull Request
  - Requires
    - Minimum of 2 reviewers
    - Passing GitHub Actions checks
    - Linear history
    - Manual deployment approval
### Deployment
Deployed via GitHub Actions with manual approval.
Sensitive resources (e.g., Glue Catalog, IAM, LakeFormation) require an additional manual review

### Structure
This branch unifies:
  - `terraform/` -> Infrastructure modules
  - `AWS/` -> Application logic (e.g., Lambda, Glue Jobs, etc.)
  - `docs/` -> Architecture diagrams and metadata

