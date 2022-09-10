#!/bin/bash

HOST_FT="8610"
CAP_DISK_FT="240"
CACHE_DISK_FT="15"
DISKGROUP_FIXED_FT="8420"
ST_SLACK_OVERHEAD="30"

read -p "Enter Number of Disk Groups: " N_DISK_GROUP
read -p "Enter Amount of Memory per node (MB): " MEM_PER_NODE
read -p "Enter Amount of Cache size (GB): " CACHE
read -p "Enter Number of Cap Tier Disks: " N_CAP_DISK
read -p "Enter Number of VMs: " N_VM
read -p "Enter Amount of Disk per VM (GB): " DISK_PER_VM
read -p "Enter Amount of Swap per VM (GB): " SWP_PER_VM
read -p "Enter Number of ESXi Nodes: " N_NODES
read -p "Enter Desired Replication Factor: " R_FACTOR
read -p "Enter Estimated growth (%): " EST_GROWTH
read -p "Enter Slack Overhead (% | default to 30): " ST_SLACK_OVERHEAD


DISKGROUP_SCALABALE_FT=$(( MEM_PER_NODE / 200 ))
DISK_FT=$(( HOST_FT + ( N_DISK_GROUP * ( DISKGROUP_FIXED_FT + DISKGROUP_SCALABALE_FT +( CACHE * CACHE_DISK_FT ) + ( N_CAP_DISK * CAP_DISK_FT ))) ))
VSAN_TOTAL_FT=$(( (HOST_FT + ( N_DISK_GROUP * DISK_FT )) / 1024 )) 



VM_RAW_CAP=$(( N_VM * (DISK_PER_VM + SWP_PER_VM) ))
VM_R_RAW_CAP=$(( VM_RAW_CAP * (R_FACTOR + 1) ))
TOTAL_RAW_CAP=$(( VM_R_RAW_CAP + VSAN_TOTAL_FT ))
RAW_UNFORMAT_CAP=$(( TOTAL_RAW_CAP + (TOTAL_RAW_CAP * ( ST_SLACK_OVERHEAD + EST_GROWTH) / 100)))
PER_NODE_ST=$(( (( RAW_UNFORMAT_CAP + N_NODES - 1 ) / N_NODES + 999 ) / 1000 ))
DISK_GROUP_CAP=$(( PER_NODE_ST / N_DISK_GROUP ))

clear
echo "INFO:"
echo "#########################"
echo "Number of Nodes: $N_NODES"
echo "Number of Disks Per Node: $N_CAP_DISK"
echo "Number of VMs: $N_VM"
echo "Total storage Per VM: $(( DISK_PER_VM + SWP_PER_VM ))"
echo "Est. Growth: $EST_GROWTH"
echo "Est. Slack Overhead: $ST_SLACK_OVERHEAD"
echo "########################"
echo "Results:"
echo "########################"
echo "Total vSAN footprint is (GB): $VSAN_TOTAL_FT"
echo "Total Raw Unformatted Capacity needed is(Incl. Growth+Slack)(TB): $(( (RAW_UNFORMAT_CAP + 999) / 1000))"
echo "Total Raw Unformatted Capacity needed is(Excl. Growth+Slack)(TB): $(( (TOTAL_RAW_CAP + 999) / 1000))"
echo "Final Raw Storage Per Node(TB): $PER_NODE_ST"
echo "Total Raw Storage Per Node Per Disk Group(TB): $DISK_GROUP_CAP"
echo "########################"
