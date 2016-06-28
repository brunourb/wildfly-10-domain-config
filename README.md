# Wildfly 10 Clustering (with TCP)

In this repo 2 scripts are provided (for master and slaves) to setup automatically a cluster in an out-of-the-box wildfly 10 installation. 

## Why Domain mode in Wildfly?

There are some advantages in using a cluster:

- Whenever you deploy on Master, the same war is also deployed in all slaves.
- Any configuration made on Master via jboss-cli, for example (add a datasource, create a shared cache, log config, etc...) is automatically passed to all slaves.
- If a slave connects for the first time to a master, it will inherit all the apps deployed and configuration from the master.
- Depending on the profile that the server-group is running, you can use some features automatically, for example a shared memory cache for all nodes of the cluster with [Infinispan](http://infinispan.org/) is available in HA profile.

What is not a cluster in Wildfly:

- If doesn´t offer Load Balancing: All requests go through a entry point and some go master, others to slave1 and others to slave2. You have to achieve this with other software, for example [nginx](http://nginx.org/).

## Why use TCP and not UDP (Multicasting)?

For network communication between nodes [JGroups](http://www.jgroups.org/) is used. JGroups recommends to use UDP instead of TCP. 

[Explanation why UDP is recommended](http://www.jgroups.org/manual/html/protlist.html#TCP) --> "While UDP sends 1 IP multicast packet when sending a message to a cluster of 10 members, TCP needs to send the message 9 times. It sends the same message to the first member, to the second member, and so on (excluding itself as the message is looped back internally). We recommend to use UDP for larger clusters, whenever possible"

Use of Multicast is also easier to setup because the nodes of the cluster are autodiscovered and no extra configuration needs to be done to add a node to the cluster. 

But there are cases where UDP or Multicasting is not allowed and you have to use TCP. Some hostings don´t allow it (For example: [Digital Ocean](https://www.digitalocean.com/community/questions/ip-multicasting-on-private-networking))

In that cases you can only use TCP.

If you want to test if your network allows Multicast, JGroups provides with a tool to perform tests. The following page explains very well how to do this easily:

[HOWTO: Troubleshoot JGroups and Multicast IP Issues](http://www.techstacks.com/howto/troubleshoot-jgroups-and-multicast-ip-issues.html)

## Configure Master

Steps to configure master instance:

- Download wildfly from [Wildfly download page](http://wildfly.org/downloads/) and extract it.
- Download master.sh provided in this repo.
- Edit and configure the following properties:

    - Where your wildfly installation is.

            WILDFLY_HOME="/root/wildfly-10.0.0.Final"

    - Password that will be used to authenticate master with slaves. This password must be the same in slave.sh script.

            PASSWORD_MANAGEMENT="passw0rd!"

    - Which interface you want to bind to listen for requests. If you want to bind to all available IP addresses...

            BIND_ADDRESS="0.0.0.0"

    - Interface that will be used for administration and for communication between nodes. It is recommended not to be public.

            MANAGEMENT_ADDRESS="10.135.1.180"

    - Server name. It will be shown in logs.

            SERVER_NAME="server-master"

    - Which profile do you want to use. (ha, full-ha, etc...)

            PROFILE="ha"

    - Specify all nodes that will be part of the cluster, master and slaves:

            JGROUP_CLUSTER_NODES="10.135.1.180[7600],10.135.1.241[7600]"

- Execute master.sh. Wildfly 10 does not need to be started.
- Start server in domain mode -> /root/wildfly-10.0.0.Final/bin/domain.sh

Done! Server is started and waiting for slaves to connect.

![alt text](https://raw.githubusercontent.com/marcoslop/wildfly-10-domain-config/master/images/master_started.png "Master Started")

## Configure Slave

Steps to configure slave instance:

- Download wildfly from [Wildfly download page](http://wildfly.org/downloads/) and extract it.
- Download slave.sh provided in this repo.
- Edit and configure the following properties:

    - Where your wildfly installation is.

            WILDFLY_HOME="/root/wildfly-10.0.0.Final"

    - Password that will be used to authenticate master with slaves. In Base64!!

            PASSWORD_MANAGEMENT_BASE64="cGFzc3cwcmQh"

    - Which interface you want to bind to listen for requests. If you want to bind to all available IP addresses...

            BIND_ADDRESS="0.0.0.0"

    - Interface that will be used for administration and for communication between nodes. It is recommended not to be public.

            MANAGEMENT_ADDRESS="10.135.1.180"

    - Master Server IP.

            MASTER_ADDRESS="10.135.1.180"

    - Server host name. It will be shown in logs.

            HOST="slave1"


- Execute slave.sh. Wildfly 10 does not need to be started.
- Start server in domain mode -> /root/wildfly-10.0.0.Final/bin/domain.sh

While starting slave, we will see the following in master logs:

![alt text](https://raw.githubusercontent.com/marcoslop/wildfly-10-domain-config/master/images/master_slave_connected.png "Slave connected to Master")

When slave is started, we should see the following:

![alt text](https://raw.githubusercontent.com/marcoslop/wildfly-10-domain-config/master/images/slave_started.png "Slave Started")



