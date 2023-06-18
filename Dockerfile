FROM alpine:3.18.2

LABEL maintainer "suguru.ochiai@ochipin.com"
LABEL version "1.0"

# OpenSSLインストール
RUN apk --no-cache add bash openssl && rm -rf /var/cache/apk/*

# コンテナ起動時の初期位置を '/' とする
WORKDIR /

# 証明書作成ツールをコピー
COPY create-cert.sh /usr/local/bin/create-cert.sh
# 実行権限を付与
RUN chmod +x /usr/local/bin/create-cert.sh
