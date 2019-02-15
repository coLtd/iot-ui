import Vue from 'vue'
import Vuex from 'vuex'
import mongo, { MongoVuexHelper } from '@vehiclecloud/mongo-rest-client'

Vue.use(Vuex)

const store = new Vuex.Store({
  strict: true,
  state: {
    search: {
      keyword: null
    },
    config: {
      iotServer: null,
      province: {
        _id: { $oid: '530000000000530000000000' },
        level: 2,
        name: '云南',
        code: '530000000000',
        center: { lat: 24.267, lng: 101.7554 }
      }
    },
    'base.area': {
      items: [],
      loaded: {},
      database: 'iss'
    },
    'sys.tenant': {
      items: [],
      loaded: false,
      database: 'iss',
      params: { sort: { name: 1 } }
    },
    'tenant.staff': {
      items: [],
      current: null, // 当前登录用户信息
      token: null, // 当前登录用户oauth token
      jwt: null, // 当前登录录用oauth token jwt
      tenant: null, // 当前登录用户激活的组织
      loaded: false,
      database: 'iss'
    },
    'tenant.farmland': {
      allItems: [],
      items: [],
      loaded: false,
      database: 'iss',
      // params: { sort: { name: 1 } }
      params: async ({ state, commit }) => {
        let currentStaffOId = state['tenant.staff'].current._id
        let currentTenantId = state['tenant.staff'].tenant

        if (!state['tenant.staff_roles'].loaded) {
          let r = await mongo.db().collection('tenant.staff_roles').find(
            { filter: { staff: currentStaffOId, tenant: { $oid: currentTenantId } } }
          )
          let { items } = r
          commit('set', { name: 'tenant.staff_roles', k: 'items', v: items })
          state['tenant.staff_roles'].loaded = true
        }

        return ({ sort: { name: 1 }, filter: { _id: { $in: state['tenant.staff_roles'].items.reduce((a, r) => { a = a.concat(r.farmlands); return a }, []) } }, projection: { gis: 0, createdOn: 0, updatedOn: 0 } })
      }
    },
    'base.device.type': {
      items: [],
      loaded: false
    },
    'base.sensor.type': {
      items: [],
      loaded: false
    },
    'base.device.param_type': {
      items: [],
      loaded: false
    },
    'tenant.device': {
      items: [],
      loaded: false
    },
    'sys.authority': {
      items: [],
      current: null, // 当前登录用户的权限 { items: [所有权限], map: { method: { uri: true } }}
      loaded: false
    },
    'tenant.role': {
      items: [],
      loaded: false
    },
    'tenant.staff_roles': {
      items: []
    }
  },
  ...MongoVuexHelper
})

export default store
