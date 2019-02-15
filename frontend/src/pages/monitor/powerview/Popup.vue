<template>
  <div style="width: 400px;">
    <div style="background-color:#2196F3;width:100%;height:40px;">
      <span class="pl-3"
            style="font-size:15px;color:#fff;line-height:2.5">{{ device.name }}</span>
      <span class="pr-4"
            style="display:block;float:right;line-height:38.5px"><a color="black"
           style="font-size:15px;color:#fff;"
           @click="openDialog('detail',device)">详情</a></span>
    </div>

    <div>
      <div>
        <ali-player @play="played"
                    autoplay
                    :source="aplayer.source"
                    ref="player"
                    isLive
                    useFlashPrism
                    useH5Prism>
        </ali-player>
      </div>
      <!-- <div>
      <video-player  class="vjs-custom-skin"
            :options="playerOptions"
        ></video-player>
      </div> -->
      <v-alert style="height:1px; text-align: center;"
               :value="alert"
               :color="status"
               transition="scale-transition">{{status=='success'?`照片${photoTime}已保存`:'拍摄失败。'}}
      </v-alert>
      <div v-show="ctrlop"
           class="container">
        <div class="left">
          <div class="left-item active"
               style="border-left:1px solid #eee"
               @click="setLeftUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-315deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-270deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setRightUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-225deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setLeft">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(0deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setRight">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-180deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setLeftDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-45deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-90deg); cursor:pointer;" />
          </div>
          <div class="left-item active"
               @click="setRightDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-135deg); cursor:pointer;" />
          </div>
          <span>&nbsp;&nbsp;&nbsp;</span>
          <div class="right">
            <div class="button active"
                 @click="zoomSmall"
                 style="cursor:pointer">-</div>
            <div style="width:50px;text-align:center;">缩放</div>
            <div class="button active"
                 @click="zoomBig"
                 style="cursor:pointer">+</div>
          </div>
          <span>&nbsp;&nbsp;&nbsp;</span>
          <div class="left-item-1 active"
               @click="capture"
               style="cursor:pointer">
            <img src="../../../../static/img/tupian.png" />
          </div>
        </div>
      </div>
      <div v-show="!ctrlop"
           class="container">
      </div>
    </div>
    <photo-list :show.sync="dialog.detail"
                :device="dialog.item"></photo-list>
  </div>

</template>

<script>
import VueAliplayer from 'vue-aliplayer'
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import axios from 'axios'
import PhotoList from './PhotoListDialog'
import mongo from '@vehiclecloud/mongo-rest-client'
import moment from 'moment'
export default {
  name: 'ag-monitor-powerview-popup',
  mixins: [ItemDialog],
  props: {
    device: {
      type: Object,
      required: true
    },
    token: ''
  },
  components: {
    'ali-player': VueAliplayer,
    PhotoList
  },
  data () {
    return {
      aplayer: {
        source: ''
      },
      player: null,
      ctrlop: true,
      alert: false,
      status: undefined,
      dialog: {
        detail: false
      },
      photoTime: ''
    }
  },
  methods: {
    played () {
    },
    play: function () {
      const player = this.$refs.player.instance
      player && player.reloadPlayer()
    },
    pause: function () {
      const player = this.$refs.player.instance
      player && player.pause()
    },
    replay: function () {
      const player = this.$refs.player.instance
      player && player.replay()
    },
    reload: function () {
      // 修改source地址后
      const player = this.$refs.player
      player && player.reloadPlayer()
    },
    ctrRequest (direction) {
      axios.post(`${this.$store.state.config.pvServer}/api/lapp/device/ptz/start`, JSON.stringify({
        deviceSerial: this.device.code,
        channelNo: 1,
        direction: direction,
        speed: 1
      })).then(response => {
        setTimeout(() => {
          axios.post(`${this.$store.state.config.pvServer}/api/lapp/device/ptz/stop`, JSON.stringify({
            deviceSerial: this.device.code,
            channelNo: 1,
            direction: direction
          })
          ).then(response => { console.log(response) }, err => { console.log(err) })
        }, 400)
      })
        .catch(error => {
          console.log(error)
        })
    },
    capture () {
      let obj = JSON.stringify({
        deviceSerial: this.device.code,
        channelNo: 1,
        led: 0,
        num: 1,
        oss: {
          'endpoint': 'oss-cn-qingdao.aliyuncs.com',
          'accessId': 'LTAI0OGtYpIcPY3F',
          'accessKey': 'GTOksKA7cGIr8P3lvJFqPDjeXaMMmm',
          'bucket': 'iot-oss',
          'dir': 'snap',
          'expireTime': 1800
        }
      })
      axios.post(`${this.$store.state.config.pvServer}/api/lapp/device/capture`, obj).then(response => {
        if (response.data['code'] === 200 && response.data.data['osspicUrl'].length > 0) {
          let list = []
          let time = new Date().getTime()
          for (let i = 0; i < response.data.data['osspicUrl'].length; i++) {
            let p = mongo.db().collection('tenant.device_powerview_data').insert({
              device: this.device._id,
              time: time,
              data: { 'v': response.data.data['osspicUrl'][i] }
            }).then(response => {
              console.log(response)
              this.photoTime = moment(parseInt(response.createdOn.$numberLong)).format('YYYY-MM-DD HH:mm:ss')
            }, error => {
              console.log(error)
            })
            list.push(p)
          }
          Promise.all(list).then(() => {
            this.status = 'success'
            this.alert = true
            setTimeout(() => { this.alert = false }, 2000)
          }, () => {
            this.status = 'error'
            this.alert = true
            setTimeout(() => { this.alert = false }, 2000)
          })
        } else {
          this.status = 'error'
          this.alert = true
          setTimeout(() => { this.alert = false }, 2000)
        }
      }, error => { console.log(error) })
    },

    setUp () {
      this.ctrRequest(0)
    },
    setDown () {
      this.ctrRequest(1)
    },
    setLeft () {
      this.ctrRequest(2)
    },
    setRight () {
      this.ctrRequest(3)
    },
    setLeftUp () {
      this.ctrRequest(4)
    },
    setRightUp () {
      this.ctrRequest(6)
    },
    setLeftDown () {
      this.ctrRequest(5)
    },
    setRightDown () {
      this.ctrRequest(7)
    },
    zoomBig () {
      this.ctrRequest(8)
    },
    zoomSmall () {
      this.ctrRequest(9)
    }
  },
  mounted () {
    let sef = this
    let type = sef.$store.state['base.device.type'].items.filter(value => value._id.$oid === sef.device.type.$oid)
    let typeParamsId = type[0].paramTypes[0].$oid
    if (sef.device.params) {
      sef.aplayer.source = sef.device.params[typeParamsId]
    }
    if (type[0].gisIcon === 6) {
      sef.ctrlop = false
    }
  }
}
</script>
<style>
.direction--point {
  cursor: pointer;
}
.top--left {
  transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  -moz-transform: rotate(45deg);
  -webkit-transform: rotate(45deg);
  -o-transform: rotate(45deg);
  cursor: pointer;
}
.down--left {
  transform: rotate(225deg);
  -ms-transform: rotate(225deg);
  -moz-transform: rotate(225deg);
  -webkit-transform: rotate(225deg);
  -o-transform: rotate(225deg);
  cursor: pointer;
}
.top--right {
  transform: rotate(225deg);
  -ms-transform: rotate(225deg);
  -moz-transform: rotate(225deg);
  -webkit-transform: rotate(225deg);
  -o-transform: rotate(225deg);
  cursor: pointer;
}
.down--right {
  transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  -moz-transform: rotate(45deg);
  -webkit-transform: rotate(45deg);
  -o-transform: rotate(45deg);
  cursor: pointer;
}
.container {
  display: block;
  /* border:1px solid red; */
  overflow: hidden;
}
.left {
  float: left;
  display: flex;
}
.left-item {
  border: 1px solid #eee;
  width: 30px;
  height: 30px;
  border-left: none;
  text-align: center;
}
.left-item img {
  width: 30px;
  height: 30px;
}

.left-item-1 img {
  width: 28px;
  height: 28px;
  cursor: pointer;
  text-align: center;
}
.right {
  float: right;
  display: flex;
  text-align: center;
  padding-top: 10px;
}
.right-item {
  flex: 1;
}
.button {
  width: 15px;
  height: 15px;
  line-height: 15px;
  text-align: center;
  background: #eee;
  border-radius: 2px;
  color: #fff;
}
.active:hover {
  opacity: 0.5;
}
</style>
