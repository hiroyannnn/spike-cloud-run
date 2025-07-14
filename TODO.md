# TODO - Cloud Run + Cloud SQL デプロイ手順

## 🚀 次にやること

### 1. GCP プロジェクトの準備
- [ ] GCP プロジェクトの作成または選択
- [ ] gcloud CLI の認証設定
- [ ] ビリングアカウントの設定（重要！）
- [ ] 必要な API の有効化
  ```bash
  gcloud services enable compute.googleapis.com --project=spike-cloud-run
  gcloud services enable run.googleapis.com --project=spike-cloud-run
  gcloud services enable vpcaccess.googleapis.com --project=spike-cloud-run
  gcloud services enable sqladmin.googleapis.com --project=spike-cloud-run
  gcloud services enable servicenetworking.googleapis.com --project=spike-cloud-run
  gcloud services enable secretmanager.googleapis.com --project=spike-cloud-run
  gcloud services enable containerregistry.googleapis.com --project=spike-cloud-run
  gcloud services enable artifactregistry.googleapis.com --project=spike-cloud-run
  ```

### 2. Terraform によるインフラ構築
- [ ] `terraform/terraform.tfvars` ファイルの作成
  ```bash
  cp terraform/terraform.tfvars.example terraform/terraform.tfvars
  # プロジェクト ID やパスワードを設定
  ```
- [ ] Terraform の初期化と実行
  ```bash
  make terraform-init
  make terraform-plan
  make terraform-apply
  ```

### 3. アプリケーションのデプロイ
- [ ] Docker イメージのビルドとプッシュ（Terraform 実行前に必要）
- [ ] Cloud Run へのデプロイ
  ```bash
  export PROJECT_ID=spike-cloud-run
  make deploy
  ```

### 4. データベースのセットアップ
- [ ] Cloud SQL への接続確認
- [ ] 本番環境でのマイグレーション実行
- [ ] API 経由でテストデータの作成

### 5. 動作確認
- [ ] Cloud Run の URL でアプリケーションアクセス
- [ ] API エンドポイントの動作確認
  - `GET /` - アプリケーション情報
  - `GET /health` - ヘルスチェック
  - `GET /api/users` - ユーザー一覧
  - `POST /api/users` - ユーザー作成
  - `GET /api/posts` - 投稿一覧

## 🔧 トラブルシューティング

### Terraform エラーの場合
- プロジェクト ID の確認
- 権限の確認 (Editor または Owner)
- ビリングアカウントの設定確認
- API の有効化状況確認
- Docker イメージの存在確認（Cloud Run デプロイ時）

### Cloud Run デプロイエラーの場合
- Docker イメージの確認
- 環境変数の設定確認
- サービスアカウントの権限確認

## 📝 補足事項

- 初回デプロイ時は Cloud SQL インスタンスの作成に時間がかかる場合があります
- Secret Manager にデータベース接続情報が自動的に保存されます
- VPC コネクタを使用してプライベート IP で Cloud SQL に接続します