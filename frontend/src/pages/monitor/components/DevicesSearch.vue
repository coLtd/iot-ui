<template>
  <div class="devices-search-panel">
    <v-card>
      <v-card-title class="py-0">
        <form class="layout row" @submit.prevent="search">
          <v-text-field label="设备名称或ID" single-line hide-details v-model="params.keyword"></v-text-field>
          <v-btn type="submit" small color="info" class="ml-3 btn--search">搜索</v-btn>
        </form>
      </v-card-title>
      <v-card-actions class="card__actions-tags">
        <v-btn-toggle v-model="params.tag" :class="{'btn-toggle--right': tags.right}">
          <template v-for="(tag, i) in tags.items">
            <v-btn flat :value="tag.value" :key="tag.value" @click="params.tag = tag.value">{{ tag.text }}</v-btn>
            <div class="divider-v" :key="'d_' + tag.value" v-if="(i + 1) % 3 && i !== tags.items.length - 1"></div>
            <template v-if="!((i + 1) % 3)">
              <a class="a-slider" :key="'ar-' + i" v-show="!tags.right" @click="tags.right = true">
                <v-icon>keyboard_arrow_right</v-icon>
              </a>
              <a class="a-slider a-slider-left" :key="'al-' + i" v-show="tags.right" @click="tags.right = false">
                <v-icon>keyboard_arrow_left</v-icon>
              </a>
            </template>
          </template>
        </v-btn-toggle>
      </v-card-actions>
    </v-card>
    <v-card class="mt-3 pt-2">
      <v-list two-line class="pb-0">
        <v-list-tile>
          <vc-schema-render :tag="null" :scope="1" :elements="list.farmland" :item="farmland"></vc-schema-render>
        </v-list-tile>
        <v-divider></v-divider>
      </v-list>
      <div class="scrollbar-thin container-devices">
        <v-list two-line>
          <template v-for="device in value">
            <v-list-tile :key="device._id.$oid" :value="device === currentDevice" @click="select(device)">
              <vc-schema-render :tag="null" :scope="1" :elements="list.device" :item="device"></vc-schema-render>
            </v-list-tile>
            <v-divider :key="'d_' + device._id.$oid"></v-divider>
          </template>
          <v-list-tile v-if="!value || !value.length">
            <v-list-tile-content>
              <v-list-tile-title>未找到匹配的设备数据.</v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
        </v-list>
        <div class="text-xs-center pt-3 pb-4">
          <v-pagination :length="page.length" total-visible="6" v-model="page.current" circle prev-icon="arrow_back" next-icon="arrow_forward" color="light-blue lighten-1"></v-pagination>
        </div>
      </div>
    </v-card>
  </div>

</template>

<script>
import JsonSchema, { data as JsonSchemaData } from '@vehiclecloud/json-schema'
import JsonSchemaVuetify from '@vehiclecloud/json-schema-vuetify'

import mongo from '@vehiclecloud/mongo-rest-client'

import addressUtil from '@vehiclecloud/commons/util/address'

import commonSchema from '@/schema/common'
import deviceTypeSchema from '@/schema/base/device/type'
import deviceSchema from '@/schema/tenant/device'

const farmlandSchema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    address: {
      type: 'object',
      format: 'address',
      properties: {
        province: { $id: '#base.area' },
        city: { $id: '#base.area' },
        district: { $id: '#base.area' },
        town: { $id: '#base.area' },
        village: { $id: '#base.area' },
        street: { type: 'string' }
      }
    }
  }
}

const farmlandUiSchema = {
  address: { ...addressUtil.uiSchema(), 'ui:tag': 'v-list-tile-sub-title', 'ui:class': null }
}

const accessStatusMap = JsonSchemaData.enumsOf(commonSchema.definitions.accessStatus.items).reduce((m, e) => {
  m[e.value] = e.text
  return m
}, {})

const deviceUiSchema = {
  name: {
    'ui:tag': 'v-list-tile-title',
    'ui:filter': (ctx, el, item) => `${item.name} (${item.code})`
  },
  accessState: {
    'ui:show': (ctx, el, item, value) => value && value.status && !value.status.includes(1),
    'ui:layout': (ctx, el, item, value) => ctx.h('v-chip', { attrs: { color: 'red lighten-4', textColor: 'red darken-4', label: true, small: true } }, (value && value.status && value.status.length) ? value.status.map(s => accessStatusMap[s]).join(',') : '未知')
  },
  type: { 'ui:tag': 'v-list-tile-sub-title' }
}

export default {
  name: 'ag-monitor-gis-devices-search',
  mounted () {
    this.search()
  },
  props: {
    farmland: {
      type: Object,
      required: true
    },
    value: Array,
    accessState: Object,
    currentDevice: Object
  },
  data () {
    return {
      params: {
        keyword: null,
        tag: null
      },
      page: {
        current: 1,
        length: 0,
        limit: 100
      },
      tags: {
        items: JsonSchemaData.enumsOf(deviceTypeSchema.properties.tag),
        right: false
      },
      list: {
        farmland: JsonSchema.parse(farmlandSchema, farmlandUiSchema, JsonSchemaVuetify.config.crud.list.components, { filter: (schema, uiSchema, key) => key === 'name' || key === 'address' }),
        device: JsonSchema.parse(deviceSchema, deviceUiSchema, JsonSchemaVuetify.config.crud.list.components, { filter: (schema, uiSchema, key, parent) => key === 'name' || key === 'type' || key === 'accessState' || (parent && parent.key === 'accessState' && key === 'status') })
      }
    }
  },
  watch: {
    accessState () {
      this.search()
    },
    'params.tag' () {
      this.search()
    },
    'page.current' () {
      this.query()
    }
  },
  methods: {
    search () {
      if (this.page.current !== 1) {
        this.page.current = 1
      } else {
        this.query()
      }
    },
    query () {
      let filter = { status: 1, farmland: this.farmland._id }
      let kw = this.params.keyword && this.params.keyword.trim()
      if (kw) filter.$or = [{ name: { $regex: kw } }, { code: { $regex: kw } }]
      if (this.accessState && this.accessState.status) filter['accessState.status'] = this.accessState.status
      if (this.accessState && this.accessState.code) filter['accessState.code'] = this.accessState.code
      if (this.params.tag) {
        filter['type'] = { $in: this.$store.state['base.device.type'].items.filter(t => t.tag === this.params.tag).map(t => t._id) }
      }
      mongo.db().collection('tenant.device').find({
        filter,
        skip: (this.page.current - 1) * this.page.limit,
        limit: this.page.limit
      }).then(({ items, total }) => {
        this.page.length = Math.ceil(Number(total.$numberLong) / this.page.limit)
        this.$emit('input', items)
      })
    },
    select (device) {
      this.$emit('update:currentDevice', device)
    }
  }
}
</script>

<style lang="scss">
.devices-search-panel {
  position: absolute;
  top: 0;
  margin-top: 97px;
  margin-left: 23px;
  width: 360px;
  .btn--search {
    margin-top: 22px;
    min-width: 70px;
  }
  .card__actions-tags {
    overflow: hidden;
    margin-right: 40px;
    padding-top: 4px;
    .btn-toggle {
      box-shadow: none;
      &.btn-toggle--right {
        margin-left: -275px;
      }
      .btn {
        font-size: 1rem;
        height: 32px;
      }
      .divider-v {
        width: 1px;
        background-color: #6b6b6b;
        margin: 11px 1rem;
      }
      .a-slider {
        line-height: 32px;
        color: black;
        margin: 0 1rem;
      }
    }
  }
  .list--two-line .list__tile {
    height: 60px;
  }
  .container-devices {
    max-height: calc(100vh - 500px);
    .chip {
      position: absolute;
      right: 10px;
      height: 25px;
    }
    .pagination {
      .pagination__item,
      .pagination__navigation {
        box-shadow: none;
        color: #a39895;
        background-color: #f0f0f0;
        margin: 0.1rem;
        width: 30px;
        height: 30px;
      }
      .pagination__item.pagination__item--active {
        color: white;
      }
      .pagination__navigation {
        .icon {
          color: #a39895;
          font-size: 20px;
        }
      }
    }
  }
}
</style>
