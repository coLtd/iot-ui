<template>
  <v-layout row wrap style="display:flex">
      <div style="width:480px;padding-top:10px;">
        <video :src="aplayer.source" controls="controls" width="480px;" poster="/static/img/vedio_img.png">
        您的浏览器展示不支持该视频播放
        </video>
      </div>
      <div style="padding-left:40px;flex:1;max-width:800px;padding-top:60px;">
        <v-date-picker
          v-model="veido_date"
          :max="maxDate"
          full-width
          no-title
          locale="zh-cn"
          class="mt-3"
        ></v-date-picker>
      </div>
    </v-layout>
</template>
<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import Period from '@agrithings/common/util/period'
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  props: {
    device: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      veido_date: null,
      maxDate: 0,
      aplayer: {
        source: ''
      }
    }
  },
  methods: {
    fmt_Date (time) {
      let d = new Date(+time)
      return `${d.getFullYear()}-${pre(d.getMonth() + 1)}-${pre(d.getDate())}`
    }
  },
  watch: {
    'veido_date' (v) {
      mongo.db().collection('tenant.device_bloomsky_video_data').find({filter: {'device': {'$oid': this.device._id.$oid}, time: new Date(new Date(v).toLocaleDateString()).getTime()}}).then(d => {
        this.aplayer.source = ''
        if (d.items.length > 0) {
          this.aplayer.source = d.items[0].data.v.startsWith('http:') ? d.items[0].data.v : 'http://' + d.items[0].data.v
        }
      })
    }
  },
  created () {
    let nowTime = new Date(new Date().toLocaleDateString()).getTime() - Period.day
    this.maxDate = this.fmt_Date(nowTime)
    mongo.db().collection('tenant.device_bloomsky_video_data').find({filter: {'device': {'$oid': this.device._id.$oid}, time: nowTime}}).then(d => {
      this.aplayer.source = ''
      if (d.items.length > 0) {
        this.aplayer.source = d.items[0].data.v.startsWith('http:') ? d.items[0].data.v : 'http://' + d.items[0].data.v
      }
    })
  }
}
</script>

