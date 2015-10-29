#!/bin/bash
declare -a myInsARRAY
mapfile -t myInsARRAY < <(aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name itmo544-fall2015 --security-group-ids sg-17da1e71 --subnet-id subnet-fff4dbd4 --associate-public-ip-address --iam-instance--profile Name=phpDeveloperRole --user-data file://enviroment.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")



echo ${myInARRAY[@]}

aws ec2 wait instance-running --instance-ids ${myInsARRAY[@]}
echo "instances are running"

ELBURL=(`aws elb create-load-balancer --load-balancer-name $2 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups sg-17da1e71 --subnets subnet-fff4dbd4 --output=text`);
echo $ELBURL

aws elb register-instances-with-load-balancer --load-balancer-name $2 --instances ${MyInsARRAY[@]}


aws elb configure-health-check --load-balancer-name $2 --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3


aws autoscaling create-launch-configuration --launch-configuration-name itm-config --image-id ami-d05e75b8 --key-name itmo544-fall2015 --security-groups sg-17da1e71 --instance-type t2.micro --user-data file://install-enviroment.sh --iam-instance-profile phpDeveloperRole 

aws autoscaling create-auto-scaling-group --auto-scaling-group-name itmo544-autoscaling-group --launch-configuration-name itm-config --load-balancer-names $2 --health-check-type ELB --min-size 3 --max-size 6 desired-capacity 3 --defult-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-fff4dbd4



