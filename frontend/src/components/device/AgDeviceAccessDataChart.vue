<template>
  <div>
    <div v-for="(sensorType, idx) in sensorTypes" :key="sensorType._id.$oid">
      <h4 class="ml-4" :class="{'mt-4': idx > 0}">{{ sensorType.name }}</h4>
      <ag-echarts :options="optionsOf(sensorType, idx)"></ag-echarts>
    </div>
  </div>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'

import AgEcharts from '@/components/echarts/AgEcharts'

import DeviceAccessData from './mixins/device-access-data'

import Period from '@agrithings/common/util/period'

function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}

function fmtTime (time) {
  let d = new Date(time)
  return `${pre(d.getMonth() + 1)}/${pre(d.getDate())} ${pre(d.getHours())}:${pre(d.getMinutes())}`
}

const colors = ['#8c99d1', '#7cc2f7', '#8fe0eb', '#ad9990']

function rgba (color, opacity) {
  return `rgba(${parseInt(color.substr(1, 2), 16)},${parseInt(color.substr(3, 2), 16)},${parseInt(color.substr(5, 2), 16)},${opacity})`
}

export default {
  name: 'ag-device-access-data-chart',
  mixins: [DeviceAccessData],
  props: {
    period: {
      type: Number,
      default: 1
    }
  },
  data () {
    return {
      xAxis: {
        str: null,
        data: null,
        start: null,
        end: null
      },
      yAxis: {
        data: null
      }
    }
  },
  methods: {
    refresh () {
      if (!this.xAxis.data || this.xAxis.start !== this.startTime || this.xAxis.end !== this.stopTime) {
        this.xAxis.data = []
        this.xAxis.str = []
        for (let time = this.startTime; time < this.stopTime; time += Period[this.period]) {
          this.xAxis.data.push(time)
          this.xAxis.str.push(fmtTime(time))
        }
        this.xAxis.start = this.startTime
        this.xAxis.end = this.stopTime
      }
      mongo.db().collection('tenant.report.device_access_data_summary').find({
        filter: {
          device: this.device._id,
          time: { $gte: this.startTime, $lte: this.stopTime },
          period: this.period
        },
        projection: { time: 1, data: 1, _id: -1 },
        sort: { time: 1 }
      }).then(({ items }) => {
        let data = this.sensorTypes.reduce((d, s) => {
          d[s.code] = []
          return d
        }, {})

        let itemMap = items.reduce((m, item) => {
          m[item.time.$numberLong] = item
          return m
        }, {})

        this.xAxis.data.forEach(time => {
          this.sensorTypes.forEach(st => {
            let v = '-'

            let item = itemMap[time]
            if (item) {
              let value = item.data[st.code]
              let times = (value && value.times) || 1
              if (value) v = value.v / times
            }
            data[st.code].push((typeof v === 'number' ? Number((+v).toFixed(2)) : v))
          })
        })

        this.yAxis.data = data
      })
    },
    optionsOf (sensorType, idx) {
      idx = idx % colors.length
      if (!this.xAxis.data || !this.yAxis.data) return null
      let splitLine = {
        show: true,
        lineStyle: { color: colors[idx], opacity: 0.4 }
      }
      let axisLine = {
        lineStyle: splitLine.lineStyle
      }
      return {
        grid: {
          show: true,
          top: 20,
          bottom: 20,
          borderColor: rgba(colors[idx], 0.4),
          x: 70,
          y: 10
        },
        tooltip: {
          trigger: 'axis',
          formatter: `{b}<br/>{a}: {c}${sensorType.data.unit || ''}`
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          axisLine,
          axisLabel: {
            color: '#9e9e9e',
            show: idx === this.sensorTypes.length - 1
          },
          axisTick: { show: false },
          splitLine,
          data: this.xAxis.str
        },
        yAxis: {
          type: 'value',
          axisLine,
          axisLabel: {
            color: '#9e9e9e',
            formatter: `{value}${sensorType.data.unit || ''}`
          },
          axisTick: { show: false },
          splitLine,
          splitNumber: 3,
          scale: true
        },
        series: [{
          name: sensorType.name,
          data: this.yAxis.data[sensorType.code],
          type: 'line',
          smooth: true,
          lineStyle: { color: colors[idx], opacity: 0.4 },
          itemStyle: { color: colors[idx] },
          areaStyle: { color: colors[idx], opacity: 0.8 }
        }]
      }
    }
  },
  components: {
    AgEcharts
  }
}
</script>
