#!/bin/bash
set -e -x

TABLEAU_SERVER_CONTAINER_SETUP_TOOL_VERSION=2021.3.0
TABLEAU_SERVER_CONTAINER_SETUP_TOOL=tableau-server-container-setup-tool-${TABLEAU_SERVER_CONTAINER_SETUP_TOOL_VERSION}.tar.gz
TABLEAU_SERVER_CONTAINER_SETUP_TOOL_URL=https://downloads.tableau.com/esdalt/${TABLEAU_SERVER_CONTAINER_SETUP_TOOL_VERSION}/${TABLEAU_SERVER_CONTAINER_SETUP_TOOL}
TABLEAU_SERVER_RPM_VERSION=2021-3-0
TABLEAU_SERVER_RPM=tableau-server-${TABLEAU_SERVER_RPM_VERSION}.x86_64.rpm
TABLEAU_SERVER_RPM_URL=https://downloads.tableau.com/esdalt/${TABLEAU_SERVER_CONTAINER_SETUP_TOOL_VERSION}/${TABLEAU_SERVER_RPM}
JDBC_POSTGRESQL_VERSION=42.2.14
JDBC_POSTGRESQL=postgresql-${JDBC_POSTGRESQL_VERSION}.jar
JDBC_POSTGRESQL_URL=https://downloads.tableau.com/drivers/linux/postgresql/${JDBC_POSTGRESQL}


rm -rf  build-dir
mkdir build-dir
cd build-dir

echo "# download/extract ${TABLEAU_SERVER_CONTAINER_SETUP_TOOL_URL}"
rm -rf $(basename ${TABLEAU_SERVER_CONTAINER_SETUP_TOOL .tar.gz})
curl -L -O ${TABLEAU_SERVER_CONTAINER_SETUP_TOOL_URL}
tar -zxvf ${TABLEAU_SERVER_CONTAINER_SETUP_TOOL}

cd $(basename ${TABLEAU_SERVER_CONTAINER_SETUP_TOOL} .tar.gz)

echo "# download ${TABLEAU_SERVER_RPM}"
curl -L -O ${TABLEAU_SERVER_RPM_URL}

echo "# download ${JDBC_POSTGRESQL_URL} "
( cd customer-files/ && curl -LO ${JDBC_POSTGRESQL_URL} )

cat <<EOF > customer-files/setup-script
#!/bin/bash
# Driver installation and other artifact installation script
mkdir -p /opt/tableau/tableau_driver/jdbc
cp /docker/customer-files/${JDBC_POSTGRESQL} /opt/tableau/tableau_driver/jdbc/${JDBC_POSTGRESQL}
EOF

cat <<EOF > env.txt
TABLEAU_USERNAME=admin
TABLEAU_PASSWORD=admin
TSM_REMOTE_UID=1010
TSM_REMOTE_USERNAME=tsmadmin
EOF

cat <<EOF > reg-info.json
{
     "first_name" : "John",
     "last_name" : "Smith",
     "email" : "bla@nodomain.org",
     "company" : "CI tool",
     "title" : "Head Cat Herder",
     "department" : "Engineering",
     "industry" : "Finance",
     "phone" : "123-555-1212",
     "city" : "Kirkland",
     "state" : "WA",
     "zip" : "98034",
     "country" : "United States",
     "eula" : "accept"
}
EOF

echo "# disable yum fastestmirror (corporate proxy restriction)"
sed -i.back -e '/set -e/a\
sed -i -e "s/^enabled=.*/enabled=0/g" /etc/yum/pluginconf.d/fastestmirror.conf\
cat /etc/yum/pluginconf.d/fastestmirror.conf\
yum -v repolist\
' image/init/setup_default_environment.bash

echo "# add http_proxy build var"
sed -i.back -e '/docker build/a\
    --build-arg "http_proxy=\"${http_proxy}\""\
    --build-arg "https_proxy=\"${https_proxy}\""\
    --build-arg "no_proxy=\"${no_proxy}\""
' build-image


echo "# build tableau server docker image"
./build-image --accepteula -i ${TABLEAU_SERVER_RPM} -e env.txt