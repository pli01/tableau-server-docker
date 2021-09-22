# tableau-server-docker

[![CI](https://github.com/pli01/tableau-server-docker/actions/workflows/main.yml/badge.svg)](https://github.com/pli01/tableau-server-docker/actions/workflows/main.yml)

Automatic built docker image from official tableau server-in-container_setup-tool steps:

* https://help.tableau.com/current/server-linux/en-us/server-in-container_quickstart.htm
* https://help.tableau.com/current/server-linux/en-us/server-in-container_setup-tool.htm

This docker image include the following drivers:
* Mysql
* Postgresql
* Vertica

## Run it

* PreReq: docker installed
* From your side, you only need to pull docker image and up the tableau container with your license and settings
```
export LICENSE_KEY="XXXX"
export TSM_REMOTE_PASSWORD="YYYY"
export PUBLIC_HOST="My-public-ip"
make pull-image
make up
# BE Patient, the container will take 20mn to be up and running !
```

* This CI workflows run the server-in-container_setup-tool script and build docker image for tableau server [details in .github](.github/workflows/main.yml)
* Docker image are automatically push in [ghcr.io repository](https://github.com/users/pli01/packages/container/package/tableau-server-docker%2Ftableau_server_image)

