# This whole file is safe to delete once testing is done

for repo in bionic-merge bionic-updates bonic-backports bionic-security ; do
  echo "Publishing $repo"
  # Signing is broken with the new bionic stuff
  # aptly publish snapshot -batch=true -passphrase="$GPG_PASSKEY" $repo
  aptly publish snapshot -skip-signing $repo
done

if [[ ! -f /aptly/public/repo ]]; then
  echo "creating repo symlink to mimick docker mirror"
  pushd /aptly/public
  ln -s . repo
  popd
fi

cp $GPG_PUBLIC_KEY_FILE /aptly/public/gpg

# start nginx, its more performant than aptly serve's little webserver
# starting webserver...
/usr/sbin/nginx
