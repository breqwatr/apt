# Breqwatr/apt

Builds the Apt image for the [Breqwatr Deployment Tool](https://github.com/breqwatr/breqwatr-deployment-tool).

This image can be pulled from Docker Hub for free users, or Breqwatr's private
registry for registered users.


## Supported Ubuntu Versions

- Xenian 16.04 LTS (deprecated)
- Bionic 18.04 LTS


## To point apt at these sources:

make /etc/apt/sources.list look like this

```
deb [trusted=yes arch=amd64] http://10.254.3.2:81 bionic main
deb [trusted=yes arch=amd64] http://10.254.3.2:81 bionic-updates main
deb [trusted=yes arch=amd64] http://10.254.3.2:81 bionic-security main
```
