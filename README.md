# AWS (EC2/RDS/ALB) への Rails アプリケーションデプロイ手順

Terraform で構築された AWS インフラ環境に対し、Rails アプリを手動でセットアップしてブラウザで閲覧可能にするまでの全手順をまとめたものです。

## 1. インフラ環境への接続

ローカル PC のターミナルから EC2 インスタンスへ SSH 接続します。

```bash
ssh -i ~/.ssh/[YOUR_KEY_NAME].pem ec2-user@[EC2_PUBLIC_IP]

```

## 2. システムパッケージとミドルウェアのインストール

Amazon Linux 2023 に必要なビルドツールとライブラリを導入します。

```bash
# リポジトリの更新
sudo dnf update -y

# Gitのインストール
sudo dnf install -y git

# MySQL 8.4 クライアントの導入（RDS接続確認用）
sudo dnf -y install https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
sudo dnf -y install mysql mysql-community-client

# Ruby開発用ツール、Gemビルド用ライブラリのインストール
sudo dnf install -y ruby-devel gcc make mysql-community-devel libxml2-devel libxslt-devel libyaml-devel

```

## 3. アプリケーションのクローン

```bash
cd /home/ec2-user
git clone https://github.com/[YOUR_GITHUB_ACCOUNT]/first_app.git
cd first_app

```

## 4. 環境の整合性修正

EC2 の Ruby バージョン（3.2.8）に合わせて設定ファイルを書き換えます。

```bash
# Rubyバージョンの固定
echo "3.2.8" > .ruby-version

# GemfileのRubyバージョン指定を修正
sed -i 's/ruby "3.2.0"/ruby "3.2.8"/' Gemfile

```

## 5. Bundler のセットアップとライブラリ導入

権限エラーを避けるため、Gem はプロジェクト内の `vendor/bundle` にインストールします。

```bash
# Bundlerのインストール（ローカルのGemfile.lockに合わせる）
gem install bundler -v 2.4.1 --user-install

# bundleコマンドにパスを通す
export PATH=$PATH:$(ruby -e 'print Gem.user_dir')/bin

# インストールパスの設定と実行
bundle config set --local path 'vendor/bundle'
bundle install

```

## 6. Rails 設定ファイルの修正

RDS 接続情報とセキュリティ設定を更新します。

### 6-1. DB接続設定 (`config/database.yml`)

`vi config/database.yml` を開き、RDS のエンドポイントを入力します。

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  database: rails_db
  username: root
  password: [YOUR_RDS_PASSWORD]
  host: [RDS_ENDPOINT_URL]

```

### 6-2. ホスト許可設定 (`config/environments/development.rb`)

`vi config/environments/development.rb` を開き、ALB 経由のアクセスを許可します。

```ruby
Rails.application.configure do
  # 全てのホストを許可（DNS Rebinding保護の回避）
  config.hosts.clear
  # ...
end

```

## 7. データベースの初期化とマイグレーション

RDS 側にテーブルを作成します。

```bash
bundle exec rails db:migrate

```

## 8. Rails サーバーの起動

ALB からのトラフィックを受け取るため、ポート 3000、バインド 0.0.0.0 で起動します。

```bash
# 古いプロセスがある場合は終了させる
sudo pkill -f puma

# 起動
bundle exec rails s -p 3000 -b 0.0.0.0

```

---

## 学習したトラブルシューティング

| 事象 | 原因 | 対策 |
| --- | --- | --- |
| `PermissionError` | `/usr/share` への書き込み権限不足 | `path 'vendor/bundle'` を指定 |
| `yaml.h not found` | `libyaml-devel` パッケージ不足 | `dnf install` で解決 |
| `Blocked hosts` | Rails のホスト認証機能 | `config.hosts.clear` を設定 |
| `NoDatabaseError` | RDS への接続設定が未完了 | `database.yml` の `host` を修正 |

---

*Created at: 2026-02-10*