<template>
  <vc-schema-table-with-confirm collection="base.sensor.type" :filter="filter" :schema="schema" :ui-schema="uiSchema" :headers="headers" :beforeInsert="beforeInsert" :beforeUpdate="setOperator" :sort="{ updatedOn: -1 }">
    <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
  </vc-schema-table-with-confirm>
</template>
<script>
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import searchUtil from '@vehiclecloud/commons/util/search'

import schema from '@/schema/base/sensor/type'

import RecordOperator from '../../mixins/record-operator'

export default {
  name: 'base-sensor-type',
  mixins: [RecordOperator],
  data () {
    let textOf = JsonSchemaVuetify.config.crud.list.helper.textOf
    return {
      schema,
      uiSchema: {
        remark: { 'ui:format': 'textarea' },
        staff: { 'ui:readOnly': true },
        updatedOn: { 'ui:readOnly': true },
        data: {
          values: {
            'ui:props': { parseConf: { filter: (s, ui, k) => k === 'title' }, formUiSchema: null },
            title: { 'ui:filter': (ctx, el, item, value) => `${textOf(item.value)} : ${textOf(value)}` }
          }
        },
        channels: { 'ui:show': false }
      },
      headers: [
        { value: 'name', align: 'left' },
        { value: 'code', align: 'left' },
        { value: 'status', align: 'left' },
        { value: 'staff', align: 'left', ui: { 'ui:show': () => true } },
        { value: 'updatedOn', align: 'left', ui: { 'ui:show': () => true } }
      ],
      search: {
        schema: {
          type: 'object',
          properties: {
            status: {
              $ref: 'common/definitions/status'
            },
            keyword: {
              type: 'string',
              title: '名称或者种类ID'
            }
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          status: searchUtil.enumSelectUiSchema('xs6'),
          keyword: searchUtil.flexClass('xs6')
        }
      },
      params: {
        status: null,
        keyword: null
      }
    }
  },
  methods: {
    filter () {
      if (!this.params.keyword && this.params.status === null) return null
      let result = {}
      if (this.params.keyword) {
        let regex = { '$regex': this.params.keyword.trim() }
        result.$or = [{ name: regex }, { code: regex }]
      }
      if (this.params.status !== null) {
        result.status = this.params.status
      }
      return result
    },
    beforeInsert (item) {
      this.setOperator(item)
      if (item.type === 2) {
        item.channels = [
          {
            code: 1,
            name: '',
            'commands': [
              {
                'type': 1,
                'code': 1,
                'name': ''
              }
            ]
          },
          {
            code: 2,
            name: '',
            'commands': [
              {
                'type': 1,
                'code': 1,
                'name': ''
              }
            ]
          },
          {
            code: 3,
            name: '',
            'commands': [
              {
                'type': 1,
                'code': 1,
                'name': ''
              }
            ]
          },
          {
            code: 4,
            name: '',
            'commands': [
              {
                'type': 1,
                'code': 1,
                'name': ''
              }
            ]
          }
        ]
      }
    }
  }
}
</script>
