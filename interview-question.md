🏗️ Section 1: Terraform & Infrastructure Architecture
Q1: Why did you use a Modular structure for Terraform instead of one large main.tf?
Answer: "I followed the DRY (Don't Repeat Yourself) principle and the Separation of Concerns. By using modules for Networking, Compute, and Data, I can manage resource lifecycles independently. This allows us to reuse the same Networking module for a 'Staging' environment while keeping the 'Production' data layer isolated, reducing the blast radius of any changes."

Q2: How did you handle Terraform State in a team environment?
Answer: "I implemented a Remote Backend using Amazon S3 for state storage and DynamoDB for State Locking. S3 Versioning ensures we can recover from state corruption, and DynamoDB prevents 'Race Conditions' where two engineers might try to apply changes simultaneously, which could lead to resource duplication or errors."

Q3: Why did you choose DocumentDB over a standard RDS (PostgreSQL/MySQL)?
Answer: "For an e-commerce platform with evolving product schemas, a NoSQL, MongoDB-compatible database like DocumentDB provides the necessary flexibility. It allows us to store diverse product attributes without complex migrations, while still providing the high availability and managed backups of an AWS service."

☸️ Section 2: Kubernetes & Helm
Q4: Why use Helm instead of plain Kubernetes Manifests?
Answer: "Helm provides Application Lifecycle Management. While plain YAMLs are static, Helm allows us to use Template Logic to inject environment-specific values (like different CPU limits for Dev vs. Prod). Most importantly, it supports Atomic Rollbacks; if a deployment fails, I can revert the entire stack (Deployment, Service, Ingress) to a previous stable version with a single command."

Q5: How does your Kubernetes cluster communicate with AWS services like S3 or SNS?
Answer: "I used IAM Roles for Service Accounts (IRSA). Instead of using hardcoded 'Access Keys' (which is a security risk), I mapped a Kubernetes Service Account to an AWS IAM Role via an OIDC Provider. This follows the Principle of Least Privilege, giving the pod only the specific permissions it needs to access the S3 bucket or SNS topic."

🚀 Section 3: Performance & Cost Optimization
Q6: How did you optimize for cost in this architecture?
Answer: "I implemented three main strategies:

S3 Lifecycle Policies: Automatically moving old logs and invoices to Glacier to save ~90% on storage.

SQS Long Polling: Reducing the number of empty API calls to SQS, which lowers the billing cost and CPU usage.

CloudFront Caching: Offloading traffic from the EKS nodes to the AWS Edge, reducing the number of expensive compute cycles needed to serve static assets."

Q7: Why use an Ingress Controller (ALB) instead of a LoadBalancer service type?
Answer: "Using the AWS Load Balancer Controller with an Ingress allows for IP-mode routing. Standard LoadBalancer services often hop through a NodePort, adding latency. IP-mode routes traffic directly from the ALB to the Pod IP, which is faster and more efficient for high-traffic e-commerce applications."

🛡️ Section 4: Messaging & Reliability
Q8: What is the benefit of the SNS -> SQS 'Fan-out' pattern you used?
Answer: "It provides Asynchronous Resilience. If the application needs to do multiple things after an order is placed (e.g., send an email, update inventory, and notify shipping), I publish one message to SNS. SNS distributes it to multiple SQS queues. This ensures that even if the Email service is down, the Inventory service still receives the message, and the Email service can retry later from its own queue."