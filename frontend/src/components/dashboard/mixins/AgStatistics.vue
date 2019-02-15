<template>
  <v-card>
    <v-card-title primary-title class="ml-3 pt-3" style="font-size: 17px;color: #525252;">
      <div>{{ title }}</div>
      <slot></slot>
    </v-card-title>
    <v-card-text>
      <ag-echarts :options="options" :height="'400px'"></ag-echarts>
    </v-card-text>
  </v-card>
</template>

<script>
import AgEcharts from '@/components/echarts/AgEcharts'

export default {
  name: 'ag-statistics',
  props: {
    title: {
      type: String,
      required: true
    },
    options: Object
  },
  data () {
    return {}
  },
  methods: {},
  components: {
    AgEcharts
  }
}
</script>