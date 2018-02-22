# Janus Auth Server
Janus is an authentication and identity service for Etna applications. It is
based on the [etna](https://github.com/mountetna/etna) gem.

Janus implements the basic user and project structure of Etna applications.

## Users

A Janus user is primarily identified by an email address. You may
add users via the `bin/janus add_user` command.

See below on how users may authenticate.

## Projects

A 'project' is the entity that produced a particular data set.
You may add projects using the `bin/janus add_project` command.
Generally Etna applications communicate using the
`project_name` and rarely `The Full Name of the Project`.

## Permissions

Users are granted specific permissions on each project. A permission consists of:
  * user
  * project
  * role - either of `[ 'administrator', 'editor', 'viewer' ]`
  * restricted - true if the user can see the project's restricted data

You may add permissions using the `bin/janus permit` command.

# Identification

Janus provides identity by yielding a JSON web token (JWT).  Client
applications may verify this token using Janus's public key, most likely
through the Etna::Auth rack middleware.

The token format is: `<header>.<params>.<signature>`

Each section is a base64-encoded JSON hash. The params Janus reports are: 
`{ email, first, last, perm }` - the latter encodes the user's project
permissions.

# Authenticating

There are three ways to get a token:

## Password login

The endpoint `/login` can be configured to display an HTML form for password
entry. If successful, Janus will set a cookie with the token in the response.
This endpoint is mostly useful for developers.

## Shibboleth login

The `/login` endpoint can also be configured as a Shibboleth-protected endpoint
for authentication. If successful, Janus will set a cookie with the token in
the response. This endpoint is most suitable for browser applications.

## Public-key login

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

TOKEN=$(wget -q -O - --header="Authorization: Signed-Nonce $AUTH" $JANUS_URL/generate )

echo $TOKEN
```

# Configuration

Janus is an Etna application and puts all of its configuration into a `config.yml` YAML file.

Example:

`./config.yml`

```
---
:development:

  # db connection made using sequel + pg gems,
  # see those for options

  :db:
    :adapter: postgres
    :host: localhost
    :database: janus
    :user: developer
    :password: <%= developer_password %>

    # We recommend using the 'private' search path
    :search_path: [ private ]

  # How Janus should generate passwords (using Etna::SignService)
  :pass_algo: sha256
  :pass_salt: <password_salt>

  # Token generation options
  :token_algo: sha256
  :token_name: JANUS_TOKEN
  :token_domain: <cookie_domain>
  :token_life: 86400

  # Janus private key
  :rsa_private: |
    -----BEGIN RSA PRIVATE KEY-----
    TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBp\nc2
    NpbmcgZWxpdA==
    -----END RSA PRIVATE KEY-----

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

## Generating keys

Janus relies on a RSA public and private key pair. You may generate keys in PEM
format using the command `bin/janus generate_key_pair <key_size>`.

# User and Project Setup

## Creating a user

You may add a new user with the `add_user` command. The primary identifier for
a user is an email address. They may also have a first and last name. You may optionally
set a password here.

### Setting a public key

Some users will want to set a public key to allow them to generate a janus token via
the `/generate` endpoint (see above). You may set this key using the `add_user_key` command and a public key file. Keys must be in PEM format and must be RSA keys.

## Creating a project

You may add a new project with the `add_project` command.  The project_name is
`snake_cased` and is the primary referrent for the project throughout Etna
applications.  Most Etna applications will not acknowledge a project if there
is no corresponding Janus project entry.

## Adding permissions

Each user has a permission for a project. You may add a permission using the `permit` command.
Each permission consists of a role (`administrator`, `editor`, or `viewer`) and whether or not the user can see `restricted` data.
