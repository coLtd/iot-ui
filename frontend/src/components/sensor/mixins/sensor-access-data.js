export default {
  props: {
    device: {
      type: Object,
      required: true
    },
    sensor: {
      type: Object,
      required: true
    },
    startTime: {
      type: Number,
      required: true
    },
    stopTime: {
      type: Number,
      required: true
    }
  },
  mounted () {
    Promise.all([
      this.$store.dispatch('init', { collection: 'base.device.type' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' })
    ]).then(() => {
      this.deviceType = this.$store.state['base.device.type'].items.find(t => t._id.$oid === this.device.type.$oid)
      this.sensorTypes = this.$store.state['base.sensor.type'].items.filter(t => this.deviceType.sensorTypes.some(typeId => t._id.$oid === typeId.$oid))
      this.refresh()
    })
  },
  watch: {
    device () {
      this.refresh()
    },
    sensor () {
      this.refresh()
    },
    startTime () {
      this.refresh()
    },
    stopTime () {
      this.refresh()
    }
  },
  data () {
    return {
      deviceType: null,
      sensorTypes: null
    }
  }
}
