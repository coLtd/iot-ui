<template>
  <div style='min-width:100px;'>
    <div style='height: 2px;border-bottom: 1px solid #ddd;'></div>
      <v-layout row style='margin-top: 20px'>
        <v-flex xs6 sm6 md6 lg6   style='line-height: 34px'>
          <label>规则名称:</label>
          <input type='text'  style='width: 83%;height:34px; border:1px solid #ddd;padding: 10px' placeholder='请输入规则名称' >
        </v-flex>
        <v-flex xs6 sm6 md6 lg6   style='line-height: 34px'>
          <label>执行周期:</label>
          <input type='text'  style='width: 83%;height:34px; border:1px solid #ddd;padding: 10px' placeholder='请输入规则名称' >
        </v-flex>
      </v-layout>
       <br/>
      <v-layout>
        <v-flex xs6 sm6 md6 lg6 style='line-height: 34px'>
          <label>触发时间:</label>
          <input type='text'  style='width: 83%;height:34px; border:1px solid #ddd;padding: 10px' placeholder='请输入触发时间' >
          </v-flex>
      </v-layout>
      <br/>
    <!-- main -->
    <ag-tree-explore>
      <template slot='sidebar'>
        <div style='width: 100%;height: 54px;line-height: 4.5;background-color: #3BBAAF;text-align:center;' >
          拍照点位
        </div>
        <div style='height: calc(100% - 139px)'></div>
        <v-btn style='margin-left:15%;'>播放/暂停</v-btn>
        <v-btn @click="setAddPotoPoint">添加拍照点</v-btn>
      </template>
      <div style='width:100%;height:70%; border-bottom:solid 1px #ccc;'>
        <div v-if="!preview" style='width:100%;height:100%;text-align:center;'>
         <ali-player
            @play="played"
            autoplay="true"
            :source="aplayer.source"
            ref="player"
            height='430px'
          >
          </ali-player>
        </div>
        <div v-else style='width:100%;height:100%;text-align:center;'>
            <img src='../../../../static/img/icon-photo-ctr.png'/>
        </div>
      </div>
      <div style='display:flex;'>
          <div style='width:120px;'>
            <span style='display:block;margin-left:40px;line-height:8;'>拍摄角度:</span>
          </div>
          <div style='overflow:hidden;flex:1;margin-left20px;'>
            <div style='position:relative;min-width:150px;height:150px;margin-top:30px;margin-left:30px;'>
              <img id='img-bottom' src='../../../../static/img/icon-photo-ctr.png'  @click="setDown"/>
              <img id='img-top' src='../../../../static/img/icon-photo-ctr.png' />
              <img id='img-left' src='../../../../static/img/icon-photo-ctr.png' />
              <img id='img-right' src='../../../../static/img/icon-photo-ctr.png' />      
              <img id='img-left-top' src='../../../../static/img/icon-photo-ctr.png' />
              <img id='img-right-top' src='../../../../static/img/icon-photo-ctr.png' />
              <img id='img-right-bottom' src='../../../../static/img/icon-photo-ctr.png' />
              <img id='img-left-bottom' src='../../../../static/img/icon-photo-ctr.png' />
              <div id='grad'></div>
            </div>
          </div>
          <div style=''>
            <span style='display:block;line-height:7;margin-right:20px;margin-top:20px;'>停留时间:</span>
          </div>
          <div style=''>
            <div style="line-height: 2.5;width:80px;margin-top:20px;">
              <v-select
                :items='items'
                v-model='e1'
                label=''
                single-line
                bottom
              ></v-select>
              </div>
          </div>
          <div style='flex:4;margin-left:50px;'>
            <v-slider :label='ex1.label' v-model='ex1.val'  :color='ex1.color' :thumb-color="ex1.thColor" :track-color="ex1.trColor" ></v-slider>
            <v-slider :label='ex2.label' v-model='ex2.val' :color='ex2.color' :thumb-color="ex2.thColor" :track-color="ex2.trColor"></v-slider>          </div>
          <div style='height:200px;margin-top75px;margin-left:20px;' >
            <v-btn small color="white">保存</v-btn>
          </div>
        </div>
      </ag-tree-explore>
      <v-layout>
        <v-flex>
          <v-btn>取消</v-btn>
          <v-btn class="primary">提交</v-btn>
        </v-flex>
      </v-layout>
    <!-- dialog -->
    <v-dialog v-model="dialog.isAdd" scrollable max-width="400px">
      <v-card v-if="dialog.isAdd">
        <v-toolbar card color="grey lighten-4">
          <v-toolbar-title>设置拍照点</v-toolbar-title>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card-text>
          <v-container class="px-3">
            <v-layout row>
                <v-flex xs3>
                  <v-subheader>名称:</v-subheader>
                </v-flex>
                <v-flex xs9>
                  <v-text-field
                    label="拍照点名称"
                    single-line
                    solo
                    v-model="potoPointName" 
                  ></v-text-field>
                </v-flex>
              </v-layout>
          </v-container>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn flat color="primary" @click.native="cancle">
            取消
          </v-btn>
          <v-btn flat color="primary" @click.native="closeDialog">
            确认
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
<script>
import AgTreeExplore from '@/layouts/AgTreeExplore'
import VueAliplayer from 'vue-aliplayer'
export default {
  name: 'add-poto-rule',
  data () {
    let self = this
    return {
      aplayer: {
        source: 'rtmp://rtmp.open.ys7.com/openlive/eec42174c851476a8ba3d2888a25aaf4'
      },
      preview: false,
      player: null,
      e1: null,
      potoPointName: '',
      rule: {
        list: {
          collection: 'monitor.rule.photograph',
          schema: {},
          uiSchema: {
            potoname: { 'ui:summary': { 'ui:format': 'tileTitle' } }
          },
          filter: () => ({
            type: 1,
            ...(self.rule.search
              ? { name: { $regex: self.rule.search.trim() } }
              : null)
          }),
          selectFn: this.selectTenant,
          addable: false,
          editable: false,
          removeable: false,
          mainClass: { 'pa-0': true },
          noDivider: true,
          tileActive (item) {
            return item === self.rule.current
          }
        },
        current: null,
        search: null
      },
      dialog: {
        isAdd: false,
        cannotUnbindManager: false,
        unbind: {
          show: false,
          resolve: null,
          close (r) {
            self.dialog.unbind.resolve(r)
            self.closeDialog('unbind')
          }
        }
      },
      ex1: { label: '焦距缩放:', val: 0, color: 'green', thColor: 'White', trColor: 'grey100' },
      ex2: { label: '旋转速度:', val: 0, color: 'yellow', thColor: 'White', trColor: 'grey100' },
      items: [
        { text: '1' },
        { text: '2' },
        { text: '3' },
        { text: '4' }
      ]
    }
  },
  watch: {
    'tenant.search' () {
      this.$refs.tenantList.search()
    },
    'dialog.farmland.search' () {
      this.$refs.dialogFarmlandTable.search()
    }
  },
  methods: {
    selectTenant (item) {
      this.tenant.current = item
      if (this.$refs.farmlandTable) this.$refs.farmlandTable.search()
    },
    selectFarmland (item) {
      this.dialog.farmland.selected.push(item)
    },
    isSelectedFarmland (item) {
      return this.dialog.farmland.selected.some(
        f => f._id.$oid === item._id.$oid
      )
    },
    async saveTenantFarmlands () {
      await Promise.all(
        this.dialog.farmland.selected.map(f =>
          this.$refs.farmlandTable.getCollection().update({
            filter: { _id: f._id },
            update: { $set: { tenant: this.tenant.current._id } }
          })
        )
      )
      this.$refs.farmlandTable.search()
      this.closeDialog('farmland')
    },
    unbindFarmland (item) {
      this.farmland.rebindTenant = this.tenant.current
      return this.$refs.farmlandTable.getCollection().update({
        filter: { _id: item._id },
        update: { $unset: { tenant: 1 } }
      })
    },
    rebindFarmland (item) {
      return this.$refs.farmlandTable.getCollection().update({
        filter: { _id: item._id },
        update: { $set: { tenant: this.farmland.rebindTenant._id } }
      })
    },
    setAddPotoPoint () {
      if (this.dialog.isAdd) {
        this.dialog.isAdd = false
      } else {
        this.dialog.isAdd = true
      }
    },
    setUp () {},
    setDown () {
      console.log('haha')
    },
    setLeft () {},
    setRight () {},
    setLeftUp () {},
    setRightUp () {},
    setLeftDown () {},
    setRightDown () {},
    cancle () {
      this.setAddPotoPoint()
    },
    closeDialog () {
      console.log(this.potoPointName)
      this.setAddPotoPoint()
    }
  },
  components: {
    AgTreeExplore,
    'ali-player': VueAliplayer
  }
}
</script>
<style scoped>
#grad {
  font-size: 80px;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: -webkit-radial-gradient(#fff, #d1d1d1);
  background: -o-radial-gradient(#fff, #d1d1d1);
  background: -moz-radial-gradient(#fff, #d1d1d1);
  background: radial-gradient(#fff, #d1d1d1);
}

#img-top {
  top: -26.8px;
  display: block;
  left: 4px;
  position: absolute;
  cursor:pointer;
}
#img-bottom {
  top: 38px;
  display: block;
  left: 5.2px;
  position: absolute;
  transform: rotate(180deg);
  -ms-transform: rotate(180deg);
  -moz-transform: rotate(180deg);
  -webkit-transform: rotate(180deg);
  -o-transform: rotate(180deg);
  cursor:pointer;
}
#img-left {
  top: 6px;
  display: block;
  left: -28px;
  position: absolute;
  transform: rotate(270deg);
  -ms-transform: rotate(270deg);
  -moz-transform: rotate(270deg);
  -webkit-transform: rotate(270deg);
  -o-transform: rotate(270deg);
  cursor:pointer;
}
#img-right {
  top: 5.1px;
  display: block;
  left: 36.5px;
  position: absolute;
  transform: rotate(90deg);
  -ms-transform: rotate(90deg);
  -moz-transform: rotate(90deg);
  -webkit-transform: rotate(90deg);
  -o-transform: rotate(90deg);
  cursor:pointer;
}
#img-left-top {
  top: -17px;
  display: block;
  left: -18.7px;
  position: absolute;
  transform: rotate(316deg);
  -ms-transform: rotate(316deg);
  -moz-transform: rotate(316deg);
  -webkit-transform: rotate(316deg);
  -o-transform: rotate(316deg);
  cursor:pointer;
}
#img-right-top {
  top: -17.8px;
  display: block;
  left: 27.3px;
  position: absolute;
  transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  -moz-transform: rotate(45deg);
  -webkit-transform: rotate(45deg);
  -o-transform: rotate(45deg);
  cursor:pointer;
}
#img-left-bottom {
  top: 29px;
  display: block;
  left: -18px;
  position: absolute;
  transform: rotate(225deg);
  -ms-transform: rotate(225deg);
  -moz-transform: rotate(225deg);
  -webkit-transform: rotate(225deg);
  -o-transform: rotate(225deg);
  cursor:pointer;
}
#img-right-bottom {
  top: 28px;
  display: block;
  left: 28px;
  position: absolute;
  transform: rotate(135deg);
  -ms-transform: rotate(135deg);
  -moz-transform: rotate(135deg);
  -webkit-transform: rotate(135deg);
  -o-transform: rotate(135deg);
  cursor:pointer;
}
</style>
