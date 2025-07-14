# spike-cloud-run

Cloud Run + Cloud SQL の構成で Hono + Drizzle による DB アクセスとマイグレーションを試すサンプルリポジトリです。

## 技術スタック

- **Runtime**: Node.js 18+ + TypeScript
- **Web Framework**: Hono
- **ORM**: Drizzle ORM
- **Database**: PostgreSQL (Cloud SQL)
- **Infrastructure**: Terraform
- **Deployment**: Cloud Run
- **Container**: Docker

## 機能

- ユーザー管理 API (`/api/users`)
- 投稿管理 API (`/api/posts`)
- データベースマイグレーション
- Terraform による GCP リソース管理
- Docker による開発環境

## 開発環境のセットアップ

### 1. 依存関係のインストール

```bash
make install
# または
npm install
```

### 2. 環境変数の設定

```bash
cp .env.example .env
# .env ファイルを編集
```

### 3. 開発用データベースの起動

```bash
make docker-up
# または
docker-compose up -d
```

### 4. データベースマイグレーション

```bash
make db-generate
make db-migrate
# または
npm run db:generate
npm run db:migrate
```

### 5. 開発サーバーの起動

```bash
make dev
# または
npm run dev
```

アプリケーションは `http://localhost:8080` で利用可能です。

## API エンドポイント

### ユーザー管理

- `GET /api/users` - ユーザー一覧取得
- `GET /api/users/:id` - ユーザー詳細取得
- `POST /api/users` - ユーザー作成
- `PUT /api/users/:id` - ユーザー更新
- `DELETE /api/users/:id` - ユーザー削除

### 投稿管理

- `GET /api/posts` - 投稿一覧取得
- `GET /api/posts/:id` - 投稿詳細取得
- `POST /api/posts` - 投稿作成
- `PUT /api/posts/:id` - 投稿更新
- `DELETE /api/posts/:id` - 投稿削除

### その他

- `GET /` - アプリケーション情報
- `GET /health` - ヘルスチェック

## GCP へのデプロイ

### 1. Terraform によるインフラストラクチャの構築

```bash
# terraform/terraform.tfvars.example を参考に terraform.tfvars を作成
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# terraform.tfvars を編集

# インフラストラクチャをデプロイ
make terraform-deploy
# または
./scripts/terraform-deploy.sh
```

### 2. アプリケーションのデプロイ

```bash
# 環境変数を設定
export PROJECT_ID=your-gcp-project-id
export REGION=asia-northeast1

# デプロイ実行
make deploy
# または
./scripts/deploy.sh
```

## 開発用コマンド

```bash
# 開発
make dev                    # 開発サーバー起動
make build                  # ビルド
make test                   # テスト実行
make lint                   # Linter 実行
make format                 # コードフォーマット

# データベース
make db-generate            # マイグレーションファイル生成
make db-migrate             # マイグレーション実行
make db-studio              # Drizzle Studio 起動

# Docker
make docker-up              # Docker 起動
make docker-down            # Docker 停止
make docker-dev             # 開発用 Docker 起動
make docker-logs            # Docker ログ表示
make docker-clean           # Docker クリーンアップ

# Terraform
make terraform-init         # Terraform 初期化
make terraform-plan         # Terraform プラン確認
make terraform-apply        # Terraform 適用
make terraform-destroy      # Terraform リソース削除

# デプロイ
make deploy                 # Cloud Run デプロイ
make terraform-deploy       # Terraform デプロイ

# クリーンアップ
make clean                  # ビルド成果物削除
```

## ディレクトリ構成

```
spike-cloud-run/
├── src/
│   ├── db/
│   │   ├── schema.ts           # Drizzle スキーマ定義
│   │   ├── connection.ts       # データベース接続設定
│   │   └── migrations/         # マイグレーションファイル
│   ├── routes/
│   │   ├── users.ts            # ユーザー関連 API
│   │   └── posts.ts            # 投稿関連 API
│   ├── index.ts                # メインアプリケーション
│   └── migrate.ts              # マイグレーション実行スクリプト
├── terraform/
│   ├── main.tf                 # Terraform メイン設定
│   ├── variables.tf            # Terraform 変数定義
│   ├── outputs.tf              # Terraform 出力定義
│   └── terraform.tfvars.example # Terraform 変数例
├── scripts/
│   ├── deploy.sh               # Cloud Run デプロイスクリプト
│   └── terraform-deploy.sh     # Terraform デプロイスクリプト
├── docker-compose.yml          # 本番用 Docker Compose
├── docker-compose.dev.yml      # 開発用 Docker Compose
├── Dockerfile                  # Docker イメージ定義
├── drizzle.config.ts          # Drizzle 設定
├── Makefile                   # 開発コマンド定義
└── README.md                  # このファイル
```

## トラブルシューティング

### データベース接続エラー

1. PostgreSQL が起動していることを確認
2. 環境変数 `DATABASE_URL` が正しく設定されていることを確認
3. データベースマイグレーションが実行されていることを確認

### Cloud Run デプロイエラー

1. GCP プロジェクトが正しく設定されていることを確認
2. 必要な API が有効になっていることを確認
3. サービスアカウントの権限が適切に設定されていることを確認
4. **重要**: Apple Silicon Mac では `--platform linux/amd64` でビルドする

### Terraform エラー

1. `terraform.tfvars` が正しく設定されていることを確認
2. GCP 認証情報が正しく設定されていることを確認
3. プロジェクトに必要な権限があることを確認
4. ビリングアカウントが設定されていることを確認
5. Docker イメージが事前にプッシュされていることを確認

## 成功例

### Cloud Run URL

- **本番環境**: `https://your-service-name-[project-number].asia-northeast1.run.app`
- **ヘルスチェック**: `https://your-service-name-[project-number].asia-northeast1.run.app/health`

> 実際のURLはデプロイ後に `gcloud run services list` で確認できます

## ライセンス

MIT License
