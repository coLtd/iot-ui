# /bin/bash
if [ "$1" = "prod" ]; then
    pwd
    rm -rf ./src/conf.js
    cp -rf ./src/conf.prod.js ./src/conf.js
fi
if [ "$1" = "sim" ]; then
    pwd
    rm -rf ./src/conf.js
    cp -rf ./src/conf.sim.js ./src/conf.js
fi
node -v
npm -v
npm cache clean --force
npm config set unsafe-perm true
npm install -g cnpm --registry=https://registry.npm.taobao.org
cnpm -v
cnpm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/
cnpm install @agrithings/cmap \
                @agrithings/common \
                @vehiclecloud/commons \
                @vehiclecloud/grpc-websocket-client \
                @vehiclecloud/json-schema \
                @vehiclecloud/json-schema-vuetify \
                @vehiclecloud/mongo-rest-client \
                @vehiclecloud/redis-rest-client \
                @vehiclecloud/oauth2-client \
                --registry=http://nexus.agthings.cn:8081/repository/npm-all/
cnpm install
cnpm run build
cp -r dist docker/