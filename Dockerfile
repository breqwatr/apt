FROM ubuntu:bionic
# NOTE(kyle):
# Aptly is maybe not a great choice any more. It doesn't support gpgv2, and
# ubuntu:bionic doesn't support gpgv1. I've had to remove the signing code.
# We should look into maybe doing the work it does ourselves to replace it.
# ...It can't be that hard, right?

ENV \
  GPG_PRIVATE_KEY_FILE='/keys/breqwatr-private-key.asc' \
  GPG_PUBLIC_KEY_FILE='/keys/breqwatr-public-key.asc'

# Install required software
RUN apt-get update \
  && echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list \
  && apt-get install -y \
    nginx \
    aptly \
    curl \
  && mkdir -p /etc/nginx /aptly /keys /etc/breqwatr \
  && rm -f /etc/nginx/sites-enabled/default

# deploy the keys, manually add them so you can enter their password
COPY image-files/ /

# bionic
#  REMINDER: keys.gnupg.net is very often broken. Use keyserver.ubuntu.com.
RUN gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3B4FE6ACC0B21F32 \
 && aptly mirror create \
      -architectures=amd64 \
      -filter "$(cat /etc/breqwatr/packages | paste -sd "|" -)" \
      -dep-follow-source=true \
      -filter-with-deps=true \
      -with-sources=false \
      bionic \
      http://us.archive.ubuntu.com/ubuntu bionic main restricted universe multiverse \
 && aptly mirror update bionic \
 && aptly snapshot create bionic from mirror bionic \
 # bionic-updates
 && aptly mirror create \
      -architectures=amd64 \
      -filter "$(cat /etc/breqwatr/packages | paste -sd "|" -)" \
      -dep-follow-source=true \
      -filter-with-deps=true \
      -with-sources=false \
      bionic-updates \
      http://us.archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse\
 && aptly mirror update bionic-updates \
 && aptly snapshot create bionic-updates from mirror bionic-updates \
# bionic-security
 && aptly mirror create \
      -architectures=amd64 \
      -filter "$(cat /etc/breqwatr/packages | paste -sd "|" -)" \
      -dep-follow-source=true \
      -filter-with-deps=true \
      -with-sources=false \
      bionic-security \
      http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse \
 && aptly mirror update bionic-security \
 && aptly snapshot create bionic-security from mirror bionic-security \
# ceph (merge with bionic)
 && gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E84AC2C0460F3994 \
 && aptly mirror create \
      -architectures=amd64 \
      -filter "$(cat /etc/breqwatr/packages | paste -sd "|" -)" \
      -dep-follow-source=true \
      -filter-with-deps=true \
      -with-sources=false \
      ceph \
      http://download.ceph.com/debian-octopus bionic main \
 && aptly mirror update ceph \
 && aptly snapshot create ceph from mirror ceph \
# docker (merge with bionic)
 && gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7EA0A9C3F273FCD8 \
 && aptly mirror create \
      -ignore-signatures \
      -architectures=amd64 \
      -dep-follow-source=true \
      -filter-with-deps=true \
     -with-sources=false \
     docker \
     https://download.docker.com/linux/ubuntu/ bionic stable \
 && aptly mirror update docker \
 && aptly snapshot create docker from mirror docker \
# Merge
 && aptly snapshot merge bionic-merge bionic ceph docker \
# Publish (Note: GPG signing no longer works)
 && aptly publish -skip-signing -batch=true snapshot bionic-merge \
 && aptly publish -skip-signing -batch=true snapshot bionic-updates \
 && aptly publish -skip-signing -batch=true snapshot bionic-security

CMD /usr/sbin/nginx
