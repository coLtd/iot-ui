<template style="background-color:#fff">
  <div class="card--table pt-3 px-0"
       style="min-height:500px;">
    <v-data-table v-if="tableFlag"
                  :custom-sort="sortDesc"
                  height="800px"
                  :headers="table.headers"
                  :items="table.items"
                  rows-per-page-text="每页"
                  :rows-per-page-items="table.pagination"
                  class="elevation-1"
                  no-data-text="未找到相应数据."
                  no-results-text="没有匹配的数据.">
      <template slot="items"
                slot-scope="props">
        <td>{{ props.item.date }}</td>
        <td>{{ props.item.time }}</td>
        <td>{{ props.item.rain }}</td>
        <td>{{ props.item.electric }}</td>
      </template>
      <template slot="pageText"
                slot-scope="props">
        共&nbsp;{{ props.itemsLength }}&nbsp;条 &nbsp;&nbsp;当前&nbsp;{{ props.pageStart }}-{{ props.pageStop }}&nbsp;条
      </template>
    </v-data-table>
    <div v-else
         style="position:absolute;left:0;right:0;bottom:0;top:0;z-index:9999;opacity:0.3;text-align:center;line-height:800px;">
      <img src="/static/img/loading.gif" />
    </div>
  </div>
</template>
<script>
import mongo from '@vehiclecloud/mongo-rest-client'
function pre (v) {
  return String(v).length === 1 ? '0' + v : v
}
export default {
  name: 'rain-device-access-data-table',
  props: {
    device: {
      type: Object,
      required: true
    },
    start: null,
    end: null
  },
  data () {
    return {
      table: {
        headers: [
          {
            text: '日期',
            align: 'left',
            value: 'date'
          },
          { text: '时间', value: 'time' },
          { text: '降雨量(mm)', value: 'rain' },
          { text: '电量(%)', value: 'electric' }
        ],
        items: [],
        pagination: [{ 'text': '10条', 'value': 10 }, { 'text': '15条', 'value': 15 }, { 'text': '20条', 'value': 20 }, { 'text': 'All', 'value': -1 }],
        totalItems: 0,
        loading: false,
        rowsPerPageItems: [1]
      },
      pagination: {
        startTime: null,
        stopTime: null
      },
      tableFlag: false
    }
  },
  created () {
    this.list(this.start, this.end)
  },
  methods: {
    sortDesc (items, index, bool) {
      if (index === 'date' || index === 'time') {
        if (!bool) {
          return items.sort((a, b) => {
            return b.datetime - a.datetime
          })
        } else {
          return items.sort((a, b) => {
            return a.datetime - b.datetime
          })
        }
      } else {
        if (!bool) {
          return items.sort((a, b) => {
            return b[index] - a[index]
          })
        } else {
          return items.sort((a, b) => {
            return a[index] - b[index]
          })
        }
      }
    },
    fmtDate (time) {
      let d = new Date(+time)
      return `${d.getFullYear()}/${pre(d.getMonth() + 1)}/${pre(d.getDate())}`
    },
    fmtDay (time) {
      let d = new Date(+time)
      return `${pre(d.getMonth() + 1)}/${pre(d.getDate())} ${pre(d.getHours())}:${pre(d.getMinutes())}`
    },
    fmtTime (time) {
      let d = new Date(+time)
      return `${pre(d.getHours())}:${pre(d.getMinutes())}`
    },
    list: function (start, end) {
      let _this = this
      _this.tableFlag = false
      let ps = mongo.db().collection('tenant.device_access_data_history').find({ filter: { device: { '$oid': this.device._id.$oid }, time: { '$gte': start, '$lte': end } }, sort: { 'time': -1 } })
      ps.then(items => {
        _this.table.items = []
        items.items.forEach(item => {
          _this.table.items.push({
            datetime: item.time.$numberLong,
            date: _this.fmtDate(item.time.$numberLong),
            time: _this.fmtTime(item.time.$numberLong),
            rain: item.data['60'].v,
            electric: item.data['66'] == null ? '-' : item.data['66'].v
          })
        })
        _this.tableFlag = true
      })
    }
  },
  watch: {
    'start' (value) {
      if (this.end) {
        this.list(value, this.end)
      }
    },
    'end' (value) {
      if (this.start) {
        this.list(this.start, value)
      }
    }
  }
}
</script>
<style>
</style>
