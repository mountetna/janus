## Janus Auth Server

### Mount Janus on VM

  `$ sudo mount -t vboxsf -o rw,uid=1000,gid=1000 janus /var/www/janus`

### To start the Thin server.

  `$ cd /var/www/janus`
  `$ thin start -d`

### To stop the Thin server.

  `$ cd /var/www/janus`
  `$ kill \`cat tmp/pids/thin.pid\``

## Notes for local development.

  I like to run a VM with the project folder being shared. That way I can develop with all of my tools and run the project quite close to a deployment setup. I tend to use VirtualBox but there are a few items to consider.

  First you should install the Virtual Box Guest Tools.

  `$ sudo apt-get install virtualbox-guest-additions-iso`
  `$ sudo apt-get install virtualbox-guest-utils`

  When installing npm modules into the shared folder you will get errors. NPM needs to make symlinks in the shared folder. However, Virual Box prevents creating symlinks for security reasons. So you need to...

### Enable symlinking for the shared project folder (using Virtual Box)

  If you are running this application in a VM with a shared folder you will need run the VM Hypervisor as root AND will need to enable symlinking on the project folder to install the appropriate npm modules. Keep in mind that you run this command on the host; not the guest.

      `$ sudo VBoxManage setextradata [name of the VM] VBoxInternal2/SharedFoldersEnableSymlinksCreate/[name of the shared folder] 1`

  ex: `$ sudo VBoxManage setextradata janus-dev VBoxInternal2/SharedFoldersEnableSymlinksCreate/janus 1`

### Mount the shared folder onto the guest system.

  Run this command on the guest.

      `$ sudo mount -t vboxsf -o rw,uid=1000,gid=1000 [name of the folder to virtual box] [guest mount directory/point]`
  ex: `$ sudo mount -t vboxsf -o rw,uid=1000,gid=1000 janus /var/www/janus`

