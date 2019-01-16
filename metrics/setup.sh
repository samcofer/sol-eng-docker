#!/bin/bash
export mac=$(curl -s http://169.254.169.254/latest/meta-data/mac)
export vpc_id=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/vpc-id)
sed -i "s/<VPC_ID>/${vpc_id}/g" /metrics/prometheus/prometheus.yml
