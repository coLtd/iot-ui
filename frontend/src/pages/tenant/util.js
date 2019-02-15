import { data as JsonSchemaData, util as JsonSchemaUtil } from '@vehiclecloud/json-schema'
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import searchUtil from '@vehiclecloud/commons/util/search'

import store from '@/store'

import commonSchema from '@/schema/common'

import deviceTypeSchema from '@/schema/base/device/type'
import deviceSchema from '@/schema/tenant/device'

import Period from '@agrithings/common/util/period'

export function td (ctx, self, value, cv) {
  return { domProps: { innerHTML: String(cv !== undefined ? cv : '-') || '-' } }
}

export function accessStatusOf (v) {
  if (!v) return '-'

  let items = JsonSchemaData.enumsOf(commonSchema.definitions.accessStatus.items)
  let status = items.filter(s => v.includes(s.value))
  return (status.length && status.map(s => s.text).join(', ')) || '-'
}

export function sensorTypeVal (code, k) {
  let st = store.state['base.sensor.type'].items.find(t => t.code === code)
  if (!st) return null
  if (!k.includes('.')) return st[k]
  let keys = k.split('.')
  let r = st
  for (let i = 0; i < keys.length; i++) {
    r = r[keys[i]]
    if (!r) return null
  }
  return r
}

export function accessDataText (d, code) {
  if (!d) return '-'
  let v = typeof d.v === 'number' ? Number(d.v.toFixed(2)) : d.v
  return (JsonSchemaUtil.isDef(v) ? v : '-') + (sensorTypeVal(code, 'data.unit') || '')
}

export function accessDataOf (device, sensorTypeCode) {
  return accessDataText(device.accessState && device.accessState.data && device.accessState.data[sensorTypeCode], sensorTypeCode)
}

export function accessDataWidget (sensorTypeCode) {
  return {
    tag: 'td',
    data: (ctx, el, item, v) => {
      return JsonSchemaVuetify.config.crud.table.helper.textData(ctx, el, item, v[sensorTypeCode] && v[sensorTypeCode].v)
    }
  }
}

export function paramsSchema (ctx, item) {
  let type = ctx.$store.state['base.device.type'].items.find(t => t._id.$oid === item.type.$oid)
  if (!type) return {}
  if (!type.paramTypes) return {}
  let paramTypes = type.paramTypes.map(pt => ctx.$store.state['base.device.param_type'].items.find(t => t._id.$oid === pt.$oid))

  // 过滤base.device.param_type 已删除的记录
  paramTypes = paramTypes.filter(pt => !!pt)

  let required = []
  let properties = paramTypes.reduce((prop, pt) => {
    let p = { title: pt.name }

    if (pt.value !== undefined) p.default = pt.value

    if (pt.type === 1) {
      p.type = 'number'
      if (pt.min) p.minimum = pt.min
      if (pt.max) p.maximum = pt.max
    } else {
      p.type = 'string'
      if (pt.minLength) p.minLength = pt.minLength
      if (pt.maxLength) p.maxLength = pt.maxLength
    }
    prop[pt._id.$oid] = p
    if (pt.required) required.push(pt._id.$oid)
    return prop
  }, {})

  return {
    type: 'object',
    properties: {
      params: {
        type: 'object',
        properties,
        required
      }
    }
  }
}

export const Schema = {
  Address: {
    province: {
      type: 'string',
      $id: '#base.area',
      title: '省'
    },
    city: {
      type: 'string',
      $id: '#base.area',
      title: '市'
    },
    district: {
      type: 'string',
      $id: '#base.area',
      title: '区'
    },
    town: {
      type: 'string',
      $id: '#base.area',
      title: '乡镇'
    }
  },
  TenantFarmland: {
    tenant: { type: 'string', $id: '#sys.tenant', title: '组织' },
    farmland: { type: 'string', $id: '#tenant.farmland', title: '所属地块' }
  },
  Device: {
    deviceTypeTag: deviceTypeSchema.properties.tag,
    deviceType: deviceSchema.properties.type
  },
  DateRange: {
    startDate: { type: 'number', format: 'date', title: '开始时间' },
    stopDate: { type: 'number', format: 'date', title: '结束时间' }
  }
}

export const Dependencies = {
  Address: {
    city: [
      'province'
    ],
    district: [
      'city'
    ],
    town: [
      'district'
    ]
  },
  TenantFarmland: {
    farmland: [
      'tenant'
    ]
  },
  Device: {
    deviceType: [
      'deviceTypeTag'
    ]
  }
}

export const UiSchema = {
  TenantFarmland () {
    let farmlandUI = searchUtil.refsSelectUiSchema()
    farmlandUI['ui:show'] = true
    farmlandUI['ui:props'] = { autocomplete: true }
    let oriMapFn = farmlandUI['ui:options'].map
    farmlandUI['ui:options'].map = (items, ctx, el, params) => {
      params.farmlands = items
      if (items && params.farmland && !items.some(item => item._id.$oid === params.farmland.$oid)) params.farmland = null
      return oriMapFn(items)
    }
    farmlandUI['ui:options'].filter = (farmland, ctx, el, params) => {
      if (!farmland.tenant) return false
      if (params.tenant && params.tenant.$oid !== farmland.tenant.$oid) return false
      if (params.province && params.province.$oid !== farmland.address.province.$oid) return false
      if (params.city && params.city.$oid !== farmland.address.city.$oid) return false
      if (params.district && params.district.$oid !== farmland.address.district.$oid) return false
      if (params.town && farmland.address.town && params.town.$oid !== farmland.address.town.$oid) return false
      return true
    }

    let tenantUI = searchUtil.refsSelectUiSchema()
    tenantUI['ui:props'] = { autocomplete: true }
    tenantUI['ui:options'].params = { sort: { name: 1 } }
    let tenantMapFn = tenantUI['ui:options'].map
    tenantUI['ui:options'].map = (items, ctx, el, params) => {
      if (items && params.tenant && !items.some(item => item._id.$oid === params.tenant.$oid)) params.tenant = null
      return tenantMapFn(items)
    }
    tenantUI['ui:options'].filter = (tenant, ctx, el, params) => {
      if (tenant.type !== 1) return false
      if (tenant.registeredAddress) {
        if (params.province && (!tenant.registeredAddress.province || (tenant.registeredAddress.province && params.province.$oid !== tenant.registeredAddress.province.$oid))) return false
        if (params.city && (!tenant.registeredAddress.city || (tenant.registeredAddress.city && params.city.$oid !== tenant.registeredAddress.city.$oid))) return false
        if (params.district && (!tenant.registeredAddress.district || (tenant.registeredAddress.district && params.district.$oid !== tenant.registeredAddress.district.$oid))) return false
      }
      let farmlands = ctx.vm.$store.state['tenant.farmland'].items
      if (farmlands && !farmlands.some(f => f.tenant && f.tenant.$oid === tenant._id.$oid)) return false
      return true
    }

    return {
      tenant: tenantUI,
      farmland: farmlandUI
    }
  },
  Device (ctx, containOtherProvider = true) {
    let result = searchUtil.refsSelectUiSchema()
    result['ui:show'] = true
    let oriMapFn = result['ui:options'].map
    result['ui:options'].map = items => {
      ctx.params.deviceTypes = items
      return oriMapFn(items)
    }
    result['ui:options'].filter = type => {
      if (!containOtherProvider) {
        if (type.provider !== 1 || type.status !== 1) return false
        if (type.provider !== 1) return false
      } else {
        if (type.status !== 1) return false
      }
      if (ctx.params.deviceTypeTag && ctx.params.deviceTypeTag !== type.tag) return false
      return true
    }
    return {
      deviceTypeTag: searchUtil.enumSelectUiSchema(),
      deviceType: result
    }
  },
  DateRange () {
    return {
      startDate: searchUtil.flexClass(),
      stopDate: searchUtil.flexClass()
    }
  }
}

export const Params = {
  Address: {
    country: { $oid: '100000000000100000000000' },
    province: null,
    city: null,
    district: null,
    town: null
  },
  TenantFarmland: {
    tenant: null,
    farmlands: [],
    farmland: null
  },
  Device: {
    deviceTypeTag: null,
    deviceTypes: [],
    deviceType: null
  },
  DateRangeFactory () {
    let today = new Date()
    today.setDate(today.getDate() - 1)
    today.setHours(0, 0, 0, 0)
    return {
      startDate: { $numberLong: today.getTime() - Period.day * 6 },
      stopDate: { $numberLong: today.getTime() }
    }
  }
}

export const Filter = {
  farmland (ctx) {
    return ctx.params.farmland || { $in: ctx.params.farmlands.map(f => f._id) }
  },
  deviceType (ctx) {
    return ctx.params.deviceType || { $in: ctx.params.deviceTypes.map(t => t._id) }
  }
}
