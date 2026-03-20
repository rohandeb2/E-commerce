

| Category           | Service / Resource                | Quantity    | Description & Specification                                                                           |
| ------------------ | --------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| **Networking**     | VPC                               | 1           | Custom VPC with 10.0.0.0/16 CIDR block.                                                               |
|                    | Subnets                           | 6           | 2 Public (ALB/NAT), 2 Private (EKS), 2 Database (DocDB), across 2 AZs. Public subnets tagged for ALB. |
|                    | NAT Gateway                       | 1           | Placed in a Public Subnet to allow Private Nodes to access the internet.                              |
|                    | Elastic IP (EIP)                  | 1           | Static IP for the NAT Gateway. Required for consistent outbound traffic.                              |
|                    | Internet Gateway                  | 1           | Provides internet access for Public Subnets.                                                          |
|                    | Route Tables                      | 2           | One for Public (IGW), one for Private/DB (NAT).                                                       |
|                    | Route Table Associations          | 6           | Public, Private, and DB subnets mapped to respective route tables.                                    |
|                    | Route53 Hosted Zone               | 1           | Managed DNS zone for your domain (e.g., rohandevops.co.in).                                           |
|                    | CloudFront Distribution           | 1           | Global CDN for static asset delivery with HTTPS.                                                      |
|                    | CloudFront Origin Access Identity | 1           | Restricts S3 asset bucket access only via CloudFront.                                                 |
| **Compute**        | EKS Cluster                       | 1           | Managed Kubernetes Control Plane (Version 1.31).                                                      |
|                    | EC2 Worker Nodes                  | 2–5         | t3.medium instances with Auto-scaling; persistent storage via EBS.                                    |
|                    | ECR Repository                    | 1           | Private Docker registry for Next.js images with Scan-on-Push enabled.                                 |
|                    | OIDC Provider & IRSA              | 1           | Enables Kubernetes Service Accounts to use IAM roles securely.                                        |
|                    | ALB                               | 0 (managed) | ALB created dynamically via AWS Load Balancer Controller in Kubernetes.                               |
| **Data & Storage** | DocumentDB Cluster                | 1           | MongoDB-compatible database cluster.                                                                  |
|                    | DocDB Instances                   | 1–2         | db.t3.medium; Primary + optional Replica for failover.                                                |
|                    | DB Subnet Group                   | 1           | Required by DocumentDB to know which subnets to use.                                                  |
|                    | S3 Asset Bucket                   | 1           | Stores product images and static content; access controlled via OAI.                                  |
|                    | S3 Lifecycle Configuration        | 1           | Moves objects to Glacier or other storage tiers (optional for cost optimization).                     |
|                    | S3 State Bucket                   | 1           | Global bucket for Terraform remote state with versioning and encryption.                              |
|                    | EBS Volumes                       | 2+          | Persistent block storage attached to EKS nodes.                                                       |
|                    | KMS Key (CMK)                     | 1           | Customer Master Key for encrypting S3 assets and DocumentDB storage.                                  |
| **Messaging**      | SNS Topic                         | 1           | Publishes events such as “Order Created” for async processing.                                        |
|                    | SQS Queues                        | 2           | Main queue for Email/Inventory processing + 1 Dead Letter Queue.                                      |
|                    | SQS Queue Policy                  | 1           | Allows SNS topic to send messages to SQS queue.                                                       |
|                    | SNS Subscription                  | 1           | Connects SNS → SQS.                                                                                   |
| **Security**       | WAF Web ACL                       | 1           | Firewall protecting ALB; includes AWS Managed Rules (SQLi, Bot protection).                           |
|                    | Security Groups                   | 3           | For ALB, EKS nodes, and DocumentDB.                                                                   |
|                    | Secrets Manager                   | 1           | Stores DocumentDB credentials securely.                                                               |
|                    | IAM Roles & Policies              | 4+          | Roles for EKS Cluster, NodeGroups, IRSA for app access.                                               |
| **Observability**  | CloudWatch Log Group              | 1           | Centralized logging for application pods and system logs.                                             |
|                    | X-Ray Sampling Rule               | 1           | Traces 5% of requests for debugging and performance analysis.                                         |
|                    | CloudWatch Dashboard              | 1           | Monitors DocumentDB CPU and other key metrics.                                                        |
|                    | DynamoDB Table                    | 1           | Used for Terraform State Locking and consistency.                                                     |

-