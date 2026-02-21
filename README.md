# Exastro × LocalStack 学習環境

このリポジトリは、**Exastro IT Automation** と **LocalStack** を組み合わせて、AWSライクなインフラ構成を手元のローカル環境で学習するための環境を提供します。

本番AWSアカウントを使わずに、Terraform によるインフラ定義やデプロイ操作を安全に試すことができます。

---

## 学習できること

- **Exastro IT Automation** の基本的な操作・設定
- **LocalStack** を使ったAWSサービス (VPC / EC2 / ALB / ACM など) のエミュレーション
- **Terraform** によるインフラのコード化 (Infrastructure as Code)
- ExastroとLocalStackを連携させた自動化ワークフローの構築

---

## 構成

```
exastro_localstack/
├── docker-compose.yml   # Exastro IT Automation + LocalStack の起動設定
├── Setup.md             # 環境セットアップ手順書
└── terraform/           # Terraform によるAWSリソース定義 (LocalStack向け)
    ├── provider.tf      # AWS provider + LocalStack エンドポイント設定
    ├── variables.tf     # 変数定義
    ├── vpc.tf           # VPC / Subnet / IGW / RouteTable
    ├── security_groups.tf # ALB / App / DB / Bastion のセキュリティグループ
    ├── ec2.tf           # Bastion / App / MySQL インスタンス
    ├── alb.tf           # ACM証明書 / ALB / HTTP→HTTPS リダイレクト
    └── outputs.tf       # 出力値
```

---

## 前提条件

| 項目 | バージョン |
|---|---|
| OS | Ubuntu 20.04 / 22.04 / 24.04 (Debian 系) |
| Docker | 24.0 以上 |
| Docker Compose | v2.0 以上 |
| Terraform | 1.7 以上 |

---

## クイックスタート

### 1. コンテナ起動

```bash
# Exastro IT Automation + LocalStack を起動
docker compose up -d
```

| サービス | URL |
|---|---|
| Exastro IT Automation | http://localhost:8080 |
| LocalStack | http://localhost:4566 |

### 2. LocalStack 起動確認

```bash
curl http://localhost:4566/_localstack/health | python3 -m json.tool
```

### 3. Terraform でAWSリソースをデプロイ

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

---

## 詳細手順

セットアップの詳細は [Setup.md](./Setup.md) を参照してください。
