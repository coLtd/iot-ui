<template>
  <div>
    <vc-schema-table collection="tenant.report.sensor_fault" :schema="schema" :headers="headers" :filter="filter" :find-fn="find" :addable="false" :editable="false" :removeable="false" :select-fn="select">
      <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
    </vc-schema-table>
    <ag-sensor-access-data-dialog :show.sync="dialog.detail" :deviceAndSensor="dialog.item"></ag-sensor-access-data-dialog>
  </div>
</template>
<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import searchUtil from '@vehiclecloud/commons/util/search'

import AgSensorAccessDataDialog from '@/components/sensor/AgSensorAccessDataDialog'

import schema from '@/schema/tenant/report/sensor_fault'

import Period from '@agrithings/common/util/period'
import { td, Schema, Dependencies, UiSchema, Params, Filter } from '../util'

const TotalDataWidget = {
  tag: 'td',
  data: () => (ctx, self, value, cv) => {
    return td(ctx, self, value, cv && cv.total)
  }
}

const SumDataWidget = {
  tag: 'td',
  data: () => (ctx, self, value, cv) => {
    let v = 0
    if (value) {
      if (value.dataFault) v += value.dataFault.total
      if (value.hdFault) v += value.hdFault.total
    }
    return td(ctx, self, value, v)
  }
}

function farmlandOptions (ctx, devices) {
  return devices.map(device => {
    let farmland = ctx.$store.state['tenant.farmland'].items.find(f => device.farmland && f._id.$oid === device.farmland.$oid)
    return { text: (farmland && farmland.name) || '-', value: device._id.$oid }
  })
}

export default {
  name: 'tenant-report-sensor_fault',
  mixins: [ItemDialog],
  data () {
    let self = this
    return {
      initedPromise: null,
      schema,
      headers: [
        { value: 'device', text: '名称', align: 'left', sortable: false },
        { value: 'device', text: '编号', align: 'left', sortable: false, ui: { 'ui:options': { textName: 'code' } } },
        { value: 'sensorType', align: 'left' },
        { value: 'dataFault', align: 'left', ui: { 'ui:widget': TotalDataWidget } },
        { value: 'hdFault', align: 'left', ui: { 'ui:widget': TotalDataWidget } },
        { value: 'hdFault', align: 'left', text: '合计', ui: { 'ui:widget': SumDataWidget } },
        { value: 'device', text: '地块名称', align: 'left', sortable: false, ui: { 'ui:options': { map: items => farmlandOptions(self, items) } } },
        { align: 'left', sortable: false, width: '0' }
      ],
      search: {
        schema: {
          type: 'object',
          properties: {
            ...Schema.DateRange,
            ...Schema.Address,
            ...Schema.TenantFarmland,
            sensorType: schema.properties.sensorType,
            keyword: { type: 'string', title: '设备名称或ID' }
          },
          dependencies: {
            ...Dependencies.Address,
            ...Dependencies.TenantFarmland
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          ...UiSchema.DateRange(),
          ...searchUtil.addressUiSchema(),
          ...UiSchema.TenantFarmland(self),
          sensorType: searchUtil.refsSelectUiSchema(),
          keyword: searchUtil.flexClass()
        }
      },
      params: {
        ...Params.DateRangeFactory(),
        ...Params.Address,
        ...Params.TenantFarmland,
        ...Params.Device,
        sensorType: null,
        keyword: null
      },
      dialog: {
        detail: false
      }
    }
  },
  created () {
    this.initedPromise = Promise.all([
      this.$store.dispatch('init', { collection: 'sys.tenant' }),
      this.$store.dispatch('init', { collection: 'tenant.farmland' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' })
    ])
  },
  methods: {
    filter () {
      return this.initedPromise.then(() => {
        let filter = { farmland: Filter.farmland(this) }
        if (this.params.keyword) filter['$or'] = [{ name: { $regex: this.params.keyword.trim() } }, { code: { $regex: this.params.keyword.trim() } }]
        return mongo.db().collection('tenant.device').find({
          filter,
          projection: { _id: 1 }
        }).then(({ items }) => {
          let result = { period: 2, time: { $gte: +this.params.startDate.$numberLong, $lt: +this.params.stopDate.$numberLong + Period.day }, device: { $in: items.map(d => d._id) } }
          if (this.params.sensorType) result.sensorType = this.params.sensorType
          return result
        })
      })
    },
    find (collection, params) {
      return collection.aggregate([
        { $match: params.filter },
        { $group: { _id: { device: '$device', sensorType: '$sensorType' } } },
        { $group: { _id: null, total: { $sum: 1 } } }
      ]).then(totalResult => {
        if (!totalResult.length || totalResult[0].total === 0) return { total: { $numberLong: 0 }, items: [] }
        return collection.aggregate([
          { $match: params.filter },
          {
            $group: {
              _id: { device: '$device', sensorType: '$sensorType' },
              dataFaultTotal: { $sum: '$dataFault.total' },
              hdFaultTotal: { $sum: '$hdFault.total' }
            }
          }
        ]).then(items => ({
          items: items.map(item => ({ device: item._id.device, sensorType: item._id.sensorType, dataFault: { total: item.dataFaultTotal }, hdFault: { total: item.hdFaultTotal } })),
          total: { $numberLong: totalResult[0].total }
        }))
      })
    },
    select (item) {
      let device = this.$store.state['tenant.device'].items.filter(d => d._id.$oid === item.device.$oid)[0]
      let sensor = this.$store.state['base.sensor.type'].items.filter(s => s._id.$oid === item.sensorType.$oid)[0]
      this.openDialog('detail', { device: device, sensor: sensor })
    }
  },
  components: {
    AgSensorAccessDataDialog
  }
}
</script>
