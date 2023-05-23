# Firejail profile for obsidian
# Description: Markdown-based knowledge base
# This file is overwritten after every install/update
# Persistent local customizations
include obsidian.local
# Persistent global definitions
include globals.local

# Noblacklist paths
# Noblacklist path for the obsidian config folder
noblacklist ${HOME}/.config/obsidian
# Noblacklist path for the path to your Obsidian Vault
noblacklist /path/to/vault
# Noblacklist path for the path to your symlinked .obsidian folder
noblacklist /path/to/.obsidian

include disable-shell.inc

#mkdir PATH
##mkfile PATH

# Whitelist paths
whitelist ${HOME}/.config/obsidian
whitelist /path/to/vault
whitelist /path/to/.obsidian

# If you do not care about fdns and use without internet, uncomment this line
#net none

# If you wish to use fdns and use a whitelist for internet connectivity,
# blacklist the output of  ldconfig -p | grep libnss_resolve.so.2
# These 2 lines were the output of the command for me, it might be different for you.
blacklist /lib64/libnss_resolve.so.2
blacklist /lib/libnss_resolve.so.2

private-bin obsidian

# Redirect
include electron.profile
