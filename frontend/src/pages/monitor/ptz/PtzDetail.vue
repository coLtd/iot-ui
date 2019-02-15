<template>
  <div class="pt-2 pl-2">
    <div>
      <p class="text-md-left pt-2" style="font-size: large"></p>
    </div>
    <div>
      <v-layout row>
        <v-flex xs4 md2>
          <span>设备类型:</span>
          <span class="pl-2"></span>
        </v-flex>
        <v-flex xs4 md2>
          <span>地块:</span>
          <span class="pl-2"></span>
        </v-flex>
        <v-flex xs4 md2>
          <span>地块管理员:</span>
          <span class="pl-2"></span>
        </v-flex>
      </v-layout>
    </div>
    <div class="pt-4">
      <v-tabs v-model="active">
        <v-tab :key="0">
          视频录像
        </v-tab>
        <v-tab :key="1">
          多光谱拍照
        </v-tab>
        <v-tab-item :key="0">
          <vedio></vedio>
        </v-tab-item>
        <v-tab-item :key="1">
          <poto></poto>
        </v-tab-item>
      </v-tabs>
    </div>
  </div>
</template>
<script>
import VueAliplayer from 'vue-aliplayer'
import VedioList from '@/pages/monitor/ptz/VedioList'
import PotoList from '@/pages/monitor/ptz/PotoList'
export default {
  name: 'monitor-ptz-detail',
  data () {
    return {
      aplayer: {
        source: 'rtmp://rtmp.open.ys7.com/openlive/eec42174c851476a8ba3d2888a25aaf4'
      },
      active: null,
      device: {
        name: 'xxx',
        type: 'xxx',
        farmland: 'xxx',
        user: 'xxx'
      },
      params: {
        startDate: null,
        endDate: null
      },
      search: {
        schema: {
          type: 'object',
          'properties': {
            startDate: {
              type: 'number',
              title: '开始日期',
              format: 'date'
            },
            endDate: {
              'type': 'number',
              title: '结束日期(时间间隔7天以内)',
              format: 'date'
            }
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          startDate: { 'ui:class': { flex: true, xs2: true, 'pr-3': true }, 'ui:props': { clearable: true } },
          endDate: { 'ui:class': { flex: true, xs2: true, 'pr-3': true }, 'ui:props': { clearable: true } }
        }
      }
    }
  },
  methods: {
    goBack () {
      this.$router.back()
    }
  },
  created () {
    this.device = this.$route.query.device
    console.log(JSON.stringify(this.device))
  },
  mounted () { },
  components: {
    'ali-player': VueAliplayer,
    'vedio': VedioList,
    'poto': PotoList
  }
}
</script>
