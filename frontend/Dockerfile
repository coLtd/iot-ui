FROM node:8-alpine
WORKDIR /code
COPY package.json /code/package.json
RUN npm config set unsafe-perm true
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org
RUN cnpm install webpack-dev-server -g
RUN cnpm install @agrithings/cmap @agrithings/common @vehiclecloud/commons @vehiclecloud/grpc-websocket-client @vehiclecloud/json-schema @vehiclecloud/json-schema-vuetify @vehiclecloud/mongo-rest-client @vehiclecloud/oauth2-client @vehiclecloud/redis-rest-client --registry=http://rc.ami-tek.com.cn:9081/repository/npm-public/
RUN cnpm install
RUN mv /code/node_modules /node_modules
COPY .postcssrc.js /node_modules/.postcssrc.js
COPY . /code
#CMD ["npm", "run", "dev"]
