import axios from 'axios'

let conf = {
  server: 'http://localhost:9500',
  tenantId: '5a71f99bf7f331c05f5c4272'
}
function ruleWithSensorType (rule, deviceType, sensorTypes) {
  return {
    ...rule.period,
    startTime: rule.startTime,
    stopTime: rule.stopTime,
    rules: deviceType.sensorTypes.reduce((r, stId) => {
      let st = sensorTypes.find(t => t._id.$oid === stId.$oid)
      if (!st || !st.status) return r
      let result = { _id: st._id, id: st.code, ...st.data }

      if (st.data.type === 1) {
        let ruleConf = rule.rules[st._id.$oid]
        if (ruleConf) {
          result.minThreshold = +ruleConf.min
          result.maxThreshold = +ruleConf.max
        }
      }
      r[st.code] = result
      return r
    }, {})
  }
}

export default {
  producer: {
    sendAlarmRules (device, rules, deviceTypes, deviceParamTypes, sensorTypes, accessSensorType = 'SENSOR_SHENGU') {
      axios.post(`${conf.server}/api/kafka/producer`, !device.status ? null : {
        topic: `analysis-1-${conf.tenantId}`,
        key: `${conf.tenantId}:${accessSensorType}:${device.code}`,
        value: rules && {
          device: device._id,
          params: device.params && Object.keys(device.params).reduce((r, pid) => {
            let pt = deviceParamTypes.find(p => p._id.$oid === pid)
            if (pt.paramId) r[pt.paramId] = device.params[pid]
            return r
          }, {}),
          rules: !(rules && rules.length)
            ? null
            : rules.map(r => ruleWithSensorType(r, deviceTypes.find(t => t._id.$oid === device.type.$oid), sensorTypes))
        }
      })
    }
  },
  config (c) {
    conf = { ...conf, ...c }
  }
}
