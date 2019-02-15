<template>
  <vc-schema-table-with-confirm collection="base.device.type" :filter="filter" :schema="schema" :ui-schema="uiSchema" :headers="headers" :beforeInsert="setOperator" :beforeUpdate="setOperator" :sort="{ updatedOn: -1 }">
    <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
  </vc-schema-table-with-confirm>
</template>
<script>
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import searchUtil from '@vehiclecloud/commons/util/search'

import schema from '@/schema/base/device/type'

import RecordOperator from '../../mixins/record-operator'

export default {
  name: 'base-device-type',
  mixins: [RecordOperator],
  data: function () {
    return {
      schema,
      uiSchema: {
        'ui:class': { row: true, wrap: true },
        name: { 'ui:validate': { unique: JsonSchemaVuetify.Validate.unique.params }, 'ui:class': { flex: true, xs12: true } },
        code: { 'ui:validate': { unique: JsonSchemaVuetify.Validate.unique.params }, 'ui:class': { flex: true, xs12: true } },
        remark: { 'ui:format': 'textarea' },
        sensorTypes: { 'ui:props': { autocomplete: true }, 'ui:options': { filter: t => t.status === 1 } },
        paramTypes: { 'ui:props': { autocomplete: true } },
        photos: { 'ui:props': { fileName: 'device-type', limit: 6, tip: '请上传200x200(宽x高), 大小在20K ~ 2M之间的图片', fileMinSize: 20 * 1024, fileMaxSize: 2 * 1024 * 1024, accept: 'image/png, image/jpeg,  image/jpg,  image/bmp' } },
        staff: { 'ui:readOnly': true },
        updatedOn: { 'ui:readOnly': true }
      },
      headers: [
        { value: 'code', align: 'left', sortable: false },
        { value: 'name', align: 'left' },
        { value: 'tag', align: 'left' },
        { value: 'status', align: 'left' },
        { value: 'staff', align: 'left', ui: { 'ui:show': () => true } },
        { value: 'updatedOn', align: 'left', ui: { 'ui:show': () => true } }
      ],
      search: {
        schema: {
          type: 'object',
          properties: {
            tag: schema.properties.tag,
            status: {
              $ref: 'common/definitions/status'
            },
            keyword: {
              type: 'string',
              title: '名称或者类型ID'
            }
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          tag: searchUtil.enumSelectUiSchema('xs3'),
          status: searchUtil.enumSelectUiSchema('xs3'),
          keyword: searchUtil.flexClass('xs6')
        }
      },
      params: {
        keyword: null,
        status: null,
        tag: null
      }
    }
  },
  methods: {
    filter () {
      if (!this.params.keyword && this.params.status === null && !this.params.tag) return null
      let result = {}
      if (this.params.keyword) {
        let regex = { '$regex': this.params.keyword.trim() }
        result.$or = [{ name: regex }, { code: parseInt(this.params.keyword.trim()) }]
      }
      if (this.params.status !== null) {
        result.status = this.params.status
      }
      if (this.params.tag) {
        result.tag = this.params.tag
      }
      return result
    }

  }
}
</script>
