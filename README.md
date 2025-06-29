### **Static Website Hosting on S3 + CloudFront**

# 🚀 Static Website Hosting on AWS S3 + CloudFront
Host a static website using AWS S3 and accelerate delivery with CloudFront CDN.

## 📌 Project Overview
This project deploys a static website on an S3 bucket and serves it via AWS CloudFront for high availability and low latency.

## 🛠️ Tech Stack
- **Cloud Provider**: AWS
- **IaC**: Terraform
- **Services**: S3, CloudFront, IAM

## 📂 File Structure
```bash
static-site-hosting/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── website/
│   └── index.html
├── README.md
````

## 🚀 How to Deploy

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 🔐 Security & Permissions

* S3 bucket has restricted public access.
* CloudFront serves content securely via HTTPS.

## 🧹 Teardown

```bash
terraform destroy
```

## 🧠 Lessons Learned

* S3 static hosting and bucket policy
* CloudFront distribution setup via Terraform

## 👨‍💻 Author

[Vishal Khairnar](https://github.com/Vishaldk18)




