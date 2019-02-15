<template>
  <v-dialog :value="show" @input="close" scrollable max-width="930px" content-class="dialog--access-data">
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
        <bk-device-access-data v-bind="$props"></bk-device-access-data>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import BkDeviceAccessData from './BkDeviceAccessData'

export default {
  name: 'bk-device-access-data-dialog',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    device: {
      type: Object,
      required: true
    }
  },
  methods: {
    close () {
      this.$emit('update:show', false)
    }
  },
  components: {
    BkDeviceAccessData
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
