#!/bin/bash
docker build -t rc.ami-tek.com.cn:9082/agrithings/iot/frontend:1.0.0 -f Dockerfile.prod .
docker push rc.ami-tek.com.cn:9082/agrithings/iot/frontend
