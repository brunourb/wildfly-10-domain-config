#!/bin/bash

WILDFLY_HOME="/root/wildfly-10.0.0.Final"
PASSWORD_MANAGEMENT="passw0rd!"
BIND_ADDRESS="0.0.0.0"
MANAGEMENT_ADDRESS="10.135.1.180"
SERVER_NAME="server-master"
PROFILE="ha"
JGROUP_CLUSTER_NODES="10.135.1.180[7600],10.135.1.241[7600]"

CLI_FILENAME="master_gen.cli"

function execute_command(){
	echo $1
	$WILDFLY_HOME/bin/jboss-cli.sh -c "$1"
}

function add_line_to_cli_file(){
	echo $1
	echo $1 >> $CLI_FILENAME
}

echo "Adding users..."
$WILDFLY_HOME/bin/add-user.sh -u admin -p $PASSWORD_MANAGEMENT
$WILDFLY_HOME/bin/add-user.sh -u slave -p $PASSWORD_MANAGEMENT

echo 'embed-host-controller' > $CLI_FILENAME

add_line_to_cli_file "#Configuring the access interfaces."
add_line_to_cli_file '/host=master/interface=public:write-attribute(name="inet-address",value="${jboss.bind.address:'$BIND_ADDRESS}'")'
add_line_to_cli_file '/host=master/interface=management:write-attribute(name="inet-address",value="${jboss.bind.address.management:'$MANAGEMENT_ADDRESS'}")'

add_line_to_cli_file "#configuring servers"
add_line_to_cli_file '/host=master/server-config=server-one:remove'
add_line_to_cli_file '/host=master/server-config=server-two:remove'
add_line_to_cli_file '/host=master/server-config=server-three:remove'
add_line_to_cli_file '/host=master/server-config='$SERVER_NAME'/:add(group=main-server-group)'

add_line_to_cli_file "#main-server-group must be in "$PROFILE" profile"
add_line_to_cli_file '/server-group=main-server-group:write-attribute(name="profile", value="'$PROFILE'")'
add_line_to_cli_file '/server-group=main-server-group:write-attribute(name=socket-binding-group, value='$PROFILE'-sockets)'

#Create infinispan replicated cache
#/profile=full-ha/subsystem=infinispan/cache-container=myCache/:add(default-cache=cachedb)
#/profile=full-ha/subsystem=infinispan/cache-container=myCache/transport=TRANSPORT/:add(lock-timeout=60000)
#/profile=full-ha/subsystem=infinispan/cache-container=myCache/replicated-cache=cachedb/:add(mode=SYNC)
#/profile=full-ha/subsystem=infinispan/cache-container=myCache/replicated-cache=cachedb/transaction=TRANSACTION/:add(mode=BATCH)

add_line_to_cli_file "#We allow TCP socket binding to be accesible for other hosts."
add_line_to_cli_file '/socket-binding-group='$PROFILE'-sockets/socket-binding=jgroups-tcp:write-attribute(name=interface,value=management)'
add_line_to_cli_file '/socket-binding-group='$PROFILE'-sockets/socket-binding=jgroups-tcp-fd:write-attribute(name=interface,value=management)'

add_line_to_cli_file "#Configure jgroups TCP stack"
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/channel=ee:write-attribute(name=stack,value=tcp)'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp:remove'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/transport=TCP:add(socket-binding=jgroups-tcp)'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=TCPPING:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=TCPPING/property=initial_hosts:add(value="${jboss.cluster.tcp.initial_hosts}")'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=MERGE3:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=FD_SOCK:add(socket-binding=jgroups-tcp-fd)'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=FD:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=VERIFY_SUSPECT:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=pbcast.NAKACK2:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=UNICAST3:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=pbcast.STABLE:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=pbcast.GMS:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=MFC:add'
add_line_to_cli_file '/profile='$PROFILE'/subsystem=jgroups/stack=tcp/protocol=FRAG2:add'
add_line_to_cli_file '/server-group=main-server-group/system-property=jboss.cluster.tcp.initial_hosts:add(value="'$JGROUP_CLUSTER_NODES'")'

echo 'stop-embedded-host-controller' >> $CLI_FILENAME

echo "executing "$CLI_FILENAME
$WILDFLY_HOME/bin/jboss-cli.sh --file=$CLI_FILENAME


