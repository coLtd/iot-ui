<template>
  <v-dialog :value="show" @input="close" persistent scrollable lazy max-width="800px" content-class="dialog--rules">
    <v-card v-if="show">
      <v-toolbar card color="grey lighten-4 pl-2">
        <v-toolbar-title class="ml-5">告警规则</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn v-show="!dialog.form.show" icon small @click.native="close">
          <v-icon>close</v-icon>
        </v-btn>
        <v-btn v-if="$authed('POST', '/tenant/device_alarm_rules/alarmRule') && showEditBtn" dark fab small absolute left bottom class="red darken-2" @click="addRule">
          <v-icon>add</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="grey lighten-3" ref="cardText">
        <v-container>
          <v-expansion-panel v-if="items.length" v-model="active" popout>
            <v-expansion-panel-content v-for="(rule, ri) in items" :key="ri" v-model="active[ri]" hide-actions>
              <template v-if="!(dialog.form.show && idx === ri)">
                <v-layout slot="header" class="layout--header" @click="panelClick($event)">
                  <v-flex>
                    <div class="body-1 mb-1">{{ rule.name }}</div>
                    <div class="grey--text text--darken-2">{{ periodOf(rule) }} 每天 {{ SchemaData.intToTimeStr(rule.startTime) }} -- {{ SchemaData.intToTimeStr(rule.stopTime) }} </div>
                  </v-flex>
                  <v-flex v-if="showEditBtn" shrink hidden>
                    <v-btn v-if="$authed('PUT', '/tenant/device_alarm_rules/alarmRule')" icon small @click.native.stop="editRule(rule, ri)" title="修改">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="$authed('PUT', '/tenant/device_alarm_rules/alarmRule')" icon small @click.native.stop="removeItem(rule, ri)" title="删除">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </v-flex>
                </v-layout>
                <vc-data-table :headers="table.headers" :items="sensorTypes" hide-actions class="card--table pa-0">
                  <template slot="items" slot-scope="{ item: st }">
                    <td class="text-xs-center">{{ st.name }}{{ st.data.unit ? ` (${st.data.unit})` : '' }}</td>
                    <td class="text-xs-center">
                      {{ (rule.rules[st._id.$oid] && rule.rules[st._id.$oid].min + '') || '-' }}
                    </td>
                    <td class="text-xs-center">
                      {{ (rule.rules[st._id.$oid] && rule.rules[st._id.$oid].max + '') || '-' }}
                    </td>
                  </template>
                </vc-data-table>
              </template>
              <template v-else>
                <div class="layout--header">
                  <v-layout>
                    <v-spacer></v-spacer>
                    <v-btn flat small @click.native="cancel">
                      取消
                    </v-btn>
                    <v-btn type="submit" flat small color="primary" form="rule-form">
                      <v-icon>done</v-icon>保存
                    </v-btn>
                  </v-layout>
                  <v-divider class="mb-4"></v-divider>
                  <vc-schema-form id="rule-form" :schema="schema" :ui-schema="uiSchema" :validator-init-fn="form.validatorInitFn" :value="item" @submit="submit"></vc-schema-form>
                </div>
                <v-data-table :headers="table.headers" :items="sensorTypes" hide-actions class="card--table card--table-edit pa-0">
                  <template slot="items" slot-scope="{ item: st }">
                    <td class="text-xs-center">{{ st.name }}{{ st.data.unit ? ` (${st.data.unit})` : '' }}</td>
                    <td class="text-xs-center">
                      <v-text-field :name="'min-' + st._id.$oid" type="number" v-model.number="item.rules[st._id.$oid].min" v-validate="'required|min_value:' + (st.data.minValid !== undefined ? st.data.minValid: st.data.minRange) + '|max_value:' + item.rules[st._id.$oid].max" :error-messages="errors.collect('min-' + st._id.$oid)" data-vv-as="下限值" data-vv-delay="1" required></v-text-field>
                    </td>
                    <td class="text-xs-center">
                      <v-text-field :name="'max-' + st._id.$oid" type="number" v-model.number="item.rules[st._id.$oid].max" v-validate="'required|min_value:' + item.rules[st._id.$oid].min + '|max_value:' + st.data.maxValid ? st.data.maxValid : st.data.maxRange" :error-messages="errors.collect('max-' + st._id.$oid)" data-vv-as="上限值" data-vv-delay="1" required></v-text-field>
                    </td>
                  </template>
                </v-data-table>
              </template>
            </v-expansion-panel-content>
          </v-expansion-panel>
          <v-alert v-else-if="loaded" type="error" :value="true">
            当前暂无告警规则
            <span v-if="!readMode && $authed('POST', '/tenant/device_alarm_rules/alarmRule')">，是否
              <a @click="readMode = false; addRule()" class="white--text" style="text-decoration: underline;">添加规则</a>?
            </span>
            <span v-else>!</span>
          </v-alert>
        </v-container>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'
import { data as SchemaData } from '@vehiclecloud/json-schema'

import schema from '@/schema/tenant/device_alarm_rules'

import kafka from '@/api/kafka'

export default {
  name: 'ag-device-alarm-rules-dialog',
  mixins: [JsonSchemaVuetify.mixins.SchemaCrud],
  $_veeValidate: { validator: 'new' },
  props: {
    show: {
      type: Boolean,
      required: true
    },
    value: Number,
    device: {
      type: Object,
      required: true
    },
    readonly: Boolean,
    collection: {
      type: String,
      default: 'tenant.device_alarm_rules'
    },
    schema: {
      type: Object,
      default: () => schema
    },
    uiSchema: {
      type: Object,
      default: () => ({
        'ui:order': ['name', 'startTime', 'stopTime', 'period', '*'],
        'ui:class': { layout: true, row: true, wrap: true },
        device: { 'ui:show': () => false },
        status: { 'ui:show': () => false },
        rules: { 'ui:show': () => false },
        name: { 'ui:class': { flex: true, xs4: true }, 'ui:attrs': { maxlength: 20 } },
        startTime: { 'ui:class': { flex: true, xs3: true, 'pr-3': true, 'offset-xs1': true } },
        stopTime: {
          'ui:class': { flex: true, xs3: true },
          'ui:props': (ctx, el, item) => ({ min: item ? SchemaData.intToTimeStr(item.startTime + 1000 * 60) : undefined }),
          'ui:validate': { 'min_value': (ctx, el, item) => item && item.startTime }
        },
        period: {
          'ui:title': '',
          'ui:class': { flex: true, xs12: true, layout: true, row: true },
          type: { 'ui:class': { flex: true, xs4: true } },
          days: { 'ui:class': { flex: true, xs6: true, 'offset-xs1': true }, 'ui:props': { chips: false } },
          startDate: { 'ui:class': { flex: true, xs3: true, 'pr-3': true, 'offset-xs1': true } },
          stopDate: { 'ui:class': { flex: true, xs3: true } }
        }
      })
    },
    filter: {
      type: Function,
      default: function () {
        return { device: this.device._id }
      }
    }
  },
  data () {
    let deviceType = this.$store.state['base.device.type'].items.find(t => t._id.$oid === this.device.type.$oid)

    return {
      SchemaData,
      params: {
        skip: null,
        limit: null,
        sort: { 'startTime': 1 }
      },
      readMode: this.readonly,
      active: [],
      loaded: false,
      sensorTypes: this.$store.state['base.sensor.type'].items.filter(t => t.data && t.data.type === 1 && deviceType.sensorTypes && deviceType.sensorTypes.some(ds => ds.$oid === t._id.$oid)),
      table: {
        headers: [
          { text: '传感器', sortable: false, align: 'center' },
          { text: '告警下限值', sortable: false, align: 'center' },
          { text: '告警上限值', sortable: false, align: 'center' }
        ]
      },
      form: {
        validatorInitFn: $validator => {
          $validator.localize('zh_CN', {
            custom: {
              stopTime: {
                'min_value': () => {
                  console.log('stopTime custom msg')
                  return '结束时间必须大于开始时间'
                }
              }
            }
          })
        }
      },
      dialog: {
        form: {
          originActive: null
        }
      }
    }
  },
  computed: {
    showEditBtn () {
      return !(this.readMode || this.dialog.form.show)
    }
  },
  created () {
    this.query()
  },
  methods: {
    close () {
      this.$emit('update:show', false)
    },
    async query () {
      let r = await this.find()
      if (!r) return
      let { items } = r
      this.active = items.map((item, i) => i === 0)
      this.items = items
      this.loaded = true
    },
    panelClick ($event) {
      if (this.dialog.form.show) $event.stopPropagation()
    },
    addRule () {
      this.add({
        device: this.device._id,
        period: { type: 1 },
        status: 1,
        rules: this.sensorTypes.reduce((o, t) => {
          o[t._id.$oid] = { min: t.data.minValid, max: t.data.maxValid }
          return o
        }, {})
      })
      this.items.push(this.item)
      this.idx = this.idx = this.items.length - 1
      this.dialog.form.originActive = this.active
      this.active = Array(this.active.length).fill(false)
      this.active.push(true)
      this.$nextTick(() => {
        this.$refs.cardText.scrollTo(0, this.$refs.cardText.scrollHeight)
      })
    },
    editRule (rule, idx) {
      this.edit(rule)
      this.idx = idx
      this.active = Array(this.active.length).fill(false)
      this.active[idx] = true
    },
    _afterInsert (item) {
      this.afterSubmit(item)
    },
    _afterUpdate (item) {
      this.afterSubmit(item)
    },
    afterSubmit (item) {
      this.dialog.form.show = false
      this.items[this.idx] = item
      this.$emit('input', this.items.length)
      this.saveToKafka()
    },
    _afterRemove (item, idx) {
      this.items.splice(idx, 1)
      this.$emit('input', this.items.length)
      this.saveToKafka()
    },
    saveToKafka () {
      kafka.producer.sendAlarmRules(this.device, this.items, this.$store.state['base.device.type'].items, this.$store.state['base.device.param_type'].items, this.$store.state['base.sensor.type'].items)
    },
    cancel () {
      if (!this.item._id) {
        this.items.pop()
        if (this.dialog.form.originActive) {
          this.active = this.dialog.form.originActive
          this.dialog.form.originActive = null
        }
      }
      this.dialog.form.show = false
      this.idx = null
    },
    periodOf (rule) {
      return rule.period.type === 1
        ? schema.properties.period.dependencies.type.oneOf[0].properties.days.items.enumNames.filter((d, idx) => rule.period.days && rule.period.days.includes(idx + 1)).join(', ')
        : `${SchemaData.longToDateStr(rule.period.startDate.$numberLong)} -- ${SchemaData.longToDateStr(rule.period.stopDate.$numberLong)}`
    }
  }
}
</script>

<style lang="scss">
.dialog--rules {
  height: 85%;
  .card__text {
    height: 100%;
    .expansion-panel__container {
      .expansion-panel__header {
        padding: 0;
        .hidden {
          display: none;
        }
      }
      .layout--header {
        padding: 12px 24px;
      }
      &:hover,
      &.expansion-panel__container--active {
        .expansion-panel__header {
          .hidden {
            display: inherit;
          }
        }
      }
      .card--table {
        .table__overflow {
          border-left-width: 0 !important;
          border-right-width: 0 !important;
        }
        &.card--table-edit {
          tr:hover {
            background: inherit;
          }
        }
      }
    }
  }
}
</style>
