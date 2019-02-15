<template>
  <div>
    <vc-schema-table collection="tenant.device" :schema="schema" :ui-schema="uiSchema" :headers="headers" :filter="filter" :add-fn="add" :edit-fn="edit" :sort="{ updatedOn: -1 }" :select-fn="select" :removeable="false" ref="schemaTable">
      <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
    </vc-schema-table>
    <ag-dialog-tabs :title="`${this.dialog.form.origin ? '修改' : '新建'}设备`" v-model="dialog.form.show" :active.sync="dialog.form.active" :tabs="dialog.form.params.schema && Object.keys(dialog.form.params.schema).length ? ['基础信息', '设备参数'] : ['基础信息']" persistent>
      <template v-if="dialog.form.show && dialog.item">
        <vc-schema-form id="form-base" v-show="dialog.form.active === 0" :schema="schema" :ui-schema="uiSchema" :value="dialog.item" @submit="submit('base')" ref="baseForm"></vc-schema-form>
        <vc-schema-form id="form-params" v-show="dialog.form.active === 1" v-if="dialog.item.type" :schema="dialog.form.params.schema" :value="dialog.item" @submit="submit('params')" ref="paramsForm"></vc-schema-form>
      </template>
      <template slot="actions">
        <v-btn flat color="primary" @click.native="closeDialog('form')">
          取消
        </v-btn>
        <v-btn flat color="primary" type="submit" :form="dialog.form.active === 0 ? 'form-base' : 'form-params'">
          保存
        </v-btn>
      </template>
    </ag-dialog-tabs>
    <ag-dialog-tabs title="设备信息" v-model="dialog.detail.show" :active.sync="dialog.detail.active" :tabs="dialog.detail.params.schema !== null && Object.keys(dialog.detail.params.schema).length ? ['基础信息', '运行状态', '设备参数'] : ['基础信息', '运行状态']" max-width="1000px">
      <template v-if="dialog.detail.show && dialog.item">
        <vc-schema-detail v-if="dialog.detail.active === 0" :schema="schema" :ui-schema="uiSchema" :item="dialog.item"></vc-schema-detail>
        <div v-if="dialog.detail.active === 1">
          <div class="dialog-tabs--access-status">当前状态:
            <strong> {{ accessStatusOf(dialog.item.accessState && dialog.item.accessState.status) }}</strong>
          </div>
          <div v-if="dialog.detail.showAcessData">
            <div class="mt-4 mb-3">传感器报表:</div>
            <ag-device-access-data class="dialog-tabs--access-data" :device="dialog.item"></ag-device-access-data>
          </div>
        </div>
        <vc-schema-detail v-if="dialog.detail.active === 2" :schema="dialog.detail.params.schema" :item="dialog.item"></vc-schema-detail>
      </template>
    </ag-dialog-tabs>
  </div>
</template>
<script>
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import searchUtil from '@vehiclecloud/commons/util/search'
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'

import GrpcApi, { ByteString } from '@vehiclecloud/grpc-websocket-client'

import AgDialogTabs from '@/components/AgDialogTabs'
import AgDeviceAccessData from '@/components/device/AgDeviceAccessData'

import { accessStatusOf, paramsSchema, Schema, Dependencies, UiSchema, Params, Filter } from './util'

import schema from '@/schema/tenant/device'

import RecordOperator from '../mixins/record-operator'

import kafka from '@/api/kafka'

// TODO: 批量编辑
export default {
  name: 'tenant-device',
  mixins: [ItemDialog, RecordOperator],
  data () {
    let self = this
    return {
      initedPromise: null,
      access: {
        dataApi: new GrpcApi.DataApiV1(),
        serverRpc: new GrpcApi.ServerRpcV1()
      },
      schema,
      uiSchema: {
        code: { 'ui:validate': { unique: JsonSchemaVuetify.Validate.unique.params } },
        type: { 'ui:options': { filter: t => t.status === 1 } },
        lng: { 'ui:attrs': { step: '0.000001' } },
        lat: { 'ui:attrs': { step: '0.000001' } },
        staff: { 'ui:readOnly': true },
        farmland: { 'ui:props': { autocomplete: true } },
        photos: { 'ui:props': { fileName: 'device', limit: 3, tip: '请上传200x200(宽x高), 大小在20K ~ 1M之间的图片', fileMinSize: 20 * 1024, fileMaxSize: 1 * 1024 * 1024, accept: 'image/png, image/jpeg,  image/jpg,  image/bmp' } },
        updatedOn: { 'ui:readOnly': true },
        params: { 'ui:show': () => false },
        accessState: { 'ui:show': () => false }
      },
      headers: [
        { value: 'name', align: 'left' },
        { value: 'code', align: 'left' },
        { value: 'type', align: 'left' },
        { value: 'accessState.code', align: 'left', text: '运行状态' },
        { value: 'farmland', align: 'left', sortable: false },
        { value: 'staff', align: 'left', sortable: false },
        { value: 'updatedOn', align: 'left' }
      ],
      search: {
        schema: {
          type: 'object',
          properties: {
            ...Schema.TenantFarmland,
            ...Schema.Device,
            status: {
              'type': 'integer',
              'title': '运行状态',
              'enum': [
                1,
                2,
                3,
                1001,
                1002,
                2001,
                2002,
                2003
              ],
              'enumNames': [
                '就绪',
                '正常',
                '休眠',
                '传感器告警',
                '视频越线告警',
                '数据异常',
                '硬件故障',
                '设备离线'
              ]
            },
            keyword: { type: 'string', title: '名称或ID' }
          },
          dependencies: {
            ...Dependencies.TenantFarmland,
            ...Dependencies.Device
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          ...UiSchema.TenantFarmland(self),
          ...UiSchema.Device(self),
          status: searchUtil.enumSelectUiSchema(),
          keyword: searchUtil.flexClass('xs3')
        }
      },
      params: {
        ...Params.TenantFarmland,
        ...Params.Device,
        status: null,
        keyword: null
      },
      dialog: {
        detail: {
          show: false,
          active: 0,
          showAcessData: true,
          params: {
            schema: null
          }
        },
        form: {
          show: false,
          origin: null,
          active: 0,
          params: {
            schema: null
          },
          submit: {
            base: false,
            params: false
          }
        }
      }
    }
  },
  watch: {
    'dialog.item.type' (v, o) {
      if (!v || !this.dialog.form.show) return
      if (this.dialog.form.params.schema && this.dialog.item.params) {
        Object.keys(this.dialog.form.params.schema.properties).forEach(k => {
          delete this.dialog.item.params[k]
        })
      }
      this.dialog.form.params.schema = paramsSchema(this, this.dialog.item)
    }
  },
  created () {
    this.initedPromise = Promise.all([
      this.$store.dispatch('init', { collection: 'base.device.param_type' }),
      this.$store.dispatch('init', { collection: 'base.device.type' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' }),
      this.$store.dispatch('init', { collection: 'tenant.farmland' })
    ])
  },
  destroyed () {
    this.access.dataApi.close()
    this.access.serverRpc.close()
  },
  methods: {
    filter () {
      return this.initedPromise.then(() => {
        let result = { farmland: Filter.farmland(this) }
        if (this.params.keyword) {
          let regex = { '$regex': this.params.keyword.trim() }
          result.$or = [{ name: regex }, { code: regex }]
        }
        if (this.params.status !== null) result['accessState.code'] = this.params.status

        if (this.params.deviceTypeTag || this.params.deviceType) {
          result.type = Filter.deviceType(this)
        }
        return result
      })
    },
    getCollection () {
      return this.$refs.schemaTable.getCollection()
    },
    itemFactory () {
      return { status: 1, accessState: { status: [1], code: [1] }, staff: this.$store.state['tenant.staff'].current }
    },
    select (item) {
      this.dialog.detail.active = 0
      this.dialog.detail.params.schema = paramsSchema(this, item)
      let type = this.$store.state['base.device.type'].items.find(t => t._id.$oid === item.type.$oid)
      this.dialog.detail.showAcessData = type && type.provider === 1
      this.openDialog('detail', item)
    },
    add () {
      this.dialog.form.active = 0
      this.dialog.form.origin = null
      this.dialog.form.params.schema = null
      this.dialog.form.submit.base = false
      this.dialog.form.submit.params = false
      this.openDialog('form', this.itemFactory())
    },
    edit (item) {
      this.dialog.form.active = 0
      this.dialog.form.origin = item
      this.dialog.form.params.schema = paramsSchema(this, item)
      this.dialog.form.submit.base = false
      this.dialog.form.submit.params = false
      this.openDialog('form', JSON.parse(JSON.stringify(item)))
    },
    submit (type) {
      this.dialog.form.submit[type] = true
      let refName = type === 'base' ? 'params' : 'base'
      if (!this.dialog.form.submit[refName]) {
        let ref = this.$refs[refName + 'Form']
        ref.submit()
      }
      if (!this.dialog.form.submit.base || (this.dialog.item.type && !this.dialog.form.submit.params)) return

      function paramsEq (param1, param2) {
        if (param1 === param2) return true
        if (!param1 || !param2) return false
        let keys = Object.keys(param1)
        if (keys.length !== Object.keys(param2).length) return false
        for (let i = 0; i < keys.length; i++) {
          if (param1[keys[i]] !== param2[keys[i]]) return false
        }
        return true
      }
      this.setOperator(this.dialog.item)
      let needSync = !this.dialog.form.origin || this.dialog.item.code !== this.dialog.form.origin.code || !paramsEq(this.dialog.item.params, this.dialog.form.origin.params)
      let params = []
      if (!this.dialog.form.origin || this.dialog.item.type.$oid !== this.dialog.form.origin.type.$oid) params.push({ id: 0x01, v: this.$store.state['base.device.type'].items.find(t => t._id.$oid === this.dialog.item.type.$oid).code })
      if (this.dialog.item.params) {
        Object.keys(this.dialog.item.params).forEach(pk => {
          let param = this.$store.state['base.device.param_type'].items.find(p => p._id.$oid === pk)
          if (param && param.isPushParam && (!this.dialog.form.origin || !this.dialog.form.origin.params || this.dialog.form.origin.params[pk] !== this.dialog.item.params[pk])) {
            params.push({ id: param.paramId, v: this.dialog.item.params[pk] })
          }
        })
      }
      (this.dialog.form.origin ? this.$refs.schemaTable.update(this.dialog.item, this.dialog.form.origin) : this.$refs.schemaTable.insert(this.dialog.item)).then(item => {
        this.closeDialog('form')
        if (!this.dialog.form.origin) {
          this.$refs.schemaTable._afterInsert()
          // send alarmRule ,rules=null
          kafka.producer.sendAlarmRules(item, [], this.$store.state['base.device.type'].items, this.$store.state['base.device.param_type'].items, this.$store.state['base.sensor.type'].items, this.deviceTypeOf(item))
        }
        if (needSync) this.syncDeviceInfoToAccess(item)
        if (params.length) this.sendParamsToDevice(item, params)
      })
    },
    syncDeviceInfoToAccess (item) {
      let serverAttrs = item.params && Object.keys(item.params).reduce((r, pk) => {
        // let param = this.$store.state['base.device.param_type'].items.find(p => p._id.$oid === pk && !!p.isPushParam)
        // 通知接入时，不用判断参数是否是下发参数
        let param = this.$store.state['base.device.param_type'].items.find(p => p._id.$oid === pk)
        if (!param) return
        // 如果参数id没有定义，给-1，防止undefinded
        r[param.paramId || -1] = item.params[pk] // 此处可能取到空串，约定null和空串时接入认为此参数无效
        return r
      }, { 1: this.$store.state['base.device.type'].items.find(dt => dt._id.$oid === item.type.$oid).code })
      this.access.dataApi.saveDeviceInfo({
        deviceType: this.deviceTypeOf(item),
        deviceId: item.code,
        serverAttrs: serverAttrs
      }, res => {
        console.log(res)
      })
    },
    sendParamsToDevice (item, params) {
      this.access.serverRpc.sendServerEvent({
        deviceType: this.deviceTypeOf(item),
        deviceId: item.code,
        rpcData: {
          '@type': 'type.googleapis.com/com.carcloud.gateway.bean.rpc.RpcGenericBinaryV1',
          cmdId: 0xA0,
          cmdData: ByteString.copyFrom(params.reduce((arr, p) => {
            arr.push(p.id)
            arr.push(0x02)
            let hex = p.v.toString(16)
            if (hex.length > 2) {
              let i = hex.length % 2 || 2
              arr.push(parseInt(hex.substr(0, i), 16))
              arr.push(parseInt(hex.substr(i, 2), 16))
            } else {
              arr.push(0x00)
              arr.push(p.v)
            }
            return arr
          }, [params.length]))
        }
      }, res => {
        console.log(res)
      })
    },
    accessStatusOf,
    deviceTypeOf (device) {
      let accessDeviceType = 'SENSOR_SHENGU'
      let deviceType = this.$store.state['base.device.type'].items.find(dt => dt._id.$oid === device.type.$oid)
      if (!deviceType) {
        console.error('没有找到对应的设备类型！')
        return accessDeviceType
      }
      // 神谷
      if (deviceType.provider === 1) {
        let sensorIds = this.$store.state['base.device.type'].items.find(dt => dt._id.$oid === device.type.$oid).sensorTypes
        let isController = false

        for (var i = 0; i < sensorIds.length; i++) {
          let sensor = this.$store.state['base.sensor.type'].items.find(st => st._id.$oid === sensorIds[i].$oid)
          if (sensor && sensor.type === 2) {
            isController = true
            break
          }
        }

        if (isController) {
          accessDeviceType = 'CONTROLLER_SHENGU'
        }
      } else if (deviceType.provider === 2) { // bloomsky
        if (deviceType.brand === 1) {
          accessDeviceType = 'SENSOR_BLOOMSKY_BASE'
        } else if (deviceType.brand === 2 || deviceType.brand === 3) {
          accessDeviceType = 'SENSOR_BLOOMSKY_ENTERPRISE'
        }
      }
      return accessDeviceType
    }
  },
  components: {
    AgDialogTabs,
    AgDeviceAccessData
  }
}
</script>

<style lang="scss">
.dialog-tabs--access-status {
  background-color: #3cbaad;
  padding: 1rem 1.5rem;
  color: #fff;
  border-radius: 4px;
}
.dialog-tabs--access-data {
  border: 1px solid #f0f0f0;
}
</style>
