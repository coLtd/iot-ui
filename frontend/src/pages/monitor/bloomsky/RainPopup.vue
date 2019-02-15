<template>
  <div style="width:401px;height:230px">
    <div style="background-color:#2196F3;width:100%;height:40px;">
      <div class="pl-2"
           style="display:inline-block;font-size:15px;color:#fff;line-height:2.5;width:335px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis"
           :title="titl">{{device.name}}({{device.code}})</div>
      <span class="pr-4"
            style="display:block;float:right;line-height:38.5px"><a color="black"
           style="font-size:15px;color:#fff;"
           @click="openDialog('rainDetail',device)">详情</a></span>
    </div>
    <div style="width: 100%;height: 150px;">
      <div class="pl-3"
           style="float:left">
        <p><span style="font-size:13px;line-height:1.5">当前降雨量 : {{rainMm}}毫米</span></p>
        <p><span style="font-size:13px;line-height:1.5">最近一小时降雨量 : {{hourRainMm}}毫米</span></p>
        <p><span style="font-size:13px;line-height:1.5">电量 : {{batt}}%</span></p>
      </div>
      <div class="pl-5"
           style="float:left">
        <p><span style="font-size:13px;line-height:1.5">最近一小时降雨强度 : {{hourRainLevel}}</span></p>
        <p><span style="font-size:13px;line-height:1.5">昨日累计降雨量 : {{dailyRainMM}}毫米</span> </p>
        <!-- <p><span  style="font-size:13px;line-height:1.5">状态 : {{status}}</span></p> -->
      </div>
    </div>
    <div class="pt-1"
         style="font-size:13px;">
      <span style="margin-left:52%">更新时间: {{bktime}}</span>
    </div>
    <bk-device-access-data-dialog :show.sync="dialog.rainDetail"
                                  :device="device"></bk-device-access-data-dialog>
  </div>
</template>

<script>
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import BkDeviceAccessDataDialog from './BkDeviceAccessDataDialog'
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  name: 'ag-monitor-bloomsky-rain-popup',
  mixins: [ItemDialog],
  props: {
    device: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      titl: '',
      rainMm: null,
      hourRainMm: null,
      hourRainLevel: null,
      dailyRainMM: null,
      status: '正常',
      rain: null,
      batt: null,
      bktime: null,
      isrc: '',
      dialog: {
        rainDetail: false
      }
    }
  },
  methods: {
    fmtTime (time) {
      let d = new Date(+time)
      return `${d.getFullYear()}-${pre(d.getMonth() + 1)}-${pre(d.getDate())} ${pre(d.getHours())}:${pre(d.getMinutes())}`
    }
  },
  mounted () {
    this.titl = `${this.device.name}(${this.device.code})`
    this.rainMm = this.device.accessState && this.device.accessState.data && this.device.accessState.data['60'] ? this.device.accessState.data['60'].v === 9999 ? '--' : this.device.accessState.data['60'].v : '--'
    // this.hourRainMm = this.device.accessState && this.device.accessState.data ? this.device.accessState.data['60'].c['1'] === 9999 ? '--' : this.device.accessState.data['60'].c['1'] : '--'
    // this.hourRainLevel = this.device.accessState && this.device.accessState.data ? this.device.accessState.data['60'].c['3'] === '9999' ? '--' : this.device.accessState.data['60'].c['3'] : '--'
    // this.dailyRainMM = this.device.accessState && this.device.accessState.data ? this.device.accessState.data['60'].c['2'] === 9999 ? '--' : this.device.accessState.data['60'].c['2'] : '--'
    this.hourRainMm = this.device.accessState && this.device.accessState.data && this.device.accessState.data['60'] ? this.device.accessState.data['60'].o['hourly_rain_mm'] === 9999 ? '--' : this.device.accessState.data['60'].o['hourly_rain_mm'] : '--'
    this.hourRainLevel = this.device.accessState && this.device.accessState.data && this.device.accessState.data['60'] ? this.device.accessState.data['60'].o['hourly_rain_level'] === '9999' ? '--' : this.device.accessState.data['60'].o['hourly_rain_level'] : '--'
    this.dailyRainMM = this.device.accessState && this.device.accessState.data && this.device.accessState.data['60'] ? this.device.accessState.data['60'].o['daily_rain_mm'] === 9999 ? '--' : this.device.accessState.data['60'].o['daily_rain_mm'] : '--'
    this.batt = this.device.accessState && this.device.accessState.data && this.device.accessState.data['66'] ? this.device.accessState.data['66'].v === 9999 ? '--' : this.device.accessState.data['66'].v : '--'
    this.bktime = this.device.accessState && this.device.accessState.time ? this.fmtTime(this.device.accessState.time.$numberLong) : '--'
  },
  components: {
    BkDeviceAccessDataDialog
  }
}
</script>
