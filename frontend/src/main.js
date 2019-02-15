// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import store from './store'
import router from './router'

import locale from 'vee-validate/dist/locale/zh_CN'
import VeeValidate, { Validator } from 'vee-validate'

import Vuetify from 'vuetify'
import 'material-design-icons/iconfont/material-icons.css'
import 'vuetify/dist/vuetify.min.css'

import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import '@vehiclecloud/json-schema-vuetify/dist/json-schema-vuetify.min.css'
import '@vehiclecloud/commons/css/main.scss'

import mongo, { config as MongoConfig } from '@vehiclecloud/mongo-rest-client'

import OAuth2 from '@vehiclecloud/oauth2-client'
import Oauth2Helper from '@agrithings/common/helper/oauth2'

import GrpcApi from '@vehiclecloud/grpc-websocket-client'

import { default as KafkaApi } from './api/kafka'

import CommonSchema from '@/schema/common'

import VCharts from 'v-charts'

import conf from './conf'

Vue.config.productionTip = false

Validator.localize(locale.name, locale)

Vue.use(VeeValidate, {
  inject: false,
  locale: locale.name,
  strict: false
})
Vue.use(VCharts)
Vue.use(Vuetify)
Vue.use(JsonSchemaVuetify, { commonSchemas: [CommonSchema], Validator })

Vue.use(OAuth2, {
  router,
  conf: {
    cookieName: 'iot-token',
    server: conf.OAuth2.server,
    clientId: conf.OAuth2.clientId,
    init: Oauth2Helper.initFnOf(store, mongo, 'iss'),
    authed: Oauth2Helper.authedFnOf(store)
  }
})

MongoConfig({
  iss: {
    database: conf.Mongo.iss.database,
    base: conf.Mongo.iss.base
  },
  default: {
    database: conf.Mongo.iot.database,
    base: conf.Mongo.iot.base
  }
})

GrpcApi.config(conf.Grpc.ws)
JsonSchemaVuetify.config.fs(conf.FS.server)
KafkaApi.config(conf.Kafka)

store.commit('set', { name: 'config', v: conf.IOT })

// 动力视讯代理服务的参数配置
store.commit('set', { name: 'config', k: 'pvServer', v: conf.PvServer.server })
/* eslint-disable no-new */
new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
