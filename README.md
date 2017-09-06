## Janus Auth Server
This is a simple authentication server written in Ruby/Rack/Thin

### Some notes about setting up.

You are going to need a `config.yml` file which will contain your app secrets 
and it should look something like so...

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
  :pass_salt: <%= password_salt %>
  :token_algo: sha256
  :token_salt: <%= token_salt %>
  :token_name: JANUS_TOKEN
  :token_domain: <%= cookie_domain %>
  :token_life: 86400
  :token_seed_length: 128
  :log_file: <%= log_file_path %>

:test:
  :db:
    :adapter: postgres
    :host: localhost
    :database: janus_test
    :user: developer
    :password: <%= developer_password %>
    :search_path: [ private ]
  :pass_algo: sha256
  :pass_salt: <%= password_salt %>
  :token_algo: sha256
  :token_salt: <%= token_salt %>
  :token_name: JANUS_TOKEN
  :token_domain: <% cookie_domain %>
  :token_life: 86400
  :token_seed_length: 128
  :log_file: <%= log_file_path %>
```
If you want to use Postgres you may need to set the 'schema' with `:search_path:`.

### Notes about database setup.

See `./db/README.md`

### To start the Thin server.

```
$ cd /var/www/janus
$ thin start -d -a 127.0.0.1 -p 3000
```

### To stop the Thin server.

```
$ cd /var/www/janus
$ kill `cat tmp/pids/thin.pid`
```

### Notes for local development.
When I initially developed this application I was using a Linux VM under virtual box. Here are a few commands I needed to get going.

#### Install the Virtual Box Guest Tools in Debian

```
$ sudo apt-get install virtualbox-guest-additions-iso
$ sudo apt-get install virtualbox-guest-utils
```

#### Mount Janus folder in the VM
I was using a shared folder on the VM, here is how to mount that folder in the VM.

  `$ sudo mount -t vboxsf -o rw,uid=1000,gid=1000 janus /var/www/janus`

#### Enable symlinking for the shared project folder (using Virtual Box)
If you are running this application in a VM with a shared folder you will need run the VM Hypervisor as root AND will need to enable symlinking on the project folder to install the appropriate npm modules. Keep in mind that you run this command on the host; not the guest.

  `$ sudo VBoxManage setextradata [name of the VM] VBoxInternal2/SharedFoldersEnableSymlinksCreate/[name of the shared folder] 1`