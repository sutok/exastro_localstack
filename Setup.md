# Terraform + LocalStack セットアップ手順書

## 前提条件

| 項目 | バージョン |
|---|---|
| OS | Ubuntu 20.04 / 22.04 / 24.04 (Debian 系) |
| Docker | 24.0 以上 |
| Docker Compose | v2.0 以上 |
| Terraform | 1.7 以上 |

---

## 1. 事前準備

### 1-1. パッケージ更新

```bash
sudo apt update && sudo apt upgrade -y
```

### 1-2. Docker インストール (未導入の場合)

```bash
# 必要パッケージ追加
sudo apt install -y ca-certificates curl gnupg

# Docker 公式 GPG キー追加
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# リポジトリ追加
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# インストール
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# sudo なしで docker コマンドを使えるようにする
sudo usermod -aG docker $USER
newgrp docker
```

### 1-3. Docker 動作確認

```bash
docker --version
docker compose version
```

---

## 2. Terraform インストール

### 2-1. HashiCorp GPG キーとリポジトリ追加

```bash
sudo apt install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
```

### 2-2. Terraform インストール

```bash
sudo apt update && sudo apt install -y terraform
```

### 2-3. インストール確認

```bash
terraform -version
```

**出力例:**
```
Terraform v1.7.5
on linux_amd64
```

### 2-4. コマンド補完設定 (任意)

```bash
terraform -install-autocomplete
source ~/.bashrc
```

---

## 3. LocalStack 起動

### 3-1. リポジトリのクローン / ディレクトリ移動

```bash
cd /home/<your-user>/Github/exastro
```

### 3-2. LocalStack 起動

```bash
docker compose up -d localstack
```

### 3-3. 起動確認

```bash
# ヘルスチェック (ready が返れば OK)
curl http://localhost:4566/_localstack/health | python3 -m json.tool
```

**出力例 (抜粋):**
```json
{
  "services": {
    "acm": "available",
    "ec2": "available",
    "elbv2": "available"
  },
  "status": "running"
}
```

---

## 4. Terraform 初期化

### 4-1. terraform ディレクトリへ移動

```bash
cd terraform/
```

### 4-2. 初期化

```bash
terraform init
```

**出力例:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

---

## 5. 実行計画の確認

```bash
terraform plan
```

作成されるリソースの一覧が表示されます。エラーがないことを確認してください。

**確認ポイント:**
- `Plan: XX to add, 0 to change, 0 to destroy.` と表示されること
- `Error` や `Warning` が出ていないこと

---

## 6. リソースのデプロイ

```bash
terraform apply
```

確認プロンプトが表示されたら `yes` を入力します。

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

**出力例:**
```
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 1s [id=vpc-xxxxxxxx]
...
Apply complete! Resources: XX added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name       = "myapp-alb.elb.localhost.localstack.cloud"
app_private_ip     = "10.0.2.xxx"
bastion_public_ip  = "10.0.1.xxx"
db_private_ip      = "10.0.3.xxx"
acm_certificate_arn = "arn:aws:acm:ap-northeast-1:000000000000:certificate/xxxx"
```

---

## 7. 動作確認

### 7-1. LocalStack 上のリソース確認

```bash
# VPC 確認
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs \
  --query 'Vpcs[*].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}' \
  --output table

# EC2 インスタンス確認
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,Name:Tags[?Key==`Name`].Value|[0]}' \
  --output table

# ALB 確認
aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}' \
  --output table

# ACM 証明書確認
aws --endpoint-url=http://localhost:4566 acm list-certificates \
  --query 'CertificateSummaryList[*].{ARN:CertificateArn,Domain:DomainName,Status:Status}' \
  --output table
```

---

## 8. リソースの削除

```bash
terraform destroy
```

確認プロンプトで `yes` を入力します。

---

## トラブルシューティング

### LocalStack に接続できない

```bash
# LocalStack コンテナの状態確認
docker compose ps

# ログ確認
docker compose logs localstack
```

### `terraform init` で Provider のダウンロードが失敗する

```bash
# プロキシ設定が必要な環境の場合
export HTTPS_PROXY=http://<proxy-host>:<port>
terraform init
```

### `Error: error configuring S3 Backend` が出る

`provider.tf` の `skip_*` フラグが正しく設定されているか確認してください。

```hcl
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_requesting_account_id  = true
```

---

## ディレクトリ構成

```
exastro/
├── docker-compose.yml        # LocalStack 起動設定
├── Setup.md                  # 本手順書
└── terraform/
    ├── provider.tf           # AWS provider + LocalStack エンドポイント
    ├── variables.tf          # 変数定義
    ├── vpc.tf                # VPC / Subnet / IGW / RouteTable
    ├── security_groups.tf    # ALB / App / DB / Bastion の SG
    ├── ec2.tf                # Bastion / App / MySQL インスタンス
    ├── alb.tf                # ACM 証明書 / ALB / HTTP→HTTPS / HTTPS(443)
    └── outputs.tf            # 出力値
```
