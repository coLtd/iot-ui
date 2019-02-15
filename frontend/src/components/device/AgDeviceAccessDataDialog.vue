<template>
  <v-dialog :value="show" @input="close" scrollable max-width="900px" content-class="dialog--access-data">
    <v-card v-if="show">
      <v-toolbar card color="grey lighten-4">
        <v-toolbar-title>{{ device.name }}
          <small> ({{ device.code }})</small>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon small @click.native="close">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="pt-0">
        <ag-device-access-data v-bind="$props"></ag-device-access-data>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import AgDeviceAccessData from './AgDeviceAccessData'

export default {
  name: 'ag-device-access-data-dialog',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    device: Object,
    skipAccessStatus: Number,
    markerAccessStatus: [Number, Boolean],
    showAccessCodes: {
      type: Boolean,
      default: false
    },
    sensorTypesInTable: Array
  },
  methods: {
    close () {
      this.$emit('update:show', false)
    }
  },
  components: {
    AgDeviceAccessData
  }
}
</script>

<style lang="scss">
.dialog--access-data {
  height: 85%;
  .card__text {
    height: 100%;
  }
}
</style>
