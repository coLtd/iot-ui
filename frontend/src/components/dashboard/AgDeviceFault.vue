<template>
  <ag-statistics :title="'今日告警/故障'" :options="option"></ag-statistics>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import AgStatistics from './mixins/AgStatistics'

import Period from '@agrithings/common/util/period'

const codeMap = {
  '1001': '传感器告警',
  '1002': '视频越线告警',
  '2001': '数据异常',
  '2002': '硬件故障',
  '2003': '设备离线'
}

const legendData = Object.keys(codeMap).reduce((a, k) => {
  a.push(codeMap[k])
  return a
}, [])

function optionOf (data) {
  let yMax = 5
  yMax = 5 + Math.max.apply(null, data.map(sd => sd.data[0]))

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      bottom: 20,
      data: legendData
    },
    grid: {
      left: '5%',
      right: '5%',
      bottom: '25%',
      containLabel: true
    },
    xAxis: [
      {
        type: 'category',
        data: [''],
        axisTick: {
          alignWithLabel: true
        }
      }
    ],
    yAxis: [
      {
        type: 'value',
        max: yMax
      }
    ],
    series: data
  }
}

export default {
  name: 'ag-device-fault',
  props: {
    devices: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      option: null
    }
  },
  watch: {},
  created () {
    let stopDate = new Date()
    stopDate.setDate(stopDate.getDate())
    stopDate.setHours(0, 0, 0, 0)
    let stopTime = stopDate.getTime()
    let startTime = stopDate - Period[2]

    let deviceIds = this.$props.devices.map(d => d._id)
    mongo.db().collection('tenant.device_access_data').aggregate([
      { $match: { device: { $in: deviceIds }, time: { $gte: startTime, $lt: stopTime + Period[2] } } },
      { $unwind: '$code' },
      { $match: { code: { $in: [1001, 1002, 2001, 2002, 2003] } } },
      { $group: { _id: { code: '$code', device: '$device' } } },
      { $group: { num_code: { $sum: 1 }, _id: '$_id.code' } }
    ]).then((items) => {
      let seriesData = []

      // 没有统计数据时要把默认的显示出来，值为0
      let statisticResultIds = items.map(item => item._id + '')
      Object.keys(codeMap).filter(k => !statisticResultIds.some(srid => srid === k)).forEach(k => items.push({ _id: k, num_code: 0 }))

      items.forEach(item => {
        seriesData.push({
          name: codeMap[item._id + ''],
          type: 'bar',
          data: [item.num_code],
          barWidth: '15px',
          barGap: '2px'
        })
      })
      this.option = optionOf(seriesData)
    })
  },
  components: {
    AgStatistics
  }
}
</script>
