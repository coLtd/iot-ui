import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'

import AgDeviceAlarmRulesDialog from './AgDeviceAlarmRulesDialog'

export default {
  name: 'ag-device-alarm-rules-dialog-with-confirm',
  mixins: [AgDeviceAlarmRulesDialog, JsonSchemaVuetify.mixins.RemoveConfirm],
  data () {
    return {
      origin: AgDeviceAlarmRulesDialog
    }
  }
}
