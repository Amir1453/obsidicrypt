# Function to easily use git with my Obsidian Vault
ob(){
  # Change the vault_path to your mounted vault location
  local vault_path="/path/to/vault/"
  # Change the enc_path to your encrypted vault location
  local enc_path="/path/to/encrypted_vault/"

  # You must create a file in the vault to make sure that the filesystem can be validated.
  # You can link any file you wish, but you must make sure that they are never removed!
  local val="/path/to/vault/validation_file"
  local validate=false

  # Validates the encrypted filesystem
  if [ -f "$val" ]; then
    validate=true
  else
    validate=false
  fi

  # obsym is used to check whether .obsidian has been symlinked properly
  # Set ob_path to the location of the .obsidian folder
  local ob_path="path/to/.obsidian"
  # Set the ob_vault_path to your mounted vault path appended with .obsidian
  local ob_vault_path="path/to/vault/.obsidian"
  local obsym=true

  # Validates the .obsidian symlink
  if [ -d $ob_vault_path ]; then
    obsym=true
  else
    obsym=false
  fi

  # Current time used for commit messages
  local current_time=$(date +"%Y-%m-%d %H:%M:%S")

  # Determines whether Obsidian is running or not
  firejail --list | grep -q Obsidian
  local obsidian_run=$?

  # Gets the pid of the Obsidian process
  local obsidian_pid=$(firejail --list | grep "Obsidian" | cut -d: -f1)

  # Changed the directory to the vault path
  if [ "$1" = "cd" ]; then
    cd "$vault_path"
    return 0
  fi


  # Changes the directory to the encrypted filesystem
  if [ "$1" = "encd" ]; then
    cd "$enc_path"
    return 0
  fi


  # Commits all of the changes in the encyrpted filesystem
  if [ "$1" = "commit" ] && [ "$2" = "all" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" add --all
    git -C "$enc_path" commit -am "vault backup: $current_time"
    return 0
  fi


  # Commits the staged changes in the encyrpted filesystem
  if [ "$1" = "commit" ] && [ "$2" = "staged" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" commit -m "vault backup: $current_time"
    return 0
  fi


  # Pulls from the remote
  if [ "$1" = "pull" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" pull
    return 0
  fi

  # Pushes to the remote
  if [ "$1" = "push" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" push
    return 0
  fi


  # Commits all changes and pushes to the remote
  if [ "$1" = "backup" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" add --all
    git -C "$enc_path" commit -am "vault backup: $current_time"
    git -C "$enc_path" push
    return 0
  fi


  # Pulls from and pushes to the remote
  if [ "$1" = "sync" ]; then
    # Checks whether the .obsidian is still symlinked
    if [ "$obsym" = true ]; then
      echo "Warning: .obsidian file is symlinked!"
      return 0
    fi

    # Checks whether the filesystem is still mounted
    if [ "$val" = true  ]; then
      echo "Warning: Filesystem is mounted!"
      return 0
    fi

    # Uses git in the encrypted vault path
    git -C "$enc_path" pull
    git -C "$enc_path" push
    return 0
  fi


  # Starts the firejail DNS-over-HTTPS server on 127.2.2.2:53 with whitelist file
  if [ "$1" = "dns" ]; then
    sudo fdns --proxy-addr=127.2.2.2 --whitelist-file=/usr/local/etc/fdns/whitelist --daemonize
    return 0
  fi


  # Kills FDNS
  if [ "$1" = "killdns" ]; then
    sudo pkill fdns
    return 0
  fi


  # Attemps to mount the encrypted filesystem
  if [ "$1" = "mount" ]; then
    # If the filesystem is already mounted skips mounting
    if [ "$validate" = true ]; then
      echo "Warning: Encrypted filesystem already mounted!"
      # If .obsidian is symlinked skips symlinking
      if [ "$obsym" = true ]; then
        echo "Warning: .obsidian symlink already created!"
        return 0
      fi

      # Creates the symlink if .obsidian does not exist
      echo "Creating symlink to .obsidian..."
      ln -s $ob_path $vault_path

      return 0
    fi

    # Mounts the encrypted filesystem
    echo "Mounting encrypted filesystem..."
    cryfs $enc_path $vault_path

    # Sleep for good measure, usually system delays
    sleep 1

    # Revalidates the filesystem
    if [ -f "$val" ]; then
      validate=true
      echo "Validated the filesystem."
    else
      # Returns in the case of validation failure
      validate=false
      echo "Error: Failed to validate the filesystem!"
      return 0
    fi

    if [ -d $ob_vault_path ]; then
      echo "Warning: The .obsidian file was left inside the mounted filesystem!"
    else
      # Creates the symlink to .obsidian if it does not exist
      echo "Creating symlink to .obsidian..."
      ln -s $ob_path $vault_path
    fi
    return 0
  fi


  # Forcefully unmounts the filesystem
  if [ "$1" = "umount" ] && [ "$2" = "force" ]; then
    # Checks whether obsidian is running
    if [ $obsidian_run = 0 ]; then
      # If it is, Obsidian is shutdown via firejail
      echo "Shutting down Obsidian..."
      firejail --shutdown=$obsidian_pid
    fi

    # Checks whether the filesystem is mounted and .obsidian exists
    if [ "$validate" = true ]; then
      if [ "$obsym" = true ]; then
        # Removes the symlink
        echo "Removing symlink..."
        rm $ob_vault_path
        sleep 1 # With no sleep sometimes .obsidian stays stuck inside the filesystem
      else
        echo "Symlink not found. Skipping."
      fi
      # Unmounts the encrypted filesystem
      echo "Unmounting encrypted filesystem."
      cryfs-unmount $vault_path
      return 0
    fi
    echo "Warning: Nothing to unmount!"
    return 0
  fi


  # Attemps to unmount the filesystem
  if [ "$1" = "umount" ]; then
    # Checks whether Obsidian is running, and returns if it does
    if [ "$obsidian_run" = 0 ]; then
      echo "Warning: Obsidian is currently running!"
      return 0
    fi

    # Checks whether the filesystem is mounted and .obsidian exists
    if [ "$validate" = true ]; then
      if [ "$obsym" = true ]; then
        # Removes the symlink
        echo "Removing symlink..."
        rm $ob_vault_path
        sleep 1 # With no sleep sometimes .obsidian stays stuck inside the filesystem
      else
        echo "Symlink not found. Skipping."
      fi
      # Unmounts the encrypted filesystem
      echo "Unmounting encrypted filesystem."
      cryfs-unmount $vault_path
      return 0
    fi
    echo "Warning: Nothing to unmount!"
    return 0
  fi


  # Mounts the filesystem and launches Obsidian
  if [ "$1" = "launch" ]; then
    # Validates the filesystem and mounts if needed
    if [ "$validate" = false ]; then
      echo "Mounting the encrypted filesystem..."
      cryfs $enc_path $vault_path
    else
      echo "Filesystem mounted, skipping."
    fi

    # Sleep for good measure
    sleep 1.5

    # Revalidates the encrypted filesystem
    if [ -f "$val" ]; then
      validate=true
      echo "Validated the filesystem."
      # Checks whether .obsidian is symlinked
      if [ -d $ob_vault_path ]; then
        echo "Warning: .obsidian symlink already created!"
      else
        # Creates the symlink
        echo "Creating symlink..."
        ln -s $ob_path $vault_path
      fi
    else
      echo "Error: Failed to validate encrypted filesystem!"
      return 0
    fi

    # Determines whether Obsidian is running or not
    firejail --list | grep -q Obsidian
    local obsidian_run=$?

    # Starts Obsidian if it is not running
    if [ "$obsidian_run" = 0 ]; then
      echo "Obsidian is already running."
    else
      echo "Starting Obsidian..."
      setsid /usr/bin/firejail --x11 --appimage --profile=/etc/firejail/obsidian.profile --dns=127.2.2.2 /opt/Obsidian-1.2.8.AppImage
    fi
    return 0
  fi


  # Kills Obsidian and unmounts the filesystem
  if [ "$1" = "sunder" ]; then
    # Shuts down Obsidian if it is running
    if [ "$obsidian_run" = 0 ]; then
      echo "Shutting down Obsidian..."
      firejail --shutdown=$obsidian_pid
    else
      echo "Obsidian closed, skipping"
    fi

    # Checks whether filesystem is mounted and .obsidian exists
    if [ "$validate" = true ]; then
      if [ "$obsym" = true ]; then
        # Removes the symlink
        echo "Removing symlink..."
        rm $ob_vault_path
        sleep 1 # With no sleep sometimes .obsidian stays stuck inside the filesystem
      else
        echo "Symlink not found. Skipping."
      fi
      # Unmounts the encrypted filesystem
      echo "Unmounting encrypted filesystem."
      cryfs-unmount $vault_path

      sleep 1 # Sleep for good measure
    fi

    echo "Warning: No filesystem to sunder!"
    return 0
  fi


  # Prints the help menu
  if [ "$1" = "help" ]; then
    echo "ob                  that's me!"
    echo "ob cd               changes the directory to the Obsidian Vault directory"
    echo "ob encd             changes the directory to the encrypted filesystem"
    echo "ob commit           commits the files in the Obsidian Vault directory, 1 parameter is required"
    echo "ob commit all       commits all changes"
    echo "ob commit staged    commits staged changes"
    echo "ob pull             pulls from the remote"
    echo "ob push             pushes to the remote"
    echo "ob backup           commits all changes and then pushes to the remote"
    echo "ob sync             pulls from and pushes to the remote"
    echo "ob dns              starts the FDNS protocol"
    echo "ob killdns          stops the FDNS protocol"
    echo "ob mount            mounts the encrypted filesystem"
    echo "ob umount           unmounts the encrypted filesystem"
    echo "ob umount force     forcefully unmounts the encrypted filesystem"
    echo "ob launch           mounts the encrypted filesystem and launches Obsidian"
    echo "ob sunder           closes Obsidian and unmounts encrypted filesystem"
    return 0
  fi


  # Prints the help menu when no arguments passed
  echo "ob                  that's me!"
  echo "ob cd               changes the directory to the Obsidian Vault directory"
  echo "ob encd             changes the directory to the encrypted filesystem"
  echo "ob commit           commits the files in the Obsidian Vault directory, 1 parameter is required"
  echo "ob commit all       commits all changes"
  echo "ob commit staged    commits staged changes"
  echo "ob pull             pulls from the remote"
  echo "ob push             pushes to the remote"
  echo "ob backup           commits all changes and then pushes to the remote"
  echo "ob sync             pulls from and pushes to the remote"
  echo "ob dns              starts the FDNS protocol"
  echo "ob killdns          stops the FDNS protocol"
  echo "ob mount            mounts the encrypted filesystem"
  echo "ob umount           unmounts the encrypted filesystem"
  echo "ob umount force     forcefully unmounts the encrypted filesystem"
  echo "ob launch           mounts the encrypted filesystem and launches Obsidian"
  echo "ob sunder           closes Obsidian and unmounts encrypted filesystem"

}
