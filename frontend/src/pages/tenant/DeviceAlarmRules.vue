<template>
  <div>
    <vc-schema-table collection="tenant.device" :schema="deviceSchema" :ui-schema="uiSchema" :headers="headers" :filter="filter" :addable="false" :removeable="false" :find-fn="find" :select-fn="select" :edit-fn="edit" ref="deviceTable">
      <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
    </vc-schema-table>
    <ag-device-alarm-rules-dialog-with-confirm v-if="dialog.rules.show" :show.sync="dialog.rules.show" v-model="rules.counts[dialog.item._id.$oid]" :readonly="dialog.rules.readonly" :device="dialog.item"></ag-device-alarm-rules-dialog-with-confirm>
  </div>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'

import deviceSchema from '@/schema/tenant/device'

import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'

import searchUtil from '@vehiclecloud/commons/util/search'

import AgDeviceAlarmRulesDialogWithConfirm from '@/components/device/AgDeviceAlarmRulesDialogWithConfirm'

import { Schema, Dependencies, UiSchema, Params, Filter } from './util'

export default {
  name: 'tenant-device_alarm_rules',
  mixins: [ItemDialog],
  created () {
    this.inited = Promise.all([
      this.$store.dispatch('init', { collection: 'sys.tenant' }),
      this.$store.dispatch('init', { collection: 'tenant.farmland' }),
      this.$store.dispatch('init', { collection: 'base.device.type' }),
      this.$store.dispatch('init', { collection: 'base.device.param_type' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' })
    ])
  },
  mounted () {
    Promise.all([
      this.$store.state['tenant.farmland'].promise,
      this.$store.state['base.device.type'].promise
    ]).then(() => this.$refs.deviceTable.search())
  },
  data () {
    let self = this

    let findTenantRoot = tenant => {
      if (!tenant) return null
      return tenant.type === 1 ? tenant : findTenantRoot(this.$store.state['sys.tenant'].items.find(item => item._id.$oid === tenant.parent.$oid))
    }

    let tenantRootName = tid => {
      let tenant = findTenantRoot(this.$store.state['sys.tenant'].items.find(item => {
        if (!tid) return false
        return item._id.$oid === tid.$oid
      }))
      return (tenant && tenant.name) || '-'
    }

    return {
      inited: null,
      deviceSchema,
      uiSchema: {
        staff: { 'ui:show': () => false },
        updatedOn: { 'ui:show': () => false },
        params: { 'ui:show': () => false },
        accessState: { 'ui:show': () => false }
      },
      headers: [
        { value: 'name', align: 'left' },
        { value: 'code', align: 'left' },
        { value: 'type', align: 'left' },
        { text: '地块名称', value: 'farmland', align: 'left', sortable: false },
        { text: '组织', value: 'farmland', align: 'left', sortable: false, ui: { 'ui:options': { map: items => items.map(f => ({ text: tenantRootName(f.tenant), value: f._id.$oid })) } } },
        { text: '规则数量', value: 'code', align: 'left', sortable: false, ui: { 'ui:filter': (ctx, el, item) => self.rules.counts[item._id.$oid] || 0 } },
        { sortable: false, width: '72px' }
      ],
      search: {
        schema: {
          type: 'object',
          properties: {
            ...Schema.Address,
            ...Schema.TenantFarmland,
            ...Schema.Device,
            keyword: { type: 'string', title: '设备名称或ID' }
          },
          dependencies: {
            ...Dependencies.Address,
            ...Dependencies.TenantFarmland,
            ...Dependencies.Device
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          ...searchUtil.addressUiSchema(),
          ...UiSchema.TenantFarmland(self),
          ...UiSchema.Device(self, false),
          keyword: searchUtil.flexClass('xs4')
        }
      },
      params: {
        ...Params.Address,
        ...Params.TenantFarmland,
        ...Params.Device,
        keyword: null
      },
      devices: null,
      rules: {
        counts: {}
      },
      dialog: {
        rules: {
          show: false,
          readonly: true
        }
      }
    }
  },
  watch: {
    devices (v) {
      if (!v || !v.length) {
        this.rules.counts = {}
        return
      }

      mongo.db().collection('tenant.device_alarm_rules').aggregate([
        { $match: { device: { $in: v.map(d => d._id) }, _removed: { $exists: false } } },
        { $group: { _id: '$device', count: { $sum: 1 } } }
      ]).then(items => {
        this.rules.counts = items.reduce((m, c) => {
          m[c._id.$oid] = c.count
          return m
        }, {})
      })
    }
  },
  methods: {
    filter () {
      return this.inited.then(() => {
        let result = { farmland: Filter.farmland(this), type: Filter.deviceType(this) }
        if (this.params.keyword) result['$or'] = [{ name: { $regex: this.params.keyword } }, { code: { $regex: this.params.keyword } }]
        return result
      })
    },
    find (collection, params) {
      if (!(this.params.farmlands.length && this.params.deviceTypes.length)) return Promise.resolve({ items: [], total: { $numberLong: 0 } })
      return collection.find(params).then(result => {
        this.devices = result.items
        return result
      })
    },
    select (device) {
      this.openRulesDialog(device, true)
    },
    edit (device) {
      this.openRulesDialog(device, false)
    },
    openRulesDialog (device, readonly) {
      this.dialog.rules.readonly = readonly
      this.openDialog('rules', device)
    }
  },
  components: {
    AgDeviceAlarmRulesDialogWithConfirm
  }
}
</script>
