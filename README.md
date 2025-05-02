# terraform-web-scraper

This repository contains the infrastructure-as-code for the Web Scraper project, managed using **Terraform** and **Terragrunt**. It provisions AWS resources such as Lambda functions, S3 buckets, IAM roles, and deployment pipelines.

📚 **Documentation:** [https://philnel.github.io/docs-web-scraper](https://philnel.github.io/docs-web-scraper)

## 🧱 Stack

- **Terraform** and **Terragrunt** for modular IaC
- **Trivy** for security scanning
- **TFLint** for linting and best practices

## 🧪 Usage

Run lint checks:
```bash
make lint
```

Run security scans:
```bash
make scan
```
