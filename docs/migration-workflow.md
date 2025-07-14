# マイグレーションワークフロー

## 新しいマイグレーションを作成・適用する手順

### 1. 開発フェーズ

```bash
# 1. スキーマを変更
vim src/db/schema.ts

# 2. マイグレーションファイル生成
make db-generate

# 3. ローカル環境で確認
make docker-up
make db-migrate
make dev

# 4. APIの動作確認
curl http://localhost:8080/api/users
```

### 2. 本番適用フェーズ

```bash
# 1. アプリケーションのデプロイ（新しいスキーマ定義込み）
export PROJECT_ID=spike-cloud-run
make deploy

# 2. 本番データベースにマイグレーション適用
make db-migrate-prod

# 3. 動作確認
curl https://your-service-url/health
```

## 重要な注意事項

### 📋 マイグレーション前のチェックリスト

- [ ] ローカル環境でマイグレーションが正常に動作することを確認
- [ ] APIの動作確認（既存機能が壊れていないか）
- [ ] 本番データのバックアップ（Cloud SQLの自動バックアップが有効）

### ⚠️ 危険な操作

- **DROP COLUMN**: データ損失の可能性
- **データ型変更**: 互換性のない変更
- **NOT NULL制約追加**: 既存データがNULLの場合

### 🔄 ロールバック

万が一問題が発生した場合：

1. **アプリケーションのロールバック**
   ```bash
   # 前のバージョンのイメージを再デプロイ
   ```

2. **データベースのリストア**
   ```bash
   # Cloud SQLの自動バックアップから復元
   gcloud sql backups list --instance=spike-cloud-run-postgres
   ```

## 自動化の改善案

将来的には以下のような自動化も検討できます：

- GitHub Actionsでのマイグレーション自動実行
- TerraformでのマイグレーションJob管理
- Slack通知付きのマイグレーション完了通知