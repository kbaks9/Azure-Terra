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
- 💾 Created **managed data disks** and attached them to the VM.  
- 🛡️ Configured **OS disk properties**: caching (`ReadWrite`) & storage type (`Standard_LRS`).  
- ⏱️ Managed resource **dependencies** with `depends_on` to control creation order.  

### Best Practices
- 🔑 Learned **secure credential handling** (avoid hard-coding usernames/passwords).  
- 🔄 Understood how Terraform manages the **lifecycle of Azure resources**.  

---

## 📝 Summary

This project helped me **apply Terraform in real-world Azure scenarios**, from networking to VMs and storage.  
It reinforced the importance of **infrastructure as code**, **resource dependencies**, and **security best practices**.

---

