<template style="background-color:#fff">
  <v-layout row
            wrap
            v-if="tableFlag && tf">
    <v-flex xs12
            v-if="sensorTypeArr['61'] && f8">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData"
                 height="200px"
                 :settings="chartSettings"
                 :colors="['#A9E5E1']"
                 :grid="grid4"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['62'] && f1">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData1"
                 height="200px"
                 :settings="chartSettings1"
                 :colors="['#D6D7D9']"
                 :grid="grid5"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['63'] && f2">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData2"
                 height="200px"
                 :settings="chartSettings2"
                 :colors="['#A9E5E1']"
                 :grid="grid6"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['64'] && f7">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData7"
                 height="200px"
                 :settings="chartSettings7"
                 :yAxis="w_direction"
                 :tooltip="tooltip"
                 :colors="['#F5784E']"
                 :grid="grid3"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['67'] && f4">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData4"
                 height="200px"
                 :settings="chartSettings4"
                 :colors="['#95C4E3']"
                 :grid="grid2"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['69'] && f5">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData5"
                 height="200px"
                 :settings="chartSettings5"
                 :colors="['#C0C2C4']"
                 :grid="grid4"
                 :legend-visible="false"></ve-line>
      </v-card>
    </v-flex>
    <v-flex xs12
            v-if="sensorTypeArr['68'] && f6">
      <v-card dark
              color="white"
              style="max-height:200px;">
        <ve-line :data="chartData6"
                 height="200px"
                 :settings="chartSettings6"
                 :colors="['#F9BBA9']"
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
function winDirection (direction) {
  let b = direction.replace('"', '').replace('"', '')
  switch (b) {
    case 'N':
      return 0
    case 'NE':
      return 45
    case 'E':
      return 90
    case 'SE':
      return 135
    case 'S':
      return 180
    case 'SW':
      return 225
    case 'W':
      return 270
    case 'NW':
      return 315
    default:
      return '-'
  }
}
function windfomat (direction) {
  switch (direction) {
    case 0:
      return '北风'
    case 45:
      return '东北风'
    case 90:
      return '东风'
    case 135:
      return '东南风'
    case 180:
      return '南风'
    case 225:
      return '西南风'
    case 270:
      return '西风'
    case 315:
      return '西北风'
    default:
      return ''
  }
}
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  name: 'bk-device-access-data-chart',
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
      w_direction: {
        name: '风向',
        axisLabel: {
          formatter: function (value) {
            let temp = []
            if (value === 0) {
              temp.push('北风')
            } else if (value === 45) {
              temp.push('东北风')
            } else if (value === 90) {
              temp.push('东风')
            } else if (value === 135) {
              temp.push('东南风')
            } else if (value === 180) {
              temp.push('南风')
            } else if (value === 225) {
              temp.push('西南风')
            } else if (value === 270) {
              temp.push('西风')
            } else if (value === 315) {
              temp.push('西北风')
            }
            return temp
          }
        },
        max: 315,
        interval: 45
      },
      tooltip: {
        formatter: function (params, ticket, callback) {
          return params.name + '</br>风向(°):&nbsp&nbsp' + params.value + '</br>风向:&nbsp&nbsp' + windfomat(params.value)
        }
      },
      tableFlag: false,
      devType: {},
      sensorTypeArr: {},
      sensorType: [],
      chartData: {},
      chartSettings: {},
      chartData1: {},
      chartSettings1: {},
      chartData2: {},
      chartSettings2: {},
      chartData3: {},
      chartSettings3: {},
      chartData4: {},
      chartSettings4: {},
      chartData5: {},
      chartSettings5: {},
      chartData6: {},
      chartSettings6: {},
      chartData7: {},
      chartSettings7: {},
      grid: {},
      grid1: {},
      grid2: {},
      grid3: {},
      grid4: {},
      grid6: {},
      f1: false,
      f2: false,
      f3: false,
      f4: false,
      f5: false,
      f6: false,
      f7: false,
      f8: false,
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
          _s.code === '61' ? _this.sensorTypeArr['61'] = true : _s.code === '62' ? _this.sensorTypeArr['62'] = true : _s.code === '63' ? _this.sensorTypeArr['63'] = true : _s.code === '64' ? _this.sensorTypeArr['64'] = true : _s.code === '65' ? _this.sensorTypeArr['65'] = true : _s.code === '66' ? _this.sensorTypeArr['66'] = true : _s.code === '67' ? _this.sensorTypeArr['67'] = true : _s.code === '68' ? _this.sensorTypeArr['68'] = true : _s.code === '69' ? _this.sensorTypeArr['69'] = true : _this.sensorTypeArr['70'] = true
        })
      }
    }
    this.chartSettings = {
      yAxisName: ['温度(℃)'],
      colors: ['#A7E5E2'],
      area: true
    }
    this.grid1 = {
      show: true,
      left: 24,
      top: 30,
      height: 150
    }
    this.grid6 = {
      show: true,
      left: 30,
      top: 30,
      height: 150
    }
    this.grid2 = {
      show: true,
      left: 30,
      top: 30,
      height: 150
    }
    this.grid3 = {
      show: true,
      top: 30,
      height: 150,
      left: 30
    }
    this.grid4 = {
      show: true,
      left: 20,
      top: 30,
      height: 150
    }
    this.grid5 = {
      show: true,
      left: 30,
      top: 30,
      height: 150
    }
    this.chartSettings1 = {
      yAxisName: ['湿度(%)'],
      area: true
    }
    this.chartSettings2 = {
      yAxisName: ['风速(m/s)'],
      area: true
    }
    this.chartSettings3 = {
      yAxisName: ['电量(%)'],
      area: true
    }
    this.chartSettings4 = {
      yAxisName: ['大气压(hPa)'],
      area: true
    }
    this.chartSettings5 = {
      yAxisName: ['每小时降雨量(mm)'],
      area: true
    }
    this.chartSettings6 = {
      yAxisName: ['紫外线指数(lux)'],
      area: true
    }
    this.chartSettings7 = {
      yAxisName: ['风向'],
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
      let wdcol = ['时间', '温度(°C)']
      let sdcol = ['时间', '湿度(%)']
      let dlcol = ['时间', '电量(%)']
      let wscol = ['时间', '风速(m/s)']
      let presscol = ['时间', '大气压(hPa)']
      let rrcol = ['时间', '每小时降雨量(mm)']
      let uvcol = ['时间', '紫外线指数(%)']
      let wdicol = ['时间', '风向(°)']
      let wdrows = []
      let sdrows = []
      let dlrows = []
      let wsrows = []
      let pressrows = []
      let rrrows = []
      let uvrows = []
      let wdirows = []
      let ps = mongo.db().collection('tenant.device_access_data_history').find({ filter: { device: { '$oid': this.device._id.$oid }, time: { '$gte': start, '$lte': end } }, sort: { 'time': 1 } })
      ps.then(items => {
        _this.f1 = false
        _this.f2 = false
        _this.f3 = false
        _this.f4 = false
        _this.f5 = false
        _this.f6 = false
        _this.f7 = false
        _this.f8 = false
        _this.tf = false
        items.items.forEach(item => {
          wdrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '温度(°C)': item.data['61'].v
          })
          sdrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '湿度(%)': item.data['62'].v
          })
          wsrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '风速(m/s)': item.data['63'].v === 9999 ? 0 : item.data['63'].v
          })
          wdirows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '风向(°)': item.data['64'].v === 9999 ? '-' : winDirection(item.data['64'].v)
          })
          if (item.data['66'] != null) {
            dlrows.push({
              '时间': this.fmtDay(item.time.$numberLong),
              '电量(%)': item.data['66'].v
            })
          }
          pressrows.push({
            '时间': this.fmtDay(item.time.$numberLong),
            '大气压(hPa)': item.data['67'].v
          })
          if (item.data['68'] != null) {
            uvrows.push({
              '时间': this.fmtDay(item.time.$numberLong),
              '紫外线指数(%)': item.data['68'].v === 9999 ? 0 : item.data['68'].v
            })
          }
          if (item.data['69'] != null) {
            rrrows.push({
              '时间': this.fmtDay(item.time.$numberLong),
              '每小时降雨量(mm)': item.data['69'].v === 9999 ? 0 : item.data['69'].v
            })
          }
        })
        if (wdirows.length > 0) {
          if (this.grid3) this.grid3.left = 3
          _this.f7 = true
        } else {
          if (this.grid3) this.grid3.left = 40
          _this.f7 = false
        }
        if (pressrows.length > 0) {
          if (this.grid2) this.grid2.left = 10
          _this.f4 = true
        } else {
          if (this.grid2) this.grid2.left = 30
          _this.f4 = false
        }
        if (sdrows.length > 0) {
          if (this.grid5) this.grid5.left = 15
          _this.f1 = true
        } else {
          if (this.grid5) this.grid5.left = 30
          _this.f1 = false
        }
        wsrows.length > 0 ? _this.f2 = true : _this.f2 = false
        dlrows.length > 0 ? _this.f3 = true : _this.f3 = false
        rrrows.length > 0 ? _this.f5 = true : _this.f5 = false
        uvrows.length > 0 ? _this.f6 = true : _this.f6 = false
        wdrows.length > 0 ? _this.f8 = true : _this.f8 = false
        _this.tf = _this.f1 || _this.f2 || _this.f3 || _this.f4 || _this.f5 || _this.f6 || _this.f7 || _this.f8
        this.chartData = { columns: wdcol, rows: wdrows }
        this.chartData1 = { columns: sdcol, rows: sdrows }
        this.chartData2 = { columns: wscol, rows: wsrows }
        this.chartData3 = { columns: dlcol, rows: dlrows }
        this.chartData4 = { columns: presscol, rows: pressrows }
        this.chartData5 = { columns: rrcol, rows: rrrows }
        this.chartData6 = { columns: uvcol, rows: uvrows }
        this.chartData7 = { columns: wdicol, rows: wdirows }
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
