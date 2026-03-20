first of all install terraform in system
and go to the terraform code and run the global one

and then go to the environment/prod and run terraform init plan vlaidate and apply


# 1. Add the EKS Chart Repo
helm repo add eks https://aws.github.io/eks-charts

# 2. Update your local repo
helm repo update

# 3. Install the Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=easyshop-prod \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

  
helm create easyshop-app




To reach a **12 LPA Senior DevOps** level, you must distinguish between **Infrastructure Bootstrapping** (things you do once to "build the house") and **CI/CD Pipelines** (things you do every time you "change the furniture").

Here is the exact sequence of the "One-Time" setup steps that sit **outside** your regular application pipeline.

---

### **Phase 1: Local Environment Preparation**
* **Install CLI Tools:** Install `aws`, `kubectl`, `terraform`, and `helm`.
* **Identity Setup:** Run `aws configure` to provide your Access Keys.
* **ECR Repository Creation:** While Terraform usually does this, you must ensure the repository exists before the pipeline tries to push to it.

---

### **Phase 2: Infrastructure Core (The "Build once" phase)**
Run these manually or via a separate "Infra Pipeline":
1.  **Terraform Global:** Run `terraform apply` in your global folder (S3 Backend, IAM OIDC provider).
2.  **Terraform Environment:** Run `terraform apply` in `environments/prod`.
    * *Result:* VPC, EKS Cluster, DocumentDB, and ECR Repos are created.
3.  **Kubeconfig Update:** Run:
    `aws eks update-kubeconfig --region us-east-1 --name easyshop-prod`

---

### **Phase 3: Cluster "Add-on" Bootstrapping**
These are the controllers that give your cluster its "Logic." You install these **once** per cluster.

#### **1. AWS Load Balancer Controller**
Required to make your `Ingress.yaml` work.
```bash
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=easyshop-prod \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

#### **2. External Secrets Operator**
Required to make your `ExternalSecret.yaml` work.
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace
```

---

### **Phase 4: Manual Secret Population**
Terraform creates the "slots" in Secrets Manager, but it shouldn't know your real passwords.
* **Step:** Log in to the **AWS Secrets Manager Console**.
* **Step:** Find `easyshop/production/docdb` and `easyshop/production/auth`.
* **Step:** Manually enter the JSON values (passwords, JWT keys) that you had in your `.env`.

---

### **Phase 5: Baseline Application Setup**
* **Namespace Creation:** `kubectl create namespace production`.
* **Docker Migration (Initial Seeding):** * Build and push your migration image manually the very first time.
    * Run the K8s Job manually once to ensure the DB is populated before the pipeline starts.

---

### **Summary: What stays OUTSIDE vs. what stays INSIDE**

| **Outside the Pipeline (One-Time)** | **Inside the Pipeline (Every Push)** |
| :--- | :--- |
| Creating VPC / EKS Cluster | Building the App Docker Image |
| Installing Helm Controllers (ALB/ESO) | Pushing Image to ECR |
| Setting up SSL Certificates in ACM | Running Helm Upgrade/Install |
| Populating Master Passwords in Secrets Manager | Updating the App Version/Tag |

---

### 🧠 The "12 LPA" Interview Pitch: "Day 0 vs Day 1 Operations"

If the interviewer asks: *"How do you handle the initial setup of a new environment?"*

**Your Senior Answer:**
> "I separate my automation into **Day 0** and **Day 1** operations. **Day 0** involves bootstrapping the infrastructure and cluster add-ons (like the ALB Controller and External Secrets Operator) which are done once. **Day 1** is our CI/CD pipeline, which handles the constant deployment of code. This separation ensures that our core infrastructure remains stable and is not accidentally modified during a standard application code release."

### 🚀 Your Next Step
Now that the "One-Time" steps are clear, the only thing left is the **GitHub Actions Pipeline** for the "Every-Time" steps.

**Would you like me to write the GitHub Actions script that automates the Build, Push, and Deploy process?**




🛠️ The Essential Prerequisites (The "Must-Haves")
Before you push this file, you must set up these external tools and secrets:

1. GitHub Secrets (The "Vault")
Go to your Repo Settings > Secrets > Actions:

AWS: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION.

GitOps: GITOPS_PAT (A Personal Access Token with "repo" scope so the pipeline can push to your manifest repo).

Security: SONAR_TOKEN (from SonarCloud), ZAP_API_KEY (if using ZAP service).

Alerts: SLACK_WEBHOOK (from your Slack App).

2. External Services
SonarCloud: Create a free account, link your GitHub repo, and get your Project Key/Org.

Slack: Create a channel (e.g., #deployments) and create an "Incoming Webhook."

GitOps Repo: You must have a separate GitHub repository named rohan/easyshop-manifests with your Helm charts inside.

3. GitHub Environments (For Manual Approval)
To make the Promote to Production step work:

Go to Repo Settings > Environments.

Create an environment named production.

Check "Required reviewers" and add your name.

In your YAML, change the promote-to-prod job to include: environment: production.



# Create the namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access the UI (Port-forward to see it on localhost:8080)
kubectl port-forward svc/argocd-server -n argocd 8080:443


kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


# For Mac/Linux
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

kubectl argo rollouts get rollout easyshop-app -n easyshop-prod

kubectl create namespace argo-rollouts

kubectl apply -n argo-rollouts -f
https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml


kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml




1️⃣ Install Argo CD

Used for GitOps deployment

Install
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

Login password:

kubectl get secret argocd-initial-admin-secret \
-n argocd \
-o jsonpath="{.data.password}" | base64 -d

Open:

https://localhost:8080
2️⃣ Install Argo Rollouts

Required for your Canary deployment strategy.

Install
kubectl create namespace argo-rollouts

kubectl apply -n argo-rollouts \
-f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

Verify:

kubectl get pods -n argo-rollouts
3️⃣ Install External Secrets Operator

Required because you are using:

kind: ExternalSecret
kind: SecretStore
Install via Helm
helm repo add external-secrets https://charts.external-secrets.io

helm repo update

helm install external-secrets external-secrets/external-secrets \
-n external-secrets \
--create-namespace

Verify:

kubectl get pods -n external-secrets
4️⃣ Install Metrics Server

Required for HorizontalPodAutoscaler.

Install
kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Verify:

kubectl top nodes

If this works → metrics server is working.

5️⃣ Install AWS Load Balancer Controller

Required because you use:

kubernetes.io/ingress.class: alb

Without this → ALB will never be created.

Step 1 — Create IAM policy
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

Create policy:

aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json
Step 2 — Create IAM Service Account
eksctl create iamserviceaccount \
  --cluster my-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
Step 3 — Install Helm chart
helm repo add eks https://aws.github.io/eks-charts

helm repo update

Install:

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
-n kube-system \
--set clusterName=my-cluster \
--set serviceAccount.create=false \
--set serviceAccount.name=aws-load-balancer-controller

Verify:

kubectl get pods -n kube-system | grep load-balancer
6️⃣ Install Velero

Required for your backup schedules.

Install CLI
brew install velero

or

curl -L https://github.com/vmware-tanzu/velero/releases/latest/download/velero-linux-amd64.tar.gz | tar -xz
Install on cluster

Example for AWS:

velero install \
--provider aws \
--plugins velero/velero-plugin-for-aws:v1.8.0 \
--bucket velero-backups \
--backup-location-config region=us-east-1 \
--snapshot-location-config region=us-east-1 \
--secret-file ./credentials-velero

Verify:

kubectl get pods -n velero



Step 6: Define "Success Criteria" for Documentation
Since you aren't deploying to AWS, you should document how an engineer would verify this setup. Add this "Verification Runbook" to your docs:

Check Targets: Run kubectl port-forward svc/prometheus-operated -n monitoring 9090. Navigate to Status > Targets and verify easyshop-app is "UP".

Query Metrics: In the Prometheus UI, run the query http_requests_total to see real-time traffic data from the Node.js app.

Grafana Visualization: Import Dashboard ID 11159 to see Node.js runtime health (Event Loop lag, Memory Heap, etc.).




kubectl label namespace easyshop-prod istio-injection=enabled

Ensure you have the Istio Control Plane Dashboard (ID: 7639) and Istio Service Dashboard (ID: 14104) in Grafana.

# 1. Update and install basics
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl git unzip

# 2. Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# 3. Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 4. Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl



Once the VM is ready, your "New Machine" workflow is:

git clone your project.

aws configure to link your AWS account.

cd terraform && terraform apply to build the cluster.

aws eks update-kubeconfig --name easyshop-eks-prod to connect your VM to EKS.

kubectl apply -f argocd/root-app.yaml to start the automated deployment.


