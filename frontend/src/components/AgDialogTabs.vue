<template>
  <v-dialog :value="value" @input="show" scrollable lazy :max-width="maxWidth" :persistent="persistent" content-class="dialog--tabs">
    <v-card>
      <v-toolbar card color="grey lighten-4">
        <v-toolbar-title>{{ title }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn v-if="!$slots.actions" icon small @click.native="show(false)">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="pa-0">
        <v-list>
          <v-list-tile v-for="(tab, idx) in tabs" :key="idx" :value="idx === active" @click="select(idx)">
            <v-list-tile-title class="body-2">{{ tab }}</v-list-tile-title>
          </v-list-tile>
        </v-list>
        <div class="tabs--container px-5 py-3">
          <slot></slot>
        </div>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions v-if="$slots.actions">
        <v-spacer></v-spacer>
        <slot name="actions"></slot>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: 'ag-dialog-tabs',
  props: {
    value: Boolean,
    title: String,
    tabs: Array,
    active: Number,
    maxWidth: {
      type: String,
      default: '700px'
    },
    persistent: Boolean
  },
  methods: {
    show (v) {
      this.$emit('input', v)
    },
    select (idx) {
      this.$emit('update:active', idx)
    }
  }
}
</script>

<style lang="scss">
.dialog--tabs {
  height: 85%;
  .card__text {
    height: 100%;
    .list {
      position: absolute;
      width: 160px;
      .list__tile {
        border-left: 4px solid #ffffff;
        &:hover {
          border-left-color: rgba(0, 0, 0, 0);
        }
        &.list__tile--active {
          border-left-color: #1976d2;
          &:hover {
            border-left-color: #1976d2;
          }
        }
      }
    }
    .tabs--container {
      margin-left: 160px;
      border-left: 1px solid rgb(243, 243, 243);
      min-height: 100%;
    }
  }
}
</style>
