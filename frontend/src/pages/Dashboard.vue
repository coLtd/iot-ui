<template>
  <v-container grid-list-md text-xs-center>
    <v-layout row wrap>
      <v-flex xs3>
        <v-card dark color='purple accent-3' style='overflow: hidden;padding:  0 10px;border-radius: 2px'>
          <v-card-text class="px-0">
            <div style="float:left">
              <p>设备总数</p>
              <p style="font-size:16px;">{{ devices ? devices.length : '-' }} (个)</p>
            </div>
            <v-icon large style="float:right">important_devices</v-icon>
          </v-card-text>
        </v-card>
      </v-flex>
      <v-flex xs3>
        <v-card dark color="amber " style="overflow: hidden;padding:0 10px;border-radius: 2px">
          <v-card-text class="px-0">
            <div style="float:left">
              <p>地块总数</p>
              <p style="font-size:16px;">{{ farmlands ? farmlands.length : '-' }} (个)</p>
            </div>
            <v-icon large style="float:right">widgets</v-icon>
          </v-card-text>
        </v-card>
      </v-flex>
      <v-flex xs3>
        <v-card dark color="blue" style="overflow: hidden;padding: 0 10px;border-radius: 0px">
          <v-card-text class="px-0">
            <div style="float:left">
              <p>企业总数</p>
              <p style="font-size:16px;">{{ tenantCount }} (个)</p>
            </div>
            <v-icon large style="float:right">business</v-icon>
          </v-card-text>
        </v-card>
      </v-flex>
      <v-flex xs3>
        <v-card dark color="deep-orange " style="overflow: hidden;padding:  0 10px;border-radius: 0px">
          <v-card-text class="px-0">
            <div style="float:left">
              <p>面积总数</p>
              <p style="font-size:16px;">{{ acreageTotal }} (亩)</p>
            </div>
            <v-icon large style="float:right">apps</v-icon>
          </v-card-text>
        </v-card>
      </v-flex>
      <v-flex xs6>
        <ag-device-type v-if="devices.length" :devices="devices"></ag-device-type>
      </v-flex>
      <v-flex xs6>
        <ag-device-fault v-if="devices.length" :devices="devices"></ag-device-fault>
      </v-flex>
      <!-- <v-flex xs6>
        <v-card>
          <v-card-title primary-title class="ml-3 pt-3" style="font-size: 17px;color: #525252;">
            <div>设备故障分布</div>
            <v-container fluid>
              <v-layout row wrap>
                <v-flex xs3>
                  <v-select :value="-1" :items="[{value: -1, text: '昨天'}, {value: 7, text: '近7天'}, {value: 30, text: '近30天'}]" label="时间" single-line></v-select>
                </v-flex>
              </v-layout>
            </v-container>
          </v-card-title>
          <v-card-text>
            <ve-map :data="chartData2" height="400px" :settings="chartSettings2" style="max-width: 660px;padding: 10px"></ve-map>
          </v-card-text>
        </v-card>
      </v-flex>
      <v-flex xs6>
        <ag-sensor-fault v-if="devices.length" :devices="devices"></ag-sensor-fault>
      </v-flex> -->
    </v-layout>
  </v-container>
</template>

<script>

import mongo from '@vehiclecloud/mongo-rest-client'

import AgDeviceType from '@/components/dashboard/AgDeviceType'
import AgDeviceFault from '@/components/dashboard/AgDeviceFault'
import AgSensorFault from '@/components/dashboard/AgSensorFault'

export default {
  name: 'dashboard',
  data () {
    return {
      currentStaff: null,
      tenantCount: '-',
      farmlands: null,
      devices: [],
      acreageTotal: '-',
      // todo map
      chartData2: {},
      chartSettings2: {},
      colorArr: ['#2195F1', '#32C687', '#00BBD3', '#FDC006', '#D458E9'],
      colorArr1: ['#2195F1', '#FDC006', '#D458E9', '#FF5651', '#999999']
    }
  },
  created () {
    Promise.all([
      this.$store.dispatch('init', { collection: 'tenant.staff' }),
      this.$store.dispatch('init', { collection: 'base.device.type' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' })
    ]).then(() => {
      this.currentStaff = this.$store.state['tenant.staff'].current

      this.chartData2 = {
        columns: ['位置', '故障数量'],
        rows: [
          { 位置: '吉林', 故障数量: 123 },
          { 位置: '北京', 故障数量: 1223 },
          { 位置: '上海', 故障数量: 2123 },
          { 位置: '浙江', 故障数量: 4123 }
        ]
      }
      this.chartSettings2 = {
        position: 'china',
        selectData: true,
        itemStyle: {
          normal: {
            areaColor: '#F2F2F2',
            borderColor: '#111'
          },
          emphasis: {
            areaColor: '#6CB4EE'
          }
        }
      }
    })
  },
  watch: {
    currentStaff () {
      mongo.db().collection('tenant.staff_roles').first({ filter: { staff: this.currentStaff._id }, projection: { _id: 0, farmlands: 1 } }).then(({ farmlands }) => {
        let farmlandIds = farmlands
        if (farmlandIds.length > 0) {
          mongo.db('iss').collection('tenant.farmland').find({ filter: { _id: { $in: farmlandIds } }, projection: { _id: 1, acreage: 1, tenant: 1 } }).then(({ items, total }) => {
            this.farmlands = items.map(f => f._id)
            this.acreageTotal = Number(items.reduce((init, f) => init + (f.acreage - 0), 0).toFixed(4))
            this.tenantCount = [...new Set(items.map(item => item.tenant.$oid))].length
          })
        }
      })
    },
    farmlands () {
      let farmlands = this.farmlands

      mongo.db().collection('tenant.device').find({ filter: { farmland: { $in: farmlands } } }).then(({ items, total }) => {
        if (total.$numberLong) {
          this.devices = items
        } else {
          this.devices = []
        }
      })

      // mongo.db('iss').collection('tenant.farmland').find({ filter: { _id: { $in: farmlands } } }).then(({ items, total }) => {
      //   if (total.$numberLong) {
      //     this.acreageTotal = items.reduce((init, f) => init + (f.acreage - 0), 0)
      //   } else {
      //     this.acreageTotal = 0
      //   }
      // })
    }
  },
  components: {
    AgDeviceType,
    AgDeviceFault,
    AgSensorFault
  }
}
</script>
