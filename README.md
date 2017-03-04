## Janus Auth Server
This is a simple authentication server written in Ruby/Rack/Thin

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