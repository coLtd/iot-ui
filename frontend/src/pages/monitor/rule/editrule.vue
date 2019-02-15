<template> 
    <v-container>  
      <v-layout row wrap>
          <v-flex xs1>
             <span style="line-height:5">相机规则启用状态 :</span>
          </v-flex>
          <v-flex xs2>
              <v-radio-group v-model="radioGroup" row>
                 <v-radio
                  label='开启'
                  color="red"
                  value='1'
                ></v-radio>
                <v-radio
                  label='关闭'
                  color="blue"
                  value='0'
                ></v-radio>
              </v-radio-group>
          </v-flex>
          <v-flex xs1>
             <span style="line-height:5">视频规则启用状态 :</span>
          </v-flex>
          <v-flex xs2>
              <v-radio-group v-model="radioGroup" row>
                <v-radio
                  label='开启'
                  color="red"
                  value='1'
                ></v-radio>
                <v-radio
                  label='关闭'
                  color="blue"
                  value='0'
                ></v-radio>
              </v-radio-group>
          </v-flex>
          <v-flex>
            <v-btn small class="primary">添加规则</v-btn>
          </v-flex>
      </v-layout>
      <v-layout row wrap>
        <v-flex xs12 style="">
        <v-tabs
        v-model="active" color=""
         slider-color="cyan">
            <v-tab
              v-for="n in tabsName" :key="n"  >
              {{ n }} 
            </v-tab>
              <v-tab-item>
                  <poto-rule-edit></poto-rule-edit>
              </v-tab-item>
              <v-tab-item>
                  <vdeio-rule-edit></vdeio-rule-edit>
              </v-tab-item>
          </v-tabs>
        </v-flex>
      </v-layout>
    </v-container>
</template>
<script>
import PotoRuleEdit from '@/pages/monitor/rule/PotoRuleEdit'
import VedioRuleEdit from '@/pages/monitor/rule/VedioRuleEdit'

export default {
  name: 'edit-rule',
  data () {
    return {
      radioGroup: 1,
      menu: false,
      modal: false,
      isActive: true,
      tabSoilShow: true,
      tabSoilReportShow: false,
      active: null,
      tabsName: [
        '拍照规则',
        '摄像规则'
      ]
    }
  },
  methods: {
    setTableShow () {
      this.tabSoilShow = true
      this.tabSoilReportShow = false
    },
    setReportShow () {
      this.tabSoilReportShow = true
      this.tabSoilShow = false
    },
    goBack () {
      this.$router.back(-1)
    }
  },
  components: {
    'poto-rule-edit': PotoRuleEdit,
    'vdeio-rule-edit': VedioRuleEdit
  }
}
</script>
<style>
.active{
    color:blue
}
</style>
