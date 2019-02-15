<template>
  <div style="width: 400px;">
    <div style="background-color:#2196F3;width:100%;height:40px;">
      <span class="pl-3"
            style="font-size:15px;color:#fff;line-height:2.5">{{ device.name }}</span>
    </div>
    <div class="">
      <div>
        <ali-player @play="played"
                    autoplay
                    :source="aplayer.source"
                    ref="player"
                    isLive>
        </ali-player>
      </div>
      <div v-show="ctrlop"
           class="container">
        <div class="left">
          <div class="left-item active"
               style="border-left:1px solid #eee"
               @click="setLeftUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-315deg);" />
          </div>
          <div class="left-item active"
               @click="setUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-270deg);" />
          </div>
          <div class="left-item active"
               @click="setRightUp">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-225deg);" />
          </div>
          <div class="left-item active"
               @click="setLeft">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(0deg);" />
          </div>
          <div class="left-item active"
               @click="setRight">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-180deg);" />
          </div>
          <div class="left-item active"
               @click="setLeftDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-45deg);" />
          </div>
          <div class="left-item active"
               @click="setDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-90deg);" />
          </div>
          <div class="left-item active"
               @click="setRightDown">
            <img src="../../../../static/img/sanjiao.png"
                 style="transform:rotate(-135deg);" />
          </div>
        </div>
        <div class="right">
          <div class="button active"
               @click="zoomSmall"
               style="cursor:pointer">-</div>
          <div style="width:50px;text-align:center;">缩放</div>
          <div class="button active"
               @click="zoomBig"
               style="cursor:pointer">+</div>
        </div>
      </div>
      <div v-show="!ctrlop"
           class="container">
      </div>
    </div>
  </div>

</template>

<script>
import VueAliplayer from 'vue-aliplayer'
import axios from 'axios'
// const URL = 'http://localhost:8205/acp-web-monitor/'
const URL = ' http://api.agrithings.cn/'
export default {
  name: 'ag-monitor-ptz-popup',
  props: {
    device: {
      type: Object,
      required: true
    },
    token: ''
  },
  components: {
    'ali-player': VueAliplayer
  },
  data () {
    return {
      aplayer: {
        source: ''
      },
      player: null,
      ctrlop: true
    }
  },
  methods: {
    goMore () {
      this.$router.push({ path: '/monitor/ptz/detail', query: { device: this.device } })
    },
    played () {
      console.log('play callback')
    },
    play: function () {
      const player = this.$refs.player.instance
      player && player.play()
    },
    pause: function () {
      const player = this.$refs.player.instance
      player && player.pause()
    },
    replay: function () {
      const player = this.$refs.player.instance
      player && player.replay()
    },
    ctrRequest (direction) {
      let sef = this
      let code = ''
      let channelNo = ''
      if (sef.device.code.indexOf('-') !== -1) {
        code = sef.device.code.split('-')[0]
        channelNo = sef.device.code.split('-')[1]
      } else {
        code = sef.device.code
        channelNo = 1
      }
      axios.post(URL + 'api/lapp/device/ptz/start?accessToken=' + sef.token + '&deviceSerial=' + code + '&channelNo=' + channelNo + '&direction=' + direction + '&speed=1')
        .then(data => {
          setTimeout(() => {
            axios.post(URL + 'api/lapp/device/ptz/stop?accessToken=' + sef.token + '&deviceSerial=' + code + '&channelNo=' + channelNo)
              .then(data => {
                console.log(1)
              }, err => {
                console.log(err)
              })
          }, 400)
        }, err => {
          console.log(err)
        })
    },
    ctrZoom (direction) {
      let sef = this
      axios.post(URL + 'api/lapp/device/ptz/start?accessToken=' + sef.token + '&deviceSerial=' + sef.device.code + '&channelNo=1&direction=' + direction + '&speed=1')
        .then(data => {
          setTimeout(() => {
            axios.post(URL + 'api/lapp/device/ptz/stop?accessToken=' + sef.token + '&deviceSerial=' + sef.device.code + '&channelNo=1')
              .then(data => {
                console.log(1)
              }, err => {
                console.log(err)
              })
          }, 400)
        }, err => {
          console.log(err)
        })
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
      this.ctrRequest(4)
    },
    zoomBig () {
      this.ctrZoom(8)
    },
    zoomSmall () {
      this.ctrZoom(9)
    }
  },
  mounted () {
    let sef = this
    axios.post(URL + 'api/lapp/token/get?appKey=81e5a657f0b04402a1b40a8cd53b9cf9&appSecret=60778daf62e8691d313c22db7ace5fa1')
      .then(data => {
        sef.token = data.data.data.accessToken
      }, err => {
        console.log(err)
      })
    let type = sef.$store.state['base.device.type'].items.filter(value => value._id.$oid === sef.device.type.$oid)
    let typeParamsId = type[0].paramTypes[0].$oid
    if (sef.device.params) {
      sef.aplayer.source = sef.device.params[typeParamsId]
    }
    if (type[0].gisIcon === 6) {
      sef.ctrlop = false
    }
  },
  create () {
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
.right {
  float: right;
  display: flex;
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

