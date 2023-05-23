<p align="center"><strong>Obsidicrypt</strong> is the method used to encrypt, sandbox and sync your Obsidian notes.</p>

<p align="center">•• <a href="#key-features">Key Features</a> • <a href="#downsides">Downsides</a> • <a href="#threat-model">Threat Model</a> • <a href="#requirements">Requirements</a> • <a href="#setting-up">Setting Up</a> • <a href="#alternatives">Alternatives</a> • <a href="automation">Automation</a> ••</p>

## Key Features
- Completely encrypt your Obsidian vault
    - [CryFs](https://github.com/cryfs/cryfs)
    - [gocryptfs](https://github.com/rfjakob/gocryptfs)
- Sandbox Obsidian via [firejail](https://github.com/netblue30/firejail)
- Sync your encrypted notes to your prefered cloud hosting site
    - GitHub
    - Dropbox
    - Google Drive
- Block X11 keylogging
    - [Xpra](https://github.com/Xpra-org/xpra)
    - [Xephyr](https://wiki.archlinux.org/title/Xephyr)
- Completely or selectively block and monitor incoming and outgoing traffic from Obsidian via [fdns](https://github.com/netblue30/fdns)

## Downsides
- Tested on Fedora only
- May work on MacOs
- Does not work in Windows
- Concrete security not guaranteed when selectively blocking via [fdns](https://github.com/netblue30/fdns)

## Threat Model
When only using encryption, all notes are protected from remote or physical access; unless accessed when filesystem was mounted or passwords were leaked. However, Obsidian must be run with no internet access or with restricted internet access in order to block any potentially malicious connections. Please note that any other malicious application running on your computer unchecked might be able to access the notes when the filesystem is mounted.

When using encryption and sanboxing, all notes are protected from remote and physical access and Obsidian has no access to any other content in your computer. The only folders that Obsidian can access are your note folders. You are able to fully restrict internet connection to Obsidian.

When using encryption and syncing, make sure that the sync service you are using has no access to the mounted folder. Also preferably do not sync your config file to the cloud. During this scenario, the cloud provider has full access to your encrypted files, so make sure to not leak your encryption password anywhere.

When using encryption, sandboxing and selective internet traffic, Obsidian has access to your unencrypted files and the internet. Although this connection is whitelisted, I cannot guarantee that it cannot be bypassed. This method is effective against protecting the notes against malicious plugins uploading your data, but again, I cannot guarantee that they do not do so from the whitelisted websites. Additionally, there are several ways to bypass this, such as harcoded IP addresses and seperate resolver libraries, so it is not as secure as simply restricting your internet connection.

Please also note that there may be security vulnerabilities with the encryption software itself, even if unlikely.

## Requirements

#### Encryption Software
If you wish to encrypt your files, you will have to install an encryption software. There are many options, but I would recommend the following three.

##### [CryFs](https://github.com/cryfs/cryfs)
CryFs is the encryption software that I would recommend using. It is designed for cloud storage, and hides the file and folder hierarchy, contents, sizes and names. Please note that there have been no security audits done, however you can find a masters paper on [CryFs encryption published](https://www.cryfs.org/cryfs_mathesis.pdf).

##### [gocryptfs](https://github.com/rfjakob/gocryptfs)
gocryptfs is similar to CryFs in the sense that they can be both used for cloud encryption. However, gocryptfs does not hide the file and folder hierarchy and sizes. You can find the security audit done on gocryptfs here: https://defuse.ca/audits/gocryptfs.htm

#### [Obsidian](https://obsidian.md/)
There are multiple ways to install Obsidian, but I would recommend using the AppImage. Note that if you use a Flatpak, you will be unable to use firejail and fdns.

#### [Firejail](https://github.com/netblue30/firejail)
Firejail is needed in order to sandbox Obsidian, to prevent it from reading other folders, connecting to the internet and more. Firejail is avaliable on most distros.

#### [fdns](https://github.com/netblue30/fdns)
fdns is needed if you wish to create a dns server for your firejail sandbox.

#### X11 Servers
If you are on X11, when running an application, other malicious applicatons may be able to log your keys. To prevent this, you can use Xpra or Xephyr when running the Obsidian sandbox. 

##### [Xpra](https://github.com/Xpra-org/xpra)
I personally recommend Xpra for Obsidian because you will be able to resize your windows, and generally the performance with Xephyr is the same. However, Xephyr boots up much faster compared to Xpra.

##### [Xephyr](https://freedesktop.org/wiki/Software/Xephyr/)
Xephyr's boot time is much faster compared to Xpra when running Obsidian, however you will not be able to resize your windows size after starting Obsidian. You may try to run Xephyr with openbox, thus being able to resize the Obsidian window, but you wont be able to resize the Xephyr window.


## Setting Up
This setting up guide assumes a lot of things, mainly: you are using Fedora, X11, want to encrypt your files with CryFs, want to sync your encrypted folders to GitHub, want to sandbox Obsidian via firejail and want to use fdns to whitelist internet connections. Even though that is a lot of assumptions, hopefully you will be able to extrapolate this onto your own setup.

### Installing Obsidian
You can download the Obsidian AppImage directly from https://obsidian.md/. After downloading, make the AppImage executable and place it to /opt/. Assuming the file name is Obsidian-1.2.8.AppImage, 

```sh
chmod u+x /path/to/Obsidian-1.2.8.AppImage
sudo mv /path/to/Obsidian-1.2.8.AppImage /opt/Obsidian-1.2.8.AppImage
```

### Creating Encryption
Install Cryfs using

```sh
sudo dnf install cryfs
```

I usually store my encrypted folders in the `~/.enc` directory. Let us assume that the `~/Vault` directory is where the filesystem is going to be mounted. Firstly, we need to create the encrypted filesystem using 

```sh
cryfs ~/.enc/encrypted_vault ~/Vault
```

When creating the filesystem, CryFs will ask whether to use default or custom settings. I recommend using custom settings. The first question will be about which block cipher you want to use. This is completly up to you. The second question will be about the block size. CryFs hides the file and folder hierarchy, and it does it so by seperating all of them into smaller blocks. The block size denotes the size of each individual block that will be created. For example, with the block size being 4KB, if you have an 8KB file, that would be seperated into 2 blocks. However, if you have a 1KB file, that would still be encrypted using a block of size 4KB. Since markdown files are each usually under a KB, I use the smallest block size of 4KB. You can find the average file size in a directory by running

```sh
find ./ -ls | awk '{sum += $7; n++;} END {print sum/n;}'
```
This command will output the average file size in a directory. If you have certain files that are much bigger than average, you can use the following command 

```sh
find ./ -size -100000c -ls | awk '{sum += $7; n++;} END {print sum/n;}'
```
This command will ignore files with file size greater than 100KB. 

After deciding on your block size, the next question will be about treating missing blocks as integrity violations. I recommend you say no to this option if you are going to be using something to sync the encrypted folders. 

Finally, create a good strong password, a chain is as strong as its weakest link!

Now the filesystem should be mounted on `~/Vaults`. If you travel to `~/.enc/encrypted_vault` you might see that there is a new file called `cryfs.config` there. I recommend that you do not sync this file.

To unmount the filesystem, simply run

```sh
cryfs-unmount ~/Vault
```

### Creating a Git Repository
Creating the git repository is as simple as 

```sh
cd ~/.enc/encrypted_vault
git init
```
Do not forget to create your .gitignore file with `cryfs.config` inside!

```sh
touch .gitignore
echo cryfs.config >> .gitignore
git add .gitignore
git commit -m "Created .gitignore"
```

To sync it with your GitHub repository, 

```sh
git branch -M main
git remote add origin https://github.com/yourusername/yourreponame.git
git push -u origin main
```

### Using Firejail to sandbox
Install firejail using 

```sh
sudo dnf install firejail
```

Try running `firejail` to see what you get as output. Your terminal window should be reloaded and your terminal should now be running with firejail. If you try to use `sudo` you will see the permission denied error message. After exiting, you should also see the parent is shutting down message. To make Obsidian work with firejail, you need to create a special configuration for it. The configuration is in this repository.

Either you can locate the `/etc/firejail` folder, or you can simply create `~/.config/firejail` and copy the profile. Be sure to edit the `obsidian.profile` file according to your own Vault location, and whether you want internet access or not. Please read the instructions in the `obsidian.profile` file.

To run Obsidian without doing anything about the X11 issues, just type

```sh
firejail --appimage --profile=/.config/firejail/obsidian.profile /opt/Obsidian-1.2.8.AppImage
```

Obsidian should be running now, albeit restricted. Notice that there are no precautions against X11 keylogging, or plugins stealing your precious notes.

### Setting up Xpra
To install Xpra, simply run

```sh
sudo dnf install
```

Now when running Obsidian, use 

```sh
firejail --x11 --appimage --profile=/.config/firejail/obsidian.profile /opt/Obsidian-1.2.8.AppImage
```

You will see that Xpra starts before Obsidian does, and there are almost no noticeble differences, except of course, the lack of hardware acceleration. You might notice horrendous performance when opening the graph, for instance. That is to be expected. So if you can, just use Wayland.

### Setting up fdns
By now, your system should be pretty solid. These next steps are optional if you just want to restrict internet connection. 

To install fdns, just follow the instructions on https://firejaildns.wordpress.com/download/. After fdns is installed, you should test it by running

```sh
sudo fdns
```
If there were no problems during installation, you should be able to see the fdns logging screen. If you wish, you can run `fdns --monitor` to monitor the DNS. To create a whitelist file, I recommend placing the whitelist file in `/usr/local/etc/fdns/`. You can simply copy the whitelist file in the repository.

```sh 
sudo mv /path/to/whitelist /usr/local/etc/fdns/whitelist
```

Note that the whitelist file in this repository contains github, to allow Obsidian and the plugins to update themselves. Now, to run the fdns with the whitelist, use

```sh
sudo fdns --whitelist-file=/usr/local/etc/fdns/whitelist
```

And your fdns server is ready! Good job if you came until here. The next step is to integrate fdns with firejail. It is nothing too difficult.

### Integrating fdns and firejail
Decide on which port fdns should work. If you plan to use it fdns in your web browser for example, I would recommend you use 

```sh
sudo fdns --proxy-addr=127.2.2.2 --whitelist-file=/usr/local/etc/fdns/whitelist --daemonize
```

Which will run fdns on `127.2.2.2:53`. Notice the `--daemonize` parameter. It is used to seperate the process from the terminal. Now to use your newly found fdns with Obsidian, simply issue the command 

```sh
firejail --x11 --appimage --profile=/.config/firejail/obsidian.profile --dns=127.2.2.2 /opt/Obsidian-1.2.8.AppImage
```

Now, Obsidian will be using fdns to communicate with the outside world. In the case that it does not work, ensure that you blacklist the output of 

```sh
ldconfig -p | grep libnss_resolve.so.2
```

If you asked me how this worked, I would have no idea. Ask [rusty-snake](https://github.com/rusty-snake). I am guessing it has something to do with `systemd-resolved`.

Remember that the default proxy address for fdns is 127.1.1.1. 

### Symlink Addendum
I do not like syncing my `.obsidian` folder, at least not all of it. Some of the plugins I have create incredible merge conflict all the time, and since the filesystem is encrypted, even the smallest merge conflict might turn into an unmanageable mess. To fix this issue, I simply moved the `.obsidian` folder outside of `~/Vault`. After mounting the filesystem, I just create a symlink between the `.obsidian` folder and `~/Vaults`, and remove it before unmounting the filesystem. 

## Alternatives

### Encryption Software
You can definetly use any encryption software you would like, so this will be completly up to you. If you want to store your files on the cloud, make sure that the encryption software is compatible with cloud syncing. 

### Obsidian
If you have the time, patience and effort avaliable, use emacs.

### Sandboxing
You can checkout [bubblewrap](https://github.com/containers/bubblewrap), the sandboxing used by flatpaks. If you download Obsidian as a flatpak you have quite a lot of options to control, such as file access control, shutting off internet access, and more. 

### X11 Server
You can use Xephyr, although it is a bit trickier to use compared to Obsidian. The performance is roughly the same. Xephyr lacks the ability to change window sizes, so you are stuck with what you start. You can change the default window size in `/etc/firejail/firejail.config` on line 153, there are multiple resolutions to choose from and you can create your own.

### fdns
Instead of using fdns to restrict connections, you might want to checkout something like a system wide firewall, an option being[OpenSnitch](https://github.com/evilsocket/opensnitch). It works very well, I would recommend having this even if you have fdns installed.

## Automation
Since this whole process would take a lot of time each time you want to simply write a note, I created a zsh function that would allow you to automate most of the process. It is titled `ob.zsh`. Simply copy the function to your `.zshrc` or create a seperate folder for your zsh aliases and functions and just add the following line to your `.zshrc`:

```sh
for config (~/.zsh/*.zsh) source $config
```
I recommend you create the zsh folder in `~/.zsh`.

Do not forget to edit the script!! I have left the paths blank, so you have to change them. Additionally, it follows all the steps in Setting Up, so if you find stuff that you do not want to implement, you can remove it from the script. For example, if you do not want to create a symlink with the `.obsidian` folder, just remove the parts from the code that manage the symlink.
