<p align="center"><strong>Obsidicrypt</strong> is the method used to encrypt, sandbox and sync your Obsidian notes.</p>

<p align="center">•• <a href="#key-features">Key Features</a> • <a href="#download">Download</a> • <a href="#installation">Installation</a> • <a href="#opensnitch-in-action">Usage examples</a> • <a href="#in-the-press">In the press</a> ••</p>

## Key Features

---

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

---

- Tested on Fedora only
- May work on MacOs
- Does not work in Windows
- Concrete security not guaranteed when selectively blocking via [fdns](https://github.com/netblue30/fdns)

## Threat Model

---

When only using encryption, all notes are protected from remote or physical access; unless accessed when filesystem was mounted or passwords were leaked. However, Obsidian must be run with no internet access or with restricted internet access in order to block any potentially malicious connections. Please note that any other malicious application running on your computer unchecked might be able to access the notes when the filesystem is mounted.

When using encryption and sanboxing, all notes are protected from remote and physical access and Obsidian has no access to any other content in your computer. The only folders that Obsidian can access are your note folders. You are able to fully restrict internet connection to Obsidian.

When using encryption and syncing, make sure that the sync service you are using has no access to the mounted folder. Also preferably do not sync your config file to the cloud. During this scenario, the cloud provider has full access to your encrypted files, so make sure to not leak your encryption password anywhere.

When using encryption, sandboxing and selective internet traffic, Obsidian has access to your unencrypted files and the internet. Although this connection is whitelisted, I cannot guarantee that it cannot be bypassed. This method is effective against protecting the notes against malicious plugins uploading your data, but again, I cannot guarantee that they do not do so from the whitelisted websites. Additionally, there are several ways to bypass this, such as harcoded IP addresses and seperate resolver libraries, so it is not as secure as simply restricting your internet connection.

Please also note that there may be security vulnerabilities with the encryption software itself, even if unlikely.

## Requirements

---

### Encryption Software

---

If you wish to encrypt your files, you will have to install an encryption software. There are many options, but I would recommend the following three.

#### CryFs
CryFs is the encryption software that I would recommend using. It is designed for cloud storage, and hides the file and folder hierarchy, contents, sizes and names. Please note that there have been no security audits done, however you can find a masters paper on [CryFs encryption published](https://www.cryfs.org/cryfs_mathesis.pdf).

To install CryFs, please refer to https://github.com/cryfs/cryfs.

#### gocryptfs
gocryptfs is similar to CryFs in the sense that they can be both used for cloud encryption. However, gocryptfs does not hide the file and folder hierarchy and sizes. You can find the security audit done on gocryptfs here: https://defuse.ca/audits/gocryptfs.htm

To install gocryptfs, please refer to https://github.com/rfjakob/gocryptfs.

### Obsidian

---

There are multiple ways to install Obsidian, but I would recommend using the AppImage. Note that if you use a Flatpak, you will be unable to use firejail and fdns.

### Firejail

---

Firejail is needed in order to sandbox Obsidian, to prevent it from reading other folders, connecting to the internet and more. firejail is avaliable on most distros, the you can find the installation instructions [here](https://github.com/netblue30/firejail).


### fdns

---

fdns is needed if you wish to create a dns server for your firejail sandbox. You can find installation instructions [here](https://github.com/netblue30/fdns)



