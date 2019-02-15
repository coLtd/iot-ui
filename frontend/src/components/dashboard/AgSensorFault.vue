<template>
  <ag-statistics :title="'传感器故障'" :options="option">
    <v-container fluid>
      <v-layout row wrap>
        <v-flex xs3>
          <v-select v-model="filter.date" :value="filter.date" :items="[{value: 1, text: '昨天'}, {value: 7, text: '近7天'}, {value: 30, text: '近30天'}]" label="时间" single-line></v-select>
        </v-flex>
        <v-flex xs3>
          <v-select v-model="filter.deviceType" :value="filter.deviceType" :items="deviceTypes" label="设备类型" single-line></v-select>
        </v-flex>
      </v-layout>
    </v-container>
  </ag-statistics>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import AgStatistics from './mixins/AgStatistics'

import Period from '@agrithings/common/util/period'

function optionOf (legendData, data) {
  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      bottom: '10px',
      data: legendData
    },
    series: [
      {
        name: '传感器故障',
        type: 'pie',
        radius: ['50%', '70%'],
        avoidLabelOverlap: true,
        labelLine: {
          normal: {
            show: false
          }
        },
        data: data
      }
    ]
  }
}

export default {
  name: 'ag-sensor-fault',
  props: {
    devices: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      filter: {
        date: 1,
        deviceType: null
      },
      deviceTypes: [],
      option: null
    }
  },
  watch: {
    filter: {
      deep: true,
      handler (v) {
        this.refresh()
      }
    }
  },
  created () {
    let devices = this.$props.devices
    let deviceTypeIds = devices.map(d => d.type)
    let deviceTypes = deviceTypeIds
      .map(tid => this.$store.state['base.device.type'].items.find(t => {
        return t._id.$oid === tid.$oid
      })
      ).map(t => {
        return { value: t._id.$oid, text: t.name }
      })
    this.deviceTypes = deviceTypes
    this.filter.deviceType = deviceTypes.length ? deviceTypes[0].value : null

    this.refresh()
  },
  methods: {
    refresh () {
      let stopDate = new Date()
      stopDate.setDate(stopDate.getDate())
      stopDate.setHours(0, 0, 0, 0)
      let stopTime = stopDate.getTime()
      let startTime = stopDate - this.filter.date * Period[2]

      let devices = this.$props.devices
      let deviceIds = devices.filter(d => d.type.$oid === this.filter.deviceType).map(d => d._id)

      mongo.db().collection('tenant.report.sensor_fault').aggregate([
        { $match: { device: { $in: deviceIds }, period: 2, time: { $gte: startTime, $lt: stopTime } } },
        { $group: { num_dataFault: { $sum: '$dataFault.total' }, num_hdFault: { $sum: '$hdFault.total' }, _id: '$sensorType' } },
        { $project: { total: { $sum: ['$num_dataFault', '$num_hdFault'] } } }
      ]).then((items) => {
        let data = []
        items.forEach(item => {
          data.push({ value: item.total, name: this.$store.state['base.sensor.type'].items.find(st => st._id.$oid === item._id.$oid).name })
        })

        let legendData = this.$store.state['base.sensor.type'].items.map(st => st.name)
        this.option = optionOf(legendData, data)
      })
    }
  },
  components: {
    AgStatistics
  }
}
</script>
