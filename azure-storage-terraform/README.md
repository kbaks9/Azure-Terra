# 🌐 Terraform Azure Storage Setup

This folder contains a **Terraform configuration** to create an **Azure Resource Group, Storage Account, Container, and Blob**.  

**Purpose:** Practice Terraform and apply Azure skills in a real environment.  

---

### 🧩 Key Learnings

#### Terraform Basics
- Provider & required versions  
- Safe credentials using environment variables 🔒  

#### Variables & Locals
- Dynamic input with `variable`  
- Reusable values with `locals`  

#### Azure Resources & Dependencies
- Resource Group → Storage Account → Container → Blob  
- `depends_on` ensures correct creation order ⏳  

#### Azure Storage
- Standard Storage Account with LRS  
- Blob container and file upload  

#### Workflow
- `terraform init` → `terraform plan` → `terraform apply` → `terraform destroy`  
- Terraform handles dependencies automatically ✅  

---

### 💻 How to Run

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration
terraform apply

# Destroy resources when done
terraform destroy
