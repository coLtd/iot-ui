<template>
  <div style="width:400px;">
    <div style="background-color:#2196F3;width:100%;height:40px;">
      <div class="pl-2"
           style="display:inline-block;font-size:15px;color:#fff;line-height:2.5;width:335px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis"
           :title="titl">{{device.name}}({{device.code}})</div>
      <span class="pr-4"
            style="display:block;float:right;line-height:38.5px"><a color="black"
           style="font-size:15px;color:#fff;"
           @click="openDialog('detail',device)">详情</a></span>
    </div>
    <div class=""
         style="width: 400px;height: 220px;">
      <img :src="isrc"
           style="height: 100%;width: 100%;" />
    </div>
    <div class="mt-2 pb-1"
         style="font-size:16px;">
      <span class="ml-2"
            style="color:#56A6EA;">{{wd}}℃</span> <span class="ml-2">{{bktime}}</span><span class="ml-2"
            style="cursor:pointer;"
            @click="updateWeather">更新</span>
    </div>
    <bk-device-access-data-dialog :show.sync="dialog.detail"
                                  :device="device"></bk-device-access-data-dialog>
  </div>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import BkDeviceAccessDataDialog from './BkDeviceAccessDataDialog'
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  name: 'ag-monitor-bloomsky-popup',
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
      w: {},
      bktime: null,
      wd: null,
      isrc: '',
      dialog: {
        detail: false
      }
    }
  },
  methods: {
    fmtDate (time) {
      let d = new Date(+time)
      return `${d.getFullYear()}-${pre(d.getMonth() + 1)}-${pre(d.getDate())} ${pre(d.getHours())}:${pre(d.getMinutes())}`
    },
    updateWeather () {
      let p = mongo.db().collection('tenant.device').find({ filter: { _id: { '$oid': this.device._id.$oid } } })
      p.then(items => {
        this.wd = this.device.accessState && this.device.accessState.data && this.device.accessState.data['61'] ? this.device.accessState.data['61'].v : '--'
        this.bktime = this.device.accessState && this.device.accessState.time ? this.fmtDate(this.device.accessState.time.$numberLong) : '--'
        this.isrc = this.device.accessState && this.device.accessState.data ? `http://${this.device.accessState.data['65'].v}` : null
      })
    }
  },
  mounted () {
    this.titl = `${this.device.name}(${this.device.code})`
    this.wd = this.device.accessState && this.device.accessState.data && this.device.accessState.data['61'] ? this.device.accessState.data['61'].v : '--'
    this.bktime = this.device.accessState && this.device.accessState.time ? this.fmtDate(this.device.accessState.time.$numberLong) : '--'
    this.isrc = this.device.accessState && this.device.accessState.data ? `http://${this.device.accessState.data['65'].v}` : null
  },
  components: {
    BkDeviceAccessDataDialog
  }
}
</script>
