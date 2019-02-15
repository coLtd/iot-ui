<template>
  <v-card class="card--table">
    <form @submit.prevent="find" class="table-search">
      <v-card-title class="pa-0">
        <v-layout row align-baseline>
          <vc-schema-form tag="div" :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"></vc-schema-form>
          <v-btn type="submit" small color="info" class="ml-3 btn--search">查询</v-btn>
        </v-layout>
      </v-card-title>
    </form>
    <v-layout justify-end>
      <ul class="rate-legend">
        <li class="level4" title="当天从未发送过数据">未发送</li>
        <li class="level3" title="当天丢失率大于10%">大于10%</li>
        <li class="level2" title="当天丢失率大于3%-10%">3%-10%</li>
        <li class="level1" title="当天丢失率小于3%">小于3%</li>
      </ul>
    </v-layout>
    <v-data-table :items="table.devices" :total-items="table.total" :pagination.sync="table.pagination" :loading="table.loading" :rows-per-page-items="table.rowsPerPageItems" rows-per-page-text="每页" no-data-text="未找到相应数据." no-results-text="没有匹配的数据." class="table--lose-rate">
      <template slot="headers" slot-scope="props">
        <tr class="table--lose-rate-head-tr">
          <td rowspan="2" class="name">设备名称(编号)</td>
          <td v-for="month in table.headers.months" :key="month.v" :colspan="month.colspan" class="bl">{{ month.title }}月</td>
        </tr>
        <tr class="table--lose-rate-head-tr table--lose-rate-head-tr-days">
          <td v-for="(day, idx) in table.headers.days" :key="day.time" :class="{ bl: idx === 0 || day.v === 0 }">{{ day.title }}</td>
        </tr>
      </template>
      <template slot="items" slot-scope="{ item }">
        <tr>
          <th>
            <div class="div--name">{{ item.name }}({{ item.code }})</div>
          </th>
          <td v-for="day in table.headers.days" :key="item._id.$oid + day.time" :class="levelOf(item, day.time)"></td>
        </tr>
      </template>
      <template slot="pageText" slot-scope="{ pageStart, pageStop, itemsLength }">
        共 {{ itemsLength }} 条, 当前 {{ pageStart }} - {{ pageStop }} 条
      </template>
    </v-data-table>
  </v-card>
</template>
<script>
import mongo from '@vehiclecloud/mongo-rest-client'

import { util as JsonSchemaUtil } from '@vehiclecloud/json-schema'

import searchUtil from '@vehiclecloud/commons/util/search'
import Period from '@agrithings/common/util/period'
import { Schema, Dependencies, UiSchema, Params, Filter } from '../util'

export default {
  name: 'tenant-report-device_lose_rate',
  data () {
    let self = this
    return {
      initedPromise: null,
      search: {
        schema: {
          type: 'object',
          properties: {
            ...Schema.DateRange,
            ...Schema.Address,
            ...Schema.TenantFarmland,
            ...Schema.Device,
            keyword: { type: 'string', title: '设备名称或ID' }
          },
          dependencies: {
            ...Dependencies.Address,
            ...Dependencies.TenantFarmland,
            ...Dependencies.Device
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          ...UiSchema.DateRange(),
          ...searchUtil.addressUiSchema(),
          ...UiSchema.TenantFarmland(self),
          ...UiSchema.Device(self),
          keyword: searchUtil.flexClass()
        }
      },
      params: {
        skip: 0,
        limit: 5,
        ...Params.DateRangeFactory(),
        ...Params.Address,
        ...Params.TenantFarmland,
        ...Params.Device,
        keyword: null
      },
      table: {
        total: 0,
        headers: {
          months: [], // [{title: string, colspan: number}]
          days: [] // [{title: string, time: number}]
        },
        devices: [],
        rowsPerPageItems: [
          { text: '5条', value: 5 },
          { text: '10条', value: 10 },
          { text: '20条', value: 20 },
          { text: '50条', value: 50 }
        ],
        loading: false,
        pagination: { page: 1, rowsPerPage: 20 },
        rateMap: {}
      }
    }
  },
  watch: {
    'table.pagination': {
      handler (p) {
        this.params.skip = (p.page - 1) * p.rowsPerPage
        this.params.limit = p.rowsPerPage
        this.query()
      },
      deep: true
    }
  },
  created () {
    this.initMonthsHeader()
    this.initedPromise = Promise.all([
      this.$store.dispatch('init', { collection: 'sys.tenant' }),
      this.$store.dispatch('init', { collection: 'tenant.farmland' }),
      this.$store.dispatch('init', { collection: 'base.device.type' })
    ])
  },
  methods: {
    initMonthsHeader () {
      if (!this.params.startDate || !this.params.stopDate) return
      let months = []
      let days = []
      let month = {}
      for (let d = +this.params.startDate.$numberLong; d <= +this.params.stopDate.$numberLong; d += Period.day) {
        let date = new Date(d)
        days.push({ title: JsonSchemaUtil.pad(date.getDate()), time: d })
        let dm = date.getMonth()
        if (dm !== month.v) {
          month = { title: dm + 1, colspan: 1, v: dm }
          months.push(month)
        } else {
          month.colspan += 1
        }
      }
      this.table.headers.months = months
      this.table.headers.days = days
    },
    find () {
      if (this.table.pagination.page !== 1) {
        this.table.pagination.page = 1
        return
      }
      this.query()
    },
    async query () {
      this.table.loading = true
      this.initMonthsHeader()
      await this.initedPromise
      let filter = { farmland: Filter.farmland(this), type: Filter.deviceType(this) }
      if (this.params.keyword) filter['$or'] = [{ name: { $regex: this.params.keyword.trim() } }, { code: { $regex: this.params.keyword.trim() } }]

      let { items: devices, total } = await mongo.db().collection('tenant.device').find({
        filter,
        projection: { name: 1, code: 1 },
        skip: this.params.skip,
        limit: this.params.limit
      })
      let { items: rateItems } = await mongo.db().collection('tenant.report.device_lose_rate').find({
        filter: { period: 2, time: { $gte: +this.params.startDate.$numberLong, $lt: +this.params.stopDate.$numberLong + Period.day }, device: { $in: devices.map(d => d._id) } }
      })
      this.table.rateMap = rateItems.reduce((m, rate) => {
        let dm = m[rate.device.$oid]
        if (!dm) {
          dm = m[rate.device.$oid] = {}
        }
        dm[rate.time.$numberLong] = 100 - Math.round(rate.real / rate.expect * 100)
        return m
      }, {})
      this.table.total = +total.$numberLong
      this.table.devices = devices
      this.table.loading = false
    },
    levelOf (device, time) {
      let dm = this.table.rateMap[device._id.$oid]
      if (!dm) return 'level4'
      let rate = dm[time]
      if (rate === undefined) return 'level4'

      let r = 4
      if (rate <= 3) r = 1
      else if (rate > 3 && rate <= 10) r = 2
      else if (rate > 10) r = 3
      return `level${r}`
    }
  }
}
</script>

<style lang="scss">
.table--lose-rate {
  .table__overflow {
    table.table {
      td {
        text-align: center;
        padding: 0 !important;
        &.bl {
          border-left: 1px solid #d6d6d6;
        }
      }
      thead {
        tr {
          border-color: #d6d6d6;
          &.table--lose-rate-head-tr {
            height: 2.5rem !important;
            .name {
              vertical-align: bottom;
              width: 220px;
              padding-bottom: 0.6rem !important;
            }
            &.table--lose-rate-head-tr-days {
              td {
                border-bottom: 1px solid #d6d6d6;
              }
            }
          }
        }
      }
      tbody {
        th,
        td {
          height: auto !important;
          width: calc((100% - 220px) / 30);
          padding-bottom: calc((100% - 220px) / 30) !important;
        }
        th {
          box-shadow: 0 0 0 2px rgba(0, 0, 0, 0);
          position: relative;
          .div--name {
            position: absolute;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-right: 2rem;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            font-weight: normal;
          }
        }
        td {
          box-shadow: 0 0 0 2px #fff;
        }
      }
    }
  }
}

.level1 {
  background-color: #66b85a;
}
.level2 {
  background-color: #fea233;
}
.level3 {
  background-color: #ff6367;
}
.level4 {
  background-color: #d5c9c6;
}
.rate-legend {
  list-style: none;
  display: flex;
  li {
    margin-left: 1.5rem;
    flex: 1;
    background: inherit;
    white-space: nowrap;
    &::before {
      content: " ";
      width: 10px;
      height: 10px;
      display: inline-block;
      margin-right: 0.5rem;
    }
    &.level1 {
      &::before {
        background: #66b85a;
      }
    }
    &.level2 {
      &::before {
        background: #fea233;
      }
    }
    &.level3 {
      &::before {
        background: #ff6367;
      }
    }
    &.level4 {
      &::before {
        background: #d5c9c6;
      }
    }
  }
}
</style>
