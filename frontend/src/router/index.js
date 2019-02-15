import Vue from 'vue'
import Router from 'vue-router'

import { group, r } from '@vehiclecloud/commons/util/router-helpers'

import Dashboard from '@/pages/Dashboard'

import MonitorGis from '@/pages/monitor/Gis'

import BaseDeviceType from '@/pages/base/device/Type'
import BaseSensorType from '@/pages/base/sensor/Type'
import BaseDevicParameter from '@/pages/base/device/ParamType'

import TenantDevice from '@/pages/tenant/Device'
import TenantDeviceAlarmRules from '@/pages/tenant/DeviceAlarmRules'
import TenantDeviceAlarm from '@/pages/tenant/DeviceAlarm'
import TenantDeviceFault from '@/pages/tenant/DeviceFault'
import TenantRole from '@agrithings/common/pages/tenant/Role'
import TenantStaffRoles from '@/pages/tenant/StaffRoles'

import TenantReportDeviceLoseRate from '@/pages/tenant/report/DeviceLoseRate'
import TenantReportSensorFault from '@/pages/tenant/report/SensorFault'

import PtzDetail from '@/pages/monitor/ptz/PtzDetail'
import AddRule from '@/pages/monitor/rule/AddRule'

Vue.use(Router)

export default new Router({
  mode: 'history',
  scrollBehavior: () => ({
    y: 0
  }),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard,
      meta: {
        title: '概况'
      }
    },
    group(
      '/monitor',
      '监控中心',
      [
        r(MonitorGis, 'GIS地图'),
        r(TenantDeviceAlarmRules, '规则设置'),
        r(PtzDetail, '云台详情页')
      ]
    ),
    group(
      '/tenant',
      '运维服务',
      [
        r(TenantDeviceAlarm, '当前设备告警'),
        r(TenantDeviceFault, '当前设备故障'),
        r(TenantReportDeviceLoseRate, '故障报表'),
        r(TenantReportSensorFault, '传感器故障')
      ]
    ),
    group(
      '/base',
      '设备分类',
      [
        r(BaseSensorType, '传感器种类'),
        r(BaseDevicParameter, '参数配置'),
        r(BaseDeviceType, '设备类型')
      ]
    ),
    r(TenantDevice, '设备管理'),
    r(AddRule, '添加规则'),
    group(
      '/user',
      '用户中心',
      [
        r(TenantRole, '角色权限'),
        r(TenantStaffRoles, '权限管理')
      ]
    )
  ]
})
