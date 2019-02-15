<template>
  <v-dialog :value="show" @input="close" scrollable max-width="800px" content-class="dialog--access-data">
    <v-card v-if="show">
      <v-toolbar card color="grey lighten-4">
        <v-toolbar-title>{{ deviceAndSensor.device.name }}
          <small> ({{ deviceAndSensor.device.code }})</small>
        </v-toolbar-title>
        &nbsp; -> &nbsp;
        <v-toolbar-title>{{ deviceAndSensor.sensor.name }}
          <small> ({{ deviceAndSensor.sensor.code }})</small>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon small @click.native="close">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="pt-0">
        <v-container class="pt-0">
          <v-layout row>
            <vc-schema-form tag="div" v-bind="search" v-model="params"></vc-schema-form>
            <v-spacer></v-spacer>
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
            <ag-sensor-access-data-chart :device="deviceAndSensor.device" :sensor="deviceAndSensor.sensor" :start-time="startTime" :stop-time="stopTime"></ag-sensor-access-data-chart>
          </div>
          <div class="card--table pt-3 px-0" v-if="tab.current === 1">
            <ag-device-access-data-table :device="deviceAndSensor.device" :start-time="startTime" :stop-time="stopTime" :marker-access-status="true" :show-access-codes="true" :sensor-types-in-table="[deviceAndSensor.sensor]"></ag-device-access-data-table>
          </div>
        </v-container>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import AgSensorAccessDataChart from './AgSensorAccessDataChart'
import AgDeviceAccessDataTable from '../device/AgDeviceAccessDataTable'

import Period from '@agrithings/common/util/period'

export default {
  name: 'ag-sensor-access-data-dialog',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    deviceAndSensor: Object
  },
  watch: {
    show (v) {
      if (!v) return
      let stopDate = new Date()
      stopDate.setDate(stopDate.getDate() - 1)
      stopDate.setHours(0, 0, 0, 0)
      let stopTime = stopDate.getTime()
      this.params.stopTime = { $numberLong: String(stopTime) }
      this.params.startTime = { $numberLong: String(stopTime - Period[3]) }
      this.tab.current = 0
    }
  },
  data () {
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
          'ui:class': { layout: true, row: true },
          startTime: { 'ui:props': { singleLine: true, hideDetails: true }, 'ui:class': { 'mr-3': true } },
          stopTime: { 'ui:props': { singleLine: true, hideDetails: true } }
        }
      },
      params: {
        startTime: null,
        stopTime: null
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
    close () {
      this.$emit('update:show', false)
    }
  },
  components: {
    AgSensorAccessDataChart,
    AgDeviceAccessDataTable
  }
}
</script>

<style lang="scss">
.dialog--access-data {
  height: 85%;
  .card__text {
    height: 100%;
  }
  .flex--tab {
    border-bottom: 2px solid #ededed;
    &.active {
      border-bottom-color: #229af0;
    }
  }
}
</style>
