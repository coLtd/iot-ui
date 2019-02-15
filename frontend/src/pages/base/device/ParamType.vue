<template>
  <vc-schema-table-with-confirm collection="base.device.param_type" :filter="filter" :schema="schema" :ui-schema="uiSchema" :headers="headers" :beforeInsert="setOperator" :beforeUpdate="setOperator" :sort="{ updatedOn: -1 }">
    <v-text-field label="名称或编码" single-line v-model="params.keyword" class="mr-3"></v-text-field>
  </vc-schema-table-with-confirm>
</template>
<script>
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'

import schema from '@/schema/base/device/param_type'

import RecordOperator from '../../mixins/record-operator'

export default {
  name: 'base-device-param_type',
  mixins: [RecordOperator],
  data: function () {
    return {
      schema,
      uiSchema: {
        name: { 'ui:validate': { unique: JsonSchemaVuetify.Validate.unique.params } },
        code: { 'ui:validate': { unique: JsonSchemaVuetify.Validate.unique.params } },
        paramId: { 'ui:validate': { required: (ctx, el, item) => !!item.isPushParam }, 'ui:attrs': { min: '1' } },
        minLength: { 'ui:attrs': { min: 0 } },
        maxLength: { 'ui:attrs': { min: 0 } },
        staff: { 'ui:readOnly': true },
        updatedOn: { 'ui:readOnly': true }
      },
      headers: [
        { value: 'name', align: 'left' },
        { value: 'code', align: 'left' },
        { value: 'staff', align: 'left', ui: { 'ui:show': () => true } },
        { value: 'updatedOn', align: 'left', ui: { 'ui:show': () => true } }
      ],
      params: {
        keyword: null
      }
    }
  },
  methods: {
    filter () {
      if (!this.params.keyword) return null
      let result = {}
      let regex = { '$regex': this.params.keyword.trim() }
      result.$or = [{ name: regex }, { code: regex }]
      return result
    }
  }
}
</script>
