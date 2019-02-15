<template>
  <div>
    <vc-schema-table collection="tenant.device" :schema="schema" :headers="headers" :filter="filter" :addable="false" :editable="false" :removeable="false" :sort="{ 'accessState.time': -1, updatedOn: -1 }" :select-fn="select">
      <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
    </vc-schema-table>
    <ag-device-access-data-dialog :show.sync="dialog.detail" :device="dialog.item" :skip-access-status="2" :marker-access-status="3" show-access-codes></ag-device-access-data-dialog>
  </div>
</template>
<script>
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import searchUtil from '@vehiclecloud/commons/util/search'

import AgDeviceAccessDataDialog from '@/components/device/AgDeviceAccessDataDialog'

import { accessDataWidget, Schema, Dependencies, UiSchema, Params, Filter } from './util'

import schema from '@/schema/tenant/device'

export default {
  name: 'tenant-device-fault',
  mixins: [ItemDialog],
  created () {
    this.initedPromise = Promise.all([
      this.$store.dispatch('init', { collection: 'sys.tenant' }),
      this.$store.dispatch('init', { collection: 'tenant.farmland' }),
      this.$store.dispatch('init', { collection: 'base.device.type' })
    ])
  },
  data () {
    let self = this
    return {
      initedPromise: null,
      schema,
      headers: [
        { value: 'name', align: 'left' },
        { value: 'code', align: 'left' },
        { value: 'type', align: 'left' },
        { value: 'accessState.data', align: 'left', text: '信号', ui: { 'ui:widget': accessDataWidget(1) } },
        { value: 'accessState.data', align: 'left', text: '电量', ui: { 'ui:widget': accessDataWidget(99) } },
        { value: 'accessState.code', align: 'left', text: '状态' },
        { value: 'accessState.time', align: 'left', text: '时间' },
        { value: 'farmland', align: 'left', sortable: false },
        { align: 'left', sortable: false, width: '0' }
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
          ...UiSchema.Device(self),
          keyword: searchUtil.flexClass('xs3')
        }
      },
      params: {
        ...Params.Address,
        ...Params.TenantFarmland,
        ...Params.Device,
        keyword: null
      },
      dialog: {
        detail: false
      }
    }
  },
  methods: {
    filter () {
      return this.initedPromise.then(() => {
        let result = { 'accessState.status': 3, farmland: Filter.farmland(this), type: Filter.deviceType(this) }
        if (this.params.keyword) result['$or'] = [{ name: { $regex: this.params.keyword.trim() } }, { code: { $regex: this.params.keyword.trim() } }]
        return result
      })
    },
    select (item) {
      this.openDialog('detail', item)
    }
  },
  components: {
    AgDeviceAccessDataDialog
  }
}
</script>