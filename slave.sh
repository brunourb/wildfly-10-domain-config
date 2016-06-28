#!/bin/bash

WILDFLY_HOME="/root/wildfly-10.0.0.Final"
PASSWORD_MANAGEMENT_BASE64="cGFzc3cwcmQh"
BIND_ADDRESS="0.0.0.0"
MANAGEMENT_ADDRESS="10.135.1.241"
MASTER_ADDRESS="10.135.1.180"
HOST="slave1"

CLI_FILENAME="slave_gen.cli"

function execute_command(){
	echo $1
	$WILDFLY_HOME/bin/jboss-cli.sh -c "$1"
}

function add_line_to_cli_file(){
	echo $1
	echo $1 >> $CLI_FILENAME
}

echo 'embed-host-controller' > $CLI_FILENAME

add_line_to_cli_file "#Configuring the access interfaces."
add_line_to_cli_file '/host=master/interface=public:write-attribute(name="inet-address",value="${jboss.bind.address:'$BIND_ADDRESS}'")'
add_line_to_cli_file '/host=master/interface=management:write-attribute(name="inet-address",value="${jboss.bind.address.management:'$MANAGEMENT_ADDRESS'}")'

add_line_to_cli_file "#configuring servers"
add_line_to_cli_file '/host=master/server-config=server-one:remove'
add_line_to_cli_file '/host=master/server-config=server-two:remove'
add_line_to_cli_file '/host=master/server-config=server-three:remove'
add_line_to_cli_file '/host=master/server-config=server-'$HOST'/:add(group=main-server-group)'

add_line_to_cli_file "#configure security realm to connect with user created in master"
add_line_to_cli_file '/host=master/core-service=management/security-realm=ManagementRealm/server-identity=secret:add(value="'$PASSWORD_MANAGEMENT_BASE64'")'
add_line_to_cli_file '/host=master:write-remote-domain-controller(protocol="remote",host="${jboss.domain.master.address:'$MASTER_ADDRESS'}",username="slave",port="9999",security-realm="ManagementRealm")'

add_line_to_cli_file "#We change host name to be slave"
add_line_to_cli_file '/host=master:write-attribute(name="name",value="'$HOST'")'

echo 'stop-embedded-host-controller' >> $CLI_FILENAME

echo "executing "$CLI_FILENAME
$WILDFLY_HOME/bin/jboss-cli.sh --file=$CLI_FILENAME


