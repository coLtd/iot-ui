<template>
  <ag-statistics :title="'设备分类统计'" :options="option"></ag-statistics>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import AgStatistics from './mixins/AgStatistics'

const codeMap = {
  '1': '微气象',
  '2': '土壤环境',
  '3': '水体环境',
  '4': '视频图像',
  '5': '控制设备'
}

const legendData = Object.keys(codeMap).reduce((a, k) => {
  a.push(codeMap[k])
  return a
}, [])

function optionOf (data) {
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
      left: '2%',
      right: '5%',
      bottom: '25%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      boundaryGap: [0, 0.1]
    },
    yAxis: {
      show: false,
      type: 'category',
      data: ['']
    },
    series: data
  }
}

export default {
  name: 'ag-device-type',
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
    let devices = this.$props.devices

    mongo.db().collection('tenant.device').aggregate([
      { $match: { _id: { $in: devices.map(d => d._id) } } },
      {
        $lookup: {
          from: 'base.device.type',
          localField: 'type',
          foreignField: '_id',
          as: 'type'
        }
      },
      {$unwind: '$type'},
      { $group: { num_tag: { $sum: 1 }, _id: '$type.tag' } }
    ]).then((items) => {
      let seriesData = []
      items.forEach(item => {
        seriesData.push({
          name: codeMap[item._id + ''],
          type: 'bar',
          data: [item.num_tag],
          barWidth: '5px',
          barGap: '5px'
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