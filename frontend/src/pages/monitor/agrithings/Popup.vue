<template>
  <div>
    <v-card>
      <v-toolbar color="blue" height="60px">
        <v-toolbar-title class="body-1 white--text">
          {{ device.name }} ({{ device.code }})
          <a class="white--text ml-2" @click="openDialog('detail', device)">more</a>
        </v-toolbar-title>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text style="width: 400px; padding: 16px 0;">
        <v-container>
          <template v-if="device.accessState && device.accessState.data">
            <template v-if="Object.keys(device.accessState.data).length > 0">
              <v-layout row wrap>
                <v-flex xs6 class="mb-3 pr-3" v-for="col in collectors" :key="col.code">
                  <v-layout>
                    <strong class="flex" :title="accessDataText(device.accessState.data[col.code], col.code)">{{ sensorTypeVal(col.code, 'name') || '-' }}:
                      <span class="ml-2">{{ accessDataText(device.accessState.data[col.code], col.code) }}</span>
                    </strong>
                    <strong style="flex-shrink: 0;">
                      <span :class="{'blue--text': device.accessState.data[col.code] && device.accessState.data[col.code].as === 1, 'warning--text': device.accessState.data[col.code] && device.accessState.data[col.code].status !== 1}" :title="device.accessState.data[col.code] && accessStatus[device.accessState.data[col.code].as] || '未知状态'">{{ device.accessState.data[col.code] && accessStatus[device.accessState.data[col.code].as] || '未知状态' }}</span>
                    </strong>
                  </v-layout>
                </v-flex>
              </v-layout>
              <v-layout row wrap>
                <v-flex xs12 class="mb-3" v-for="ctl in controllers" :key="ctl.code">
                  <div class="mb-3 pr-3">
                    <strong>
                      {{ ctl.name }}:
                    </strong>
                  </div>
                  <v-layout row wrap>
                    <template v-for="(channel, cnIndex) in ctl.channels">
                      <v-flex xs6 :key="cnIndex" class="pr-3 pl-2">
                        <template v-for="(command, cmIndex) in channel.commands">
                          <v-layout row wrap :key="cmIndex">
                            <v-flex xs6 style="margin-top:7px">开关{{channel.code}}:</v-flex>
                            <v-flex xs6 v-if="sensorAccessDataOf(ctl, channel, command) && sensorAccessDataOf(ctl, channel, command).v !== undefined">
                              <v-switch :input-value="device.accessState.data[(ctl.type - 1) + ':' + ctl.code + ':' + (channel.code + '' + command.code)].v" :disabled="!!device.accessState.data[(ctl.type - 1) + ':' + ctl.code + ':' + (channel.code + '' + command.code)].loading" :loading="!!device.accessState.data[(ctl.type - 1) + ':' + ctl.code + ':' + (channel.code + '' + command.code)].loading" hide-details :true-value="1" :false-value="0" @change="changeControllerStatus($event, ctl, channel, command)"></v-switch>
                            </v-flex>
                            <v-flex xs6 style="margin-top:7px" v-else>
                              <i class='red--text'>尚未上报状态</i>
                            </v-flex>
                            <div class='blue--text' v-if="controllerControlDataOf(ctl, channel, command) && controllerControlDataOf(ctl, channel, command).time">{{formatTime(controllerControlDataOf(ctl, channel, command).time.$numberLong)}}</div>
                            <div class='red--text' v-else>无操作记录</div>
                          </v-layout>
                        </template>
                      </v-flex>
                    </template>
                  </v-layout>
                </v-flex>
              </v-layout>
            </template>
            <template v-else>
              <v-layout row v-if="device.accessState.code && device.accessState.code.some(c => c === 2003)">
                <v-flex xs12 class="text-xs-center body-1">
                  <div class='red--text'>设备已离线</div>
                </v-flex>
              </v-layout>
            </template>
            <v-layout row>
              <v-flex xs12 class="mt-4 pr-3 text-xs-right body-1">
                <div>上报时间: {{ accessTime }}</div>
              </v-flex>
            </v-layout>
          </template>
          <v-layout row v-else>
            <v-flex xs12 class="text-xs-center body-1">
              <div class='red--text'>设备未上报</div>
            </v-flex>
          </v-layout>
        </v-container>
      </v-card-text>
    </v-card>
    <ag-device-access-data-dialog :show.sync="dialog.detail" :device="dialog.item"></ag-device-access-data-dialog>
    <v-snackbar :timeout="3000" top color="light-green" v-model="snackbar.setStatusSucceed">
      操作提示: {{ snackbar.hint }}
    </v-snackbar>
    <v-snackbar :timeout="3000" top color="red accent-1" v-model="snackbar.setStatusFailed">
      操作提示: {{ snackbar.hint }}
    </v-snackbar>
  </div>
</template>

<script>
import { util, data } from '@vehiclecloud/json-schema'

import { sensorTypeVal, accessDataText, accessDataOf } from '@/pages/tenant/util'

import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'

import AgDeviceAccessDataDialog from '@/components/device/AgDeviceAccessDataDialog'

import commonSchema from '@/schema/common'

import mongo from '@vehiclecloud/mongo-rest-client'

import GrpcApi, { ByteString } from '@vehiclecloud/grpc-websocket-client'

function fmtTime (v) {
  let d = new Date(+v)
  return `${util.pad(d.getFullYear())}-${util.pad(d.getMonth() + 1)}-${util.pad(d.getDate())} ${util.pad(d.getHours())}:${util.pad(d.getMinutes())}`
}

export default {
  name: 'ag-monitor-agrithings-popup',
  mixins: [ItemDialog],
  props: {
    device: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      dialog: {
        detail: false
      },
      accessStatus: data.enumsOf(commonSchema.definitions.accessStatus.items).reduce((m, e) => {
        m[e.value] = e.text
        return m
      }, {}),
      access: {
        serverRpc: new GrpcApi.ServerRpcV1()
      },
      snackbar: {
        setStatusSucceed: false,
        setStatusFailed: false,
        hint: ''
      }
    }
  },
  computed: {
    accessTime () {
      return (this.device.accessState && this.device.accessState.time && fmtTime(this.device.accessState.time.$numberLong)) || '-'
    },
    collectors () {
      // TODO: type will be 0
      return this.sensorsOf(1)
    },
    controllers () {
      // TODO: type will be 1
      return this.sensorsOf(2)
    }
  },
  destroyed () {
    this.access.serverRpc.close()
    this.controllers.forEach(ctl => {
      ctl.channels.forEach(channel => {
        channel.commands.forEach(command => {
          this.device.accessState.data[`${ctl.type - 1}:${ctl.code}:${channel.code + '' + command.code}`].loading = false
        })
      })
    })
  },
  methods: {
    sensorTypeVal,
    accessDataText,
    accessDataOf (sensorTypeCode) {
      return accessDataOf(this.device, sensorTypeCode)
    },
    changeControllerStatus (value, sensor, channel, command) {
      this.$set(this.device.accessState.data[(sensor.type - 1) + ':' + sensor.code + ':' + (channel.code + '' + command.code)], 'loading', true)

      // 先更新 device.controlData.x.y.z.status 为2:未知
      let controlDataPath = `controlData.${sensor.code}.${channel.code}.${command.code}`
      let opTime = new Date().getTime()
      let setObj = {}
      setObj[controlDataPath + '.time'] = opTime
      setObj[controlDataPath + '.status'] = 2
      mongo.db().collection('tenant.device').update({
        filter: { _id: this.device._id },
        update: { $set: setObj }
      })

      // 更新页面值
      let commandControlData = {
        time: { $numberLong: opTime },
        status: 2,
        v: value
      }
      if (this.device.controlData && this.device.controlData[sensor.code] && this.device.controlData[sensor.code][channel.code]) {
        this.device.controlData[sensor.code][channel.code][command.code] = commandControlData
      } else if (this.device.controlData && this.device.controlData[sensor.code]) {
        this.device.controlData[sensor.code][channel.code] = {}
        this.device.controlData[sensor.code][channel.code][command.code] = commandControlData
      } else if (this.device.controlData) {
        this.device.controlData[sensor.code] = {}
        this.device.controlData[sensor.code][channel.code] = {}
        this.device.controlData[sensor.code][channel.code][command.code] = commandControlData
      } else {
        this.device.controlData = {}
        this.device.controlData[sensor.code] = {}
        this.device.controlData[sensor.code][channel.code] = {}
        this.device.controlData[sensor.code][channel.code][command.code] = commandControlData
      }

      // 下发指令
      this.access.serverRpc.sendServerRpc({
        deviceType: this.deviceTypeOf(this.device),
        deviceId: this.device.code,
        rpcData: {
          '@type': 'type.googleapis.com/com.carcloud.gateway.bean.rpc.RpcGenericBinaryV1',
          cmdId: 0xA1,
          cmdData: ByteString.copyFrom([1, sensor.code, parseInt(parseInt(channel.code + '' + command.code), 16), value, 0])
        }
      }, res => {
        console.log(res)
        if (res.resultCode === 'RESULT_SUCCESS') {
          // 解析返回的数据，当超过127时，TextEncoder会有问题
          let resData = res.resultData && res.resultData.cmdData
          if (resData) {
            let bytes = new TextEncoder().encode(atob(resData))
            console.log('------------- 终端操作结果：' + bytes[2])
            let succeed = (bytes[2] === 0)
            if (succeed) {
              this.device.accessState.data[(sensor.type - 1) + ':' + sensor.code + ':' + (channel.code + '' + command.code)].v = value
              this.$set(this.device.accessState.data[(sensor.type - 1) + ':' + sensor.code + ':' + (channel.code + '' + command.code)], 'loading', false)
              this.snackbar.setStatusSucceed = true
              this.snackbar.hint = `开关${channel.code} ${value === 1 ? '打开' : '关闭'} 成功`
            } else {
              console.log('终端操作失败')
              this.snackbar.setStatusFailed = true
              this.snackbar.hint = `开关${channel.code} ${value === 1 ? '打开' : '关闭'} 失败`
            }
          }
        } else {
          console.log('终端没有响应数据')
          this.snackbar.setStatusFailed = true
        }

        this.$set(this.device.accessState.data[(sensor.type - 1) + ':' + sensor.code + ':' + (channel.code + '' + command.code)], 'loading', false)
      })
    },
    formatTime (v) {
      return (fmtTime(v) && fmtTime(v).substring(5)) || '-'
    },
    sensorsOf (type) {
      let deviceType = this.$store.state['base.device.type'].items.find(t => t._id.$oid === this.device.type.$oid)
      return this.$store.state['base.sensor.type'].items.filter(t => deviceType.sensorTypes.some(typeId => t._id.$oid === typeId.$oid) && t.type === type)
    },
    sensorAccessDataOf (sensor, channel, command) {
      // TODO -1 will be ignored
      return this.device.accessState.data && this.device.accessState.data[(sensor.type - 1) + ':' + sensor.code + ':' + (channel.code + '' + command.code)]
    },
    controllerControlDataOf (sensor, channel, command) {
      let a = this.device.controlData && this.device.controlData[sensor.code] && this.device.controlData[sensor.code][channel.code] && this.device.controlData[sensor.code][channel.code][command.code]
      return a
    },
    deviceTypeOf (device) {
      let deviceType = 'SENSOR_SHENGU'
      let sensorIds = this.$store.state['base.device.type'].items.find(dt => dt._id.$oid === device.type.$oid).sensorTypes
      let isController = false

      for (var i = 0; i < sensorIds.length; i++) {
        let sensor = this.$store.state['base.sensor.type'].items.find(st => st._id.$oid === sensorIds[i].$oid)
        if (sensor && sensor.type === 2) {
          isController = true
          break
        }
      }

      if (isController) {
        deviceType = 'CONTROLLER_SHENGU'
      }
      return deviceType
    }
  },
  components: {
    AgDeviceAccessDataDialog
  }
}
</script>
