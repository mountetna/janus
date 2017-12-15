## Janus Auth Server
This is a simple authentication server written in Ruby/Rack/Thin

### Configuration

Janus is an Etna application and puts all of its configuration into a `config.yml`. Example:

`./config.yml`

```
---
:development:
  :db:
    :adapter: postgres
    :host: localhost
    :database: janus
    :user: developer
    :password: <%= developer_password %>
    :search_path: [ private ]
  :pass_algo: sha256
  :pass_salt: <password_salt>
  :token_algo: sha256
  :token_salt: <token_salt>
  :token_name: JANUS_TOKEN
  :token_domain: <cookie_domain>
  :token_life: 86400
  :token_seed_length: 128
  :log_file: <log_file_path>

:test:
  :db:
    :adapter: postgres
    :host: localhost
    :database: janus_test
    :user: developer
    :password: <developer_password>
    :search_path: [ private ]
  :pass_algo: sha256
  :pass_salt: <password_salt>
  :token_algo: sha256
  :token_salt: <token_salt>
  :token_name: JANUS_TOKEN
  :token_domain: <cookie_domain>
  :token_life: 86400
  :token_seed_length: 128
  :log_file: <log_file_path>
```

If you want to use Postgres you may need to set the 'schema' with `:search_path:`.

# Authenticating

Janus authenticates by yielding a JSON web token (JWT).
Client applications may verify this token using Janus's
public key, most likely through the Etna::Auth rack
middleware.

There are two ways to get a token:

## Logins

The endpoint `/login` will either display an HTML form for password entry or send you to a Shibboleth-protected endpoint for authentication. If successful, Janus will set a cookie with the token in the response. This endpoint is most suitable for browser applications.

## Generating a token

Machine users who hold no truck with browsers can use a registered public key to generate a token.

The endpoint `/time-signature` returns a cryptographic nonce. The user signs the nonce, base64-encodes the signature, and concatenates the result to the nonce.

The endpoint `/generate` returns a valid token if the `Authorization` header is set to the appropriate value.

Here is a bash script that will successfully generate a Janus token on most systems (you need 'openssl', 'wget' and 'base64' utilities).

```
#!/bin/bash

# The base URL for janus
JANUS_URL=$1
# Your secret key file in PEM format
PEM=$2
# Your email address
EMAIL=$(echo -n $3 | base64 -w 0)

NONCE=$(wget -q -O - $JANUS_URL/time-signature)

SIG=$(echo -n $NONCE.$EMAIL | openssl dgst -sha256 -sign $PEM | base64 -w 0)

AUTH=$NONCE.$EMAIL.$SIG

TOKEN=$(wget -q -O - --header="Authorization: Basic $AUTH" $JANUS_URL/generate )

echo $TOKEN
```
