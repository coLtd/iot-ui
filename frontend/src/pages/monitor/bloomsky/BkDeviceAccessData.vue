<template>
  <v-container class="access-data pt-0">
    <v-layout row>
      <vc-schema-form tag="div"
                      v-bind="search"
                      v-model="params">
        <v-flex xs5
                style="align-self: flex-end">
          <div style="margin-bottom: 2px;height:30px;margin-left:10px;background-color:#fff;">
            <button @click="quickSetDate(0)"
                    class="tbutton"
                    :class="tclz">今天</button>
            <button @click="quickSetDate(7)"
                    class="tbutton"
                    :class="wclz">7天</button>
            <button @click="quickSetDate(30)"
                    class="tbutton"
                    :class="mclz">30天</button>
          </div>
        </v-flex>
      </vc-schema-form>
      <v-layout align-end
                justify-end>
        <v-flex class="text-xs-center flex--tab"
                :class="{ active: tab.current === 0 }">
          <a @click="tab.current = 0"
             class="black--text">图表</a>
        </v-flex>
        <v-flex class="text-xs-center flex--tab"
                :class="{ active: tab.current === 1 }">
          <a @click="tab.current = 1"
             class="black--text">表格</a>
        </v-flex>
        <v-flex v-if="typeCode !== 105"
                class="text-xs-center flex--tab"
                :class="{ active: tab.current === 2 }">
          <a @click="tab.current = 2"
             class="black--text">视频</a>
        </v-flex>
      </v-layout>
    </v-layout>
    <div class="pt-4 px-0"
         v-if="tab.current === 0">
      <bk-device-access-data-chart v-if="typeCode !== 105"
                                   :device="device"
                                   :start="startTime"
                                   :end="stopTime"></bk-device-access-data-chart>
      <rain-device-access-data-chart v-else
                                     :device="device"
                                     :start="startTime"
                                     :end="stopTime"></rain-device-access-data-chart>
    </div>
    <div class="card--table pt-3 px-0"
         v-if="tab.current === 1">
      <bk-device-access-data-table :device="device"
                                   v-if="typeCode !== 105"
                                   :start="startTime"
                                   :end="stopTime"></bk-device-access-data-table>
      <rain-device-access-data-table :device="device"
                                     v-else
                                     :start="startTime"
                                     :end="stopTime"></rain-device-access-data-table>
    </div>
    <div class="card--table pt-3 px-0"
         v-if="typeCode !== 105 && tab.current === 2">
      <bk-device-access-data-vedio :device="device"></bk-device-access-data-vedio>
    </div>
  </v-container>
</template>
<script>
import { data as JsonschemaData } from '@vehiclecloud/json-schema'
import BkDeviceAccessDataChart from './BkDeviceAccessDataChart'
import RainDeviceAccessDataChart from './RainDeviceAccessDataChart'
import Period from '@agrithings/common/util/period'
import BkDeviceAccessDataTable from './BkDeviceAccessDataTable'
import RainDeviceAccessDataTable from './RainDeviceAccessDataTable'
import BkDeviceAccessDataVedio from './BkDeviceAccessDataVedio'

export default {
  name: 'bk-device-access-data',
  props: {
    device: Object
  },
  data () {
    let stopDate = new Date()
    stopDate.setDate(stopDate.getDate())
    stopDate.setHours(0, 0, 0, 0)
    let stopTime = stopDate.getTime()
    let minDate = JsonschemaData.longToDateStr(stopTime - Period.day * 30)
    let maxDate = JsonschemaData.longToDateStr(stopTime)
    return {
      tclz: '',
      wclz: '',
      mclz: '',
      search: {
        schema: {
          type: 'object',
          properties: {
            startTime: { type: 'number', title: '开始', format: 'date' },
            stopTime: { type: 'number', title: '截止', format: 'date' }
          }
        },
        uiSchema: {
          'ui:title': '时段',
          'ui:class': { layout: true, row: true, flex: true, xs7: true },
          // startTime: { 'ui:props': { singleLine: true, hideDetails: true, min: minDate, max: maxDate }, 'ui:class': { 'mr-3': true } },
          startTime: { 'ui:props': (ctx, el, item) => ({ singleLine: true, hideDetails: true, min: minDate, max: JsonschemaData.longToDateStr(this.params.stopTime) }), 'ui:class': { 'mr-3': true } },
          stopTime: {
            'ui:props': (ctx, el, item) => ({ singleLine: true, hideDetails: true, min: JsonschemaData.longToDateStr(item.startTime), max: maxDate })
          }
        }
      },
      params: {
        startTime: { $numberLong: String(stopTime - Period.day) },
        stopTime: { $numberLong: String(new Date().getTime()) }
      },
      tab: {
        current: 0
      },
      vedios: [],
      typeCode: null
    }
  },
  computed: {
    startTime () {
      return this.params.startTime && +this.params.startTime.$numberLong
    },
    stopTime () {
      return this.params.stopTime && (+this.params.stopTime.$numberLong + Period[2])
    }
  },
  created () {
    let types = this.$store.state['base.device.type'].items.filter(d => d._id.$oid === this.device.type.$oid)
    this.typeCode = types[0].code
  },
  methods: {
    quickSetDate (internal) {
      if (!internal) {
        this.tclz = 'clz'
        this.wclz = ''
        this.mclz = ''
      } else if (internal === 7) {
        this.tclz = ''
        this.wclz = 'clz'
        this.mclz = ''
      } else {
        this.tclz = ''
        this.wclz = ''
        this.mclz = 'clz'
      }
      let stopDate = new Date()
      stopDate.setDate(stopDate.getDate())
      stopDate.setHours(0, 0, 0, 0)
      let stopTime = stopDate.getTime()
      this.params.stopTime = { $numberLong: String(stopTime) }
      this.params.startTime = { $numberLong: String(stopTime - Period.day * internal * 2) }
    }
  },
  components: {
    BkDeviceAccessDataTable,
    BkDeviceAccessDataVedio,
    BkDeviceAccessDataChart,
    RainDeviceAccessDataChart,
    RainDeviceAccessDataTable
  }
}
</script>
<style lang="scss">
.access-data {
  .flex--tab {
    border-bottom: 2px solid #ededed;
    &.active {
      border-bottom-color: #229af0;
    }
  }
  .tbutton {
    width: 40px;
    height: 30px;
  }
  .clz {
    background-color: #f4f4f4;
  }
  button {
    outline: none;
  }
}
</style>
