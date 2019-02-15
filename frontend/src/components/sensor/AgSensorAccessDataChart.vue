<template>
  <div>
    <ag-echarts :options="options" :height="'500px'"></ag-echarts>
  </div>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'

import AgEcharts from '@/components/echarts/AgEcharts'

import Period from '@agrithings/common/util/period'

import SensorAccessData from './mixins/sensor-access-data'

const codeMap = {
  '64': '数据丢失',
  '65': '超出量程上限',
  '66': '超出量程下限',
  '67': '未知状态',
  '68': '违反约束',
  '128': '设备掉线',
  '129': '电量低进入休眠',
  '130': '数据错误或丢失',
  '131': '未知错误',
  '255': '未定义',
  '257': '超出告警下限',
  '258': '超出告警上限'
}

const legendData = Object.keys(codeMap).reduce((a, k) => {
  a.push(codeMap[k])
  return a
}, [])

const $group = Object.keys(codeMap).reduce((r, k) => {
  r[k] = { $sum: '$faults.' + k }
  return r
}, { _id: null })

function optionsOf (legendSelected, serieData) {
  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b} : {c} ({d}%)'
    },
    legend: {
      type: 'scroll',
      orient: 'vertical',
      right: 20,
      top: 20,
      bottom: 20,
      data: legendData,
      selected: legendSelected
    },
    series: [
      {
        name: '类型',
        type: 'pie',
        radius: '55%',
        center: ['40%', '50%'],
        data: serieData,
        itemStyle: {
          emphasis: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
}

export default {
  name: 'ag-sensor-access-data-chart',
  mixins: [SensorAccessData],
  data () {
    return {
      options: null
    }
  },
  methods: {
    async refresh () {
      let [result] = await mongo.db().collection('tenant.report.sensor_fault').aggregate([
        {
          $match: {
            device: this.device._id,
            sensorType: this.sensor._id,
            period: 2,
            time: { $gte: this.startTime, $lt: this.stopTime + Period.day }
          }
        },
        { $group: $group }
      ])
      let legendSelected = {}
      let serieData = []
      Object.keys(codeMap).forEach(k => {
        let name = codeMap[k]
        let value = (result && result[k]) || 0
        legendSelected[name] = !!value
        serieData.push({ name, value })
      })
      this.options = optionsOf(legendSelected, serieData)
    }
  },
  components: {
    AgEcharts
  }
}
</script>
