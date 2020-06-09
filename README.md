# Janus Auth Server
Janus is an authentication and identity service for Etna applications. It is based on the [etna](https://github.com/mountetna/etna) gem.

Janus implements the basic user and project structure of Etna applications.

## Users

A Janus user is primarily identified by an email address. You may add users via the `bin/janus add_user` command.

See below on how users may authenticate.

## Projects

A 'project' is the entity that produced a particular data set. You may add projects using the `bin/janus add_project` command. Generally Etna applications communicate using the `project_name` and rarely `The Full Name of the Project`.

## Permissions

Users are granted specific permissions on each project. A permission consists of:
  * user
  * project
  * role - either of `[ 'administrator', 'editor', 'viewer' ]`
  * restricted - true if the user can see the project's restricted data

You may add permissions using the `bin/janus permit` command.

# Identification

Janus provides identity by yielding a JSON web token (JWT). Client applications may verify this token using Janus's public key, most likely through the Etna::Auth rack middleware.

The token format is: `<header>.<params>.<signature>`

Each section is a base64-encoded JSON hash. The params Janus reports are: `{ email, first, last, perm }` - the latter encodes the user's project permissions.

# Authenticating

There are three ways to get a token:

## Password login

The endpoint `/login` can be configured to display an HTML form for password entry. If successful, Janus will set a cookie with the token in the response. This endpoint is mostly useful for developers.

## Shibboleth login

The `/login` endpoint can also be configured as a Shibboleth-protected endpoint for authentication. If successful, Janus will set a cookie with the token in the response. This endpoint is most suitable for browser applications. To use this method for authentication, set `auth_method: shibboleth` in the configuration.

## Public-key login

Machine users who cannot use browsers can use a registered public key to generate a token.

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
  :db:
    :database: janus
    :host: localhost
    :adapter: postgres
    :encoding: unicode
    :username: developer
    :password: <%= @psql_developer_password %>
    :pool: 5
    :timeout: 5000

    # We recommend using a search path that is not 'public' (for postgres only).
    :search_path: [private]

  # How Janus should generate passwords (using Etna::SignService).
  :pass_algo: sha256
  :pass_salt: <%= @janus_password_salt %>

  # Token generation options.
  :token_domain: ucsf.edu
  :token_life: 86400
  :token_algo: RS256
  :token_name: <%= @janus_token_name %>

  :log_level: debug
  :log_file: '<%= @log_file %>'

  # Janus private key (used to generate the user token).
  :rsa_private: |
<%= @rsa_private %>

  # Janus public key. This is required in the config.yml files of other
  # servers/apps that use the etna gem. We keep it here for reference.
  :rsa_public: |
<%= @rsa_public %>
```

## Generating keys

Janus relies on a RSA public and private key pair. You may generate keys in PEM
format using the command `bin/janus generate_key_pair <key_size>`.

# User and Project Setup

## Via Command line

### Creating a user

You may add a new user with the `add_user` command. The primary identifier for
a user is an email address. They may also have a first and last name. You may optionally set a password here.

### Setting a public key

Some users will want to set a public key to allow them to generate a janus token via the `/generate` endpoint (see above). You may set this key using the `add_user_key` command and a public key file. Keys must be in PEM format and must be RSA keys.

### Creating a project

You may add a new project with the `add_project` command.  The project_name is `snake_cased` and is the primary referrent for the project throughout Etna applications.  Most Etna applications will not acknowledge a project if there is no corresponding Janus project entry.

### Adding permissions

Each user has a permission for a project. You may add a permission using the `permit` command. Each permission consists of a role (`administrator`, `editor`, or `viewer`) and whether or not the user can see `restricted` data.

## Via web portal

Project permissions may be managed for each user by browsing to `JANUS_HOST/project/:project_name`, e.g. https://janus.example.org/project/my_project. This page includes forms to alter roles and privileged data access for each user in your project, disable a user's access to your project, or add a new user to the project with a given role.

## Development with Docker

Most mountetna projects include docker-compose files that run their respective services in isolation, but janus
is unique in that *it composes* all the other mountetna docker-compose files and runs them all as one group.

This all works through the `Makefile`'s management of the `composed.yml` file.

### Useful commands

* `make help` shows all make file commands.
* `make up` brings up any services not currently running.  Requires `metis` to be checked out next to the `janus` folder.
* `make down` bring all services down.
* `make logs`  shows recent logs in all services
* `make console` opens an irb session in the janus app context
* `make bash` opens a bash session in the janus bash context.

### Local DNS / config.yml

To make authorization redirects and ssl work, you'll need to adjust your system's `hosts` resolution.  Depending on what type of system you have
you'll need to edit one of `dnsmasq`, `/etc/hosts`, `systemd-resolved` or `c:\windows\system32\drivers\etc\hosts`

You'll want entries for `janus.development.local` and `metis.development.local` pointing to localhost.

docker-compose will run the `caddy` webserver to provide ssl to inside the docker services.
However, ssl is provided via self signed certificates.  You'll need to add the `certs/rootCA.pem` file
to your system's trusted root CA store, or add an exception to your browser.

Adding new services involves using `mkcert` to create new domain certs into the `certs` directory,
and adding a new entry to `Caddyfile` tying the cert, the subdomain, and the docker-internal url.
