# Azure VM with Terraform 🖥️☁️

This folder contains Terraform code I wrote to deploy a **Windows VM** on Azure along with its supporting network resources. Here’s what I learned while doing it:

---

## Key Learnings ✨

- How to **set up and configure the Azure provider** in Terraform.  
- Using **locals** to store reusable values like resource group names and location.  
- Understanding **data sources** to reference existing resources (like a subnet).  
- Creating a **resource group** and placing resources inside it.  
- How to define a **virtual network and subnet** in code. 🌐  
- Creating a **network interface** and connecting it to a subnet. 🔌  
- Deploying a **Windows VM** with a specific size and image. 🪟  
- Setting **dependencies** between resources using `depends_on` to control the order of creation.  
- Practical exposure to **dynamic IP allocation** and VM networking.  
- Reinforcing the importance of **secure handling of credentials** (don’t hard-code in production).  

---

## Summary 📝

By going through this exercise, I applied my Terraform knowledge to **real-world Azure scenarios**, learned how resources interact, and gained confidence in managing **VMs and networking infrastructure as code**.
