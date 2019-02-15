<template>
  <v-container class="access-data pt-0">
    <v-layout row>
      <vc-schema-form tag="div" v-bind="search" v-model="params">
        <v-flex xs5 style="align-self: flex-end">
          <v-btn-toggle style="margin-bottom: -4px;">
            <v-btn flat @click="quickSetDate(0)">今天</v-btn>
            <v-btn flat @click="quickSetDate(7)">7天</v-btn>
            <v-btn flat @click="quickSetDate(30)">30天</v-btn>
          </v-btn-toggle>
        </v-flex>
      </vc-schema-form>
      <v-layout align-end justify-end>
        <v-flex class="text-xs-center flex--tab" :class="{ active: tab.current === 0 }">
          <a @click="tab.current = 0" class="black--text">图表</a>
        </v-flex>
        <v-flex class="text-xs-center flex--tab" :class="{ active: tab.current === 1 }">
          <a @click="tab.current = 1" class="black--text">表格</a>
        </v-flex>
      </v-layout>
    </v-layout>
    <div class="pt-4 px-0" v-if="tab.current === 0">
      <ag-device-access-data-chart :device="device" :start-time="startTime" :stop-time="stopTime"></ag-device-access-data-chart>
    </div>
    <div class="card--table pt-3 px-0" v-if="tab.current === 1">
      <ag-device-access-data-table :device="device" :start-time="startTime" :stop-time="stopTime" :skip-access-status="skipAccessStatus" :marker-access-status="markerAccessStatus" :show-access-codes="showAccessCodes" :sensor-types-in-table="sensorTypesInTable"></ag-device-access-data-table>
    </div>
  </v-container>
</template>

<script>
import { data as JsonschemaData } from '@vehiclecloud/json-schema'

import Period from '@agrithings/common/util/period'

import AgDeviceAccessDataChart from './AgDeviceAccessDataChart'
import AgDeviceAccessDataTable from './AgDeviceAccessDataTable'

export default {
  name: 'ag-device-access-data',
  props: {
    device: Object,
    skipAccessStatus: Number,
    markerAccessStatus: [Number, Boolean],
    showAccessCodes: {
      type: Boolean,
      default: false
    },
    sensorTypesInTable: Array
  },
  // created () {
  //   let stopDate = new Date()
  //   stopDate.setDate(stopDate.getDate() - 1)
  //   stopDate.setHours(0, 0, 0, 0)
  //   let stopTime = stopDate.getTime()
  //   this.params.stopTime = { $numberLong: String(stopTime) }
  //   this.params.startTime = { $numberLong: String(stopTime - Period[3]) }
  //   this.tab.current = 0
  // },
  data () {
    let stopDate = new Date()
    stopDate.setDate(stopDate.getDate())
    stopDate.setHours(0, 0, 0, 0)
    let stopTime = stopDate.getTime()

    let minDate = JsonschemaData.longToDateStr(stopTime - Period.day * 30)
    let maxDate = JsonschemaData.longToDateStr(stopTime)

    return {
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
          startTime: { 'ui:props': { singleLine: true, hideDetails: true, min: minDate, max: maxDate }, 'ui:class': { 'mr-3': true } },
          stopTime: {
            'ui:props': (ctx, el, item) => ({ singleLine: true, hideDetails: true, min: JsonschemaData.longToDateStr(item.startTime), max: maxDate })
          }
        }
      },
      params: {
        startTime: { $numberLong: String(stopTime - Period.week) },
        stopTime: { $numberLong: String(stopTime) }
      },
      tab: {
        current: 0
      }
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
  methods: {
    quickSetDate (internal) {
      let stopDate = new Date()
      stopDate.setDate(stopDate.getDate())
      stopDate.setHours(0, 0, 0, 0)
      let stopTime = stopDate.getTime()

      this.params.stopTime = { $numberLong: String(stopTime) }
      this.params.startTime = { $numberLong: String(stopTime - Period.day * internal) }
    }
  },
  components: {
    AgDeviceAccessDataChart,
    AgDeviceAccessDataTable
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
}
</style>
