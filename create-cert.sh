#!/bin/bash

# openssl.cnf ファイルを、 /etc/ssl へコピーする
cp -fp /openssl/openssl.cnf /etc/ssl/
echo "$ALT_NAMES" >> /etc/ssl/openssl.cnf

# 証明書置き場用のディレクトリを作成する
mkdir -p /etc/ssl/cacerts /etc/ssl/newcerts /etc/ssl/private

# まだルート証明書が発行されていない場合は、ルート証明書を発行する
if [[ ! -f /etc/ssl/cacert.pem ]]; then
    # 秘密鍵を生成する
    openssl genrsa -out /etc/ssl/private/cakey.pem 2048
    if [[ $? != 0 ]]; then
        echo error: openssl genrsa -out /etc/ssl/private/cakey.pem 2048
        exit 1
    fi

    # 環境変数から、CSRファイルに渡す値を生成する
    # ex) "/C=JP/ST=Tokyo/L=Higashi-Kurume/O=Sample inc./OU=Sample inc./CN=openldap"
    SUBJECT="/C=${COUNTRY_NAME}/ST=${STATE}/L=${LOCALITY_NAME}/O=${ORGANIZATION_NAME}/OU=${ORGANIZATION_UNIT}/CN=${COMMON_NAME}"
    # CSRファイルを生成する
    openssl req -new -key /etc/ssl/private/cakey.pem -out cacert.csr -subj "${SUBJECT}"
    if [[ $? != 0 ]]; then
        echo error: openssl req -new -key /etc/ssl/private/cakey.pem -out cacert.csr -subj "${SUBJECT}"
        exit 1
    fi

    # ルート証明書を発行する
    openssl x509 -days ${DAYS} -in cacert.csr -req -signkey /etc/ssl/private/cakey.pem -out /etc/ssl/cacert.pem
    if [[ $? != 0 ]]; then
        echo error: openssl x509 -days ${DAYS} -in cacert.csr -req -signkey /etc/ssl/private/cakey.pem -out /etc/ssl/cacert.pem
        exit 1
    fi
fi

# openssl.cnf の "database", "serial" 項目に沿って、認証局運用記録設定をする
if [[ ! -f /etc/ssl/index.txt ]]; then
    touch /etc/ssl/index.txt
fi
if [[ ! -f /etc/ssl/serial ]]; then
    echo 00 > /etc/ssl/serial
fi

# サーバ秘密鍵・証明書を作成する
openssl genrsa -out /etc/ssl/cacerts/server.key 2048
if [[ $? != 0 ]]; then
    echo error: openssl genrsa -out /etc/ssl/cacerts/server.key 2048
    exit 1
fi
openssl req -new -key /etc/ssl/cacerts/server.key -out server.csr -subj "${SUBJECT}"
if [[ $? != 0 ]]; then
    echo error: openssl req -new -key /etc/ssl/cacerts/server.key -out server.csr -subj "${SUBJECT}"
    exit 1
fi
openssl ca -batch -in server.csr -out /etc/ssl/cacerts/server.crt -days ${DAYS}
if [[ $? != 0 ]]; then
    echo error: openssl ca -batch -in server.csr -out /etc/ssl/cacerts/server.crt -days ${DAYS}
    exit 1
fi

# ルート証明書を cacerts ディレクトリ配下へコピーする
cp -pf /etc/ssl/cacert.pem /etc/ssl/cacerts/

# chown で権限を変更する
chown -R "${USER_ID}:${GROUP_ID}" /etc/ssl/cacerts/

# 各証明書を、openssl 配下にすべて移動する
rm -rf /openssl/cacerts
mv /etc/ssl/cacerts /openssl/cacerts/

# openssl x509 -text -noout -in server.crt で証明書情報を確認できる
# openssl rsa -text -noout -in server.key で秘密鍵情報を確認できる
# openssl req -text -noout -in server.csr でCSR情報を確認できる

# サーバ証明書とサーバ秘密鍵の整合性は次のコマンドで確認できる。同じ値であれば問題ない。
# openssl x509 -noout -modulus -in server.crt | md5sum
# openssl rsa -noout -modulus -in server.key | md5sum

# サーバ証明書とルート証明書は次のコマンドで確認できる。同じ値であれば問題ない。
# openssl x509 -issuer_hash -noout -in server.crt
# openssl x509 -subject_hash -noout -in cacert.pem
