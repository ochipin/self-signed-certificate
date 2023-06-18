自己署名証明書を作成するコンテナ
===
Dockerコンテナを利用して、自己署名証明書を作成する。

## git cloneでDockerfile・compose.ymlを取得する

```
$ git clone https://github.com/ochipin/self-signed-certificate
```

## コンテナビルド

```
$ docker compose --profile extra build
```
※ `direnv` も使うので、インストールしておくこと！

## 自己署名証明書を作成
以下コマンドを実行する。
```
$ docker compose run --rm -it openssl create-cert.sh
```

コマンドの実行結果が次のように出力されれば成功。
```
[+] Running 1/0
 ⠿ Network self-signed-certificate_default  Created  0.0s
Certificate request self-signature ok
subject=C = JP, ST = Tokyo, L = Higashikurume, O = SampleInc., OU = SampleInc., CN = localhost
Using configuration from /etc/ssl/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 0 (0x0)
        Validity
            Not Before: Jun 18 12:31:37 2023 GMT
            Not After : Jun 13 12:31:37 2043 GMT
        Subject:
            countryName               = JP
            stateOrProvinceName       = Tokyo
            organizationName          = SampleInc.
            organizationalUnitName    = SampleInc.
            commonName                = localhost
        X509v3 extensions:
            X509v3 Subject Alternative Name: 
                DNS:localhost, DNS:host.docker.internal, IP Address:127.0.0.1
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                B9:0C:14:06:36:59:BC:F5:11:40:E6:B1:AC:3A:8E:30:EB:1E:30:B1
            X509v3 Authority Key Identifier: 
                DirName:/C=JP/ST=Tokyo/L=Higashikurume/O=SampleInc./OU=SampleInc./CN=localhost
                serial:0E:5C:5E:9F:C1:3E:07:8D:A6:03:FC:7F:34:92:6D:E0:66:3D:15:6A
Certificate is to be certified until Jun 13 12:31:37 2043 GMT (7300 days)

Write out database with 1 new entries
Data Base Updated
```

`create-cert.sh` コマンドを実行すると、 `openssl/cacerts` ディレクトリ内にサーバ証明書・秘密鍵・ルート証明書の3つが作成される。

| ファイル名   | 説明 |
|:--         |:-- |
| cacert.pem | ルート証明書 |
| server.crt | サーバ証明書 |
| server.key | サーバ秘密鍵 |

※自己署名証明書は、本番環境では使用しないこと！
