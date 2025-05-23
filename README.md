
# EKS CKA/CKAD Exam Environment with Terraform

This repository provides a complete, destroyable Amazon EKS (Elastic Kubernetes Service) cluster setup using **Terraform** for preparing for the **CKA** (Certified Kubernetes Administrator) and **CKAD** (Certified Kubernetes Application Developer) exams. The setup includes EC2 node access via SSH, monitoring integrations, and optional workload manifests.

---

## ⚙️ What This Project Does

- Creates a VPC with public and private subnets.
- Sets up an EKS Cluster with a custom node group (with SSH access).
- Uses AWS Launch Templates for EC2 instances in the node group.
- Configures IAM roles and policies for cluster and nodes.
- Supports environment teardown with a single command to avoid unnecessary billing.
- Includes a sample monitoring setup and Kubernetes manifests for extended use.

---

## 📐 Architecture

```
AWS VPC (with public and private subnets)
│
├── NAT Gateway (for private subnet egress)
│
├── Internet Gateway (for public subnet egress)
│
└── EKS Cluster (private endpoint)
    ├── EKS Control Plane (Managed by AWS)
    └── EKS Node Group (EC2 using Launch Template with SSH key)
        └── Kubelet registered nodes with cluster
```

**Modules Breakdown:**

- `modules/vpc`: Custom VPC with routing and NAT/IGW setup.
- `modules/eks_cluster`: EKS cluster and its IAM setup.
- `modules/node_group`: Node group using EC2 Launch Template with SSH key support.
- `monitoring-eks`: Optional monitoring stack (Prometheus, Grafana, etc).
- `kubernetes-manifest`: Optional Kubernetes workloads to deploy on the cluster.

---

## 🚀 How to Use

### 1. Setup Terraform Backend (Optional)
You may configure remote state or use local backend as configured in the repo.

### 2. Define Your Terraform Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update your values:

```hcl
region        = "us-east-1"
key_name      = "my-bastion-key"
my_ip         = "YOUR_PUBLIC_IP/32"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply the Infrastructure

```bash
terraform apply -auto-approve
```

Once applied, outputs will include:
- `eks_cluster_endpoint`
- `eks_cluster_ca`
- `node_group_name`
- `vpc_id`, etc.

### 5. Configure `kubectl`

```bash
aws eks --region <region> update-kubeconfig --name myekscluster
kubectl get nodes
```

You should see your worker nodes in `Ready` state.

---

## 🔒 SSH Access to Nodes

Make sure your SSH key is available locally and that the node security group allows inbound SSH from your IP:

```bash
ssh -i my-bastion-key-01.pem ec2-user@<node-ip>
```

Note: EKS nodes do not expose public IPs by default unless modified. You may access via bastion or allocate an EIP.

---

## ⚠️ WARNING

**This setup is intended purely for Kubernetes exam preparation (CKA/CKAD).**

- Not intended for production use.
- All resources can be destroyed with a single command:

```bash
terraform destroy -auto-approve
```

- Be mindful of AWS billing. Always destroy resources when not in use.
- You can increase the number of nodes in the node group by adjusting `desired_size`, `min_size`, and `max_size` in `node_group/main.tf`.

---

## 🧩 Extras

- Sample Prometheus + Grafana monitoring setup available in `monitoring-eks/`.
- Sample Kubernetes workloads and manifests in `kubernetes-manifest/`.

---

## 📝 Authors

Created for personal and educational purposes related to Kubernetes certification.

---


---

## 🔧 Useful Commands with Explanation

Here are some essential commands that you might find helpful during usage:

### Terraform Commands

- `terraform init`  
  Initializes the working directory and downloads the required provider plugins.

- `terraform validate`  
  Validates the configuration files in the directory to ensure they are syntactically valid.

- `terraform plan`  
  Creates an execution plan, showing what actions Terraform will take to reach the desired state.

- `terraform apply`  
  Applies the changes required to reach the desired state of the configuration.

- `terraform destroy`  
  Destroys all the resources defined in the Terraform configuration to avoid unnecessary AWS billing.

- `terraform fmt`  
  Formats Terraform configuration files to a canonical format.

### AWS CLI

- `aws eks update-kubeconfig --region <region> --name <cluster_name>`  
  Updates or generates the kubeconfig file for accessing the EKS cluster using `kubectl`.

### Kubectl

- `kubectl get nodes`  
  Lists all the nodes registered with the EKS cluster.

- `kubectl get pods -A`  
  Lists all pods across all namespaces.

- `kubectl describe node <node-name>`  
  Displays detailed information about a node.

- `kubectl logs <pod-name>`  
  Shows logs for a specific pod.

- `kubectl exec -it <pod-name> -- bash`  
  Accesses the shell inside a pod for debugging.

---

