<template>
  <div class="ag-echarts" :style="{ width, height }"></div>
</template>

<script>
import echarts from 'echarts/lib/echarts'
import 'echarts/lib/chart/line'

export default {
  name: 'ag-echarts',
  props: {
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: '220px'
    },
    initOptions: {
      type: Object,
      default () { return {} }
    },
    options: {
      type: Object
    },
    theme: Object,
    themeName: String
  },
  data () {
    return {
      chart: null
    }
  },
  created () {
    this.chart = null
  },
  mounted () {
    const themeName = this.themeName || this.theme
    this.chart = echarts.init(this.$el, themeName, this.options || this.initOptions)
    window.addEventListener('resize', this.chart.resize)
  },
  beforeDestroy () {
    this.clean()
  },
  watch: {
    options: {
      deep: true,
      handler (v) {
        if (!v) return
        this.chart.setOption(v, true)
      }
    }
  },
  methods: {
    clean () {
      window.removeEventListener('resize', this.chart.resize)
      this.chart.dispose()
    }
  }
}
</script>
