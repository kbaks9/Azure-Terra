# Azure VM with Terraform 🖥️☁️

This folder contains Terraform code to deploy a **Windows VM** on Azure along with networking and storage resources.  
Here’s what I’ve learned while building it:

---

## 🚀 Key Learnings

### Azure Provider & Basics
- 🛠️ Configured **Azure provider** in Terraform.  
- 📍 Used **locals** for reusable values like resource group and location.  
- 🔎 Used **data sources** to reference existing resources (e.g., subnet).  

### Networking
- 🌐 Created a **virtual network** and **subnet**.  
- 🔌 Built a **network interface** and linked it to the subnet.  
- 🌍 Assigned a **public IP** to allow external access.  
- 🔒 Learned about **NSGs** and controlling access (e.g., RDP port).  

### Virtual Machines
- 🪟 Deployed a **Windows VM** with a specific size (`Standard_B2s`) and image.  
- 🛡️ Added an **availability set** to improve reliability and distribute VMs across fault/update domains.  
- 💾 Created **managed data disks** and attached them to the VM.  
- 💽 Configured **OS disk properties**: caching (`ReadWrite`) & storage type (`Standard_LRS`).  
- ⏱️ Managed resource **dependencies** with `depends_on` to control creation order.  

### Cost Awareness 💰
- 🖥️ **VM compute**: you pay while the VM is running.  
- 💾 **Disks**: both OS and data disks incur storage costs, even if VM is stopped.  
- 🌍 **Public IP**: static IPs have their own cost.  
- ⚡ **Availability sets and networking**: small extra cost, but adds up with multiple resources.  
> Tip: Stop/deallocate VMs when not in use to save on compute costs.

### Best Practices
- 🔑 Learned **secure credential handling** (avoid hard-coding usernames/passwords).  
- 🔄 Understood how Terraform manages the **lifecycle of Azure resources**.  
- 📦 Learned to structure Terraform code for **scalability** (VMs, network, storage, availability sets).  

---

## 📝 Summary

This project helped me **apply Terraform in real-world Azure scenarios**, from networking to VMs, storage, and availability sets.  
It reinforced the importance of **infrastructure as code**, **resource dependencies**, **reliability**, and **security best practices**.
