<template style="background-color:#fff">
  <v-layout row
            wrap
            v-if="tableFlag && tf">
    <v-flex xs12
            v-if="sensorTypeArr['60'] && f2">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData2"
                 height="200px"
                 :settings="chartSettings2"
                 :colors="['#A9E5E1']"
                 :grid="grid1"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['66'] && f3">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData3"
                 height="200px"
                 :settings="chartSettings3"
                 :colors="['#D599B0']"
                 :grid="grid1"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
  </v-layout>
  <div v-else-if="!tableFlag"
       style="position:absolute;left:0;right:0;bottom:0;top:0;z-index:9999;opacity:0.3;text-align:center;line-height:800px;">
    <img src="/static/img/loading.gif" />
  </div>
  <div v-else
       style="text-align:center;margin-top:25%;min-height:200px;">
    暂无历史数据
  </div>
</template>
<script>
import mongo from '@vehiclecloud/mongo-rest-client'
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  name: 'rain-device-access-data-chart',
  props: {
    device: {
      type: Object,
      required: true
    },
    start: null,
    end: null
  },
  data () {
    return {
      tableFlag: false,
      devType: {},
      sensorTypeArr: {},
      sensorType: [],
      chartData2: {},
      chartSettings2: {},
      chartData3: {},
      chartSettings3: {},
      grid1: {},
      f2: false,
      f3: false,
      tf: false
    }
  },
  created () {
    let _this = this
    _this.devType = this.$store.state['base.device.type'].items.filter(value => value._id.$oid === _this.device.type.$oid)
    let ss = _this.devType[0].sensorTypes
    let sa = []
    if (ss && ss.length > 0) {
      ss.forEach(_s => {
        sa.push(_this.$store.state['base.sensor.type'].items.filter(_vl => _s.$oid === _vl._id.$oid)[0])
      })
      if (sa && sa.length > 0) {
        sa.forEach(_s => {
          if (_s.code === '60') _this.sensorTypeArr['60'] = true
          else if (_s.code === '66') _this.sensorTypeArr['66'] = true
        })
      }
    }
    this.grid1 = {
      show: true,
      left: 20,
      top: 30,
      height: 150
    }
    this.chartSettings2 = {
      yAxisName: ['降雨量(mm)'],
      area: true
    }
    this.chartSettings3 = {
      yAxisName: ['电量(%)'],
      area: true
    }
    this.list(_this.start, _this.end)
  },
  methods: {
    fmtDay (time) {
      let d = new Date(+time)
      return `${pre(d.getMonth() + 1)}/${pre(d.getDate())} ${pre(d.getHours())}:${pre(d.getMinutes())}`
    },
    list: function (start, end) {
      let _this = this
      _this.tableFlag = false
      let dlcol = ['时间', '电量(%)']
      let rrcol = ['时间', '降雨量(mm)']
      let dlrows = []
      let rrrows = []
      let ps = mongo.db().collection('tenant.device_access_data_history').find({ filter: { device: { '$oid': this.device._id.$oid }, time: { '$gte': start, '$lte': end } }, sort: { 'time': -1 } })
      ps.then(items => {
        _this.f2 = false
        _this.f3 = false
        _this.tf = false
        items.items.forEach(item => {
          rrrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '降雨量(mm)': item.data['60'].v === 9999 ? 0 : item.data['60'].v
          })
          dlrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '电量(%)': item.data['66'].v
          })
        })
        dlrows.length > 0 ? _this.f3 = true : _this.f3 = false
        rrrows.length > 0 ? _this.f2 = true : _this.f2 = false
        _this.tf = _this.f2 || _this.f3
        this.chartData2 = { columns: rrcol, rows: rrrows }
        this.chartData3 = { columns: dlcol, rows: dlrows }
        _this.tableFlag = true
      })
    }
  },
  watch: {
    'start' (value) {
      if (this.end) {
        this.list(value, this.end)
      }
    },
    'end' (value) {
      if (this.start) {
        this.list(this.start, value)
      }
    }
  }
}
</script>
<style>
</style>
