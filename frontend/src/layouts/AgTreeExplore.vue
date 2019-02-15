<template>
  <v-card class="tree-explore" height="calc(100vh - 25.5rem)">
    <v-layout>
      <div class="sidebar">
        <slot name="sidebar"></slot>
      </div>
      <v-flex>
        <slot></slot>
      </v-flex>
    </v-layout>
  </v-card>
</template>
<script>
export default {
  name: 'ag-tree-explore',
  props: {
    sidebarTitle: String,
    mainTitle: String
  }
}
</script>
<style lang="scss">
.tree-explore {
  display: flex;
  .sidebar {
    width: 23rem;
    border-right: 1px solid #f1f1f1;
  }
  .toolbar {
    border-bottom: 1px solid #f1f1f1;
    background-color: inherit;
    color: #707070;
    padding: 0 24px !important;
    .toolbar__title {
      font-size: 1.1rem;
    }
  }
  .search {
    .input-group__details {
      max-width: 100% !important;
      &:before {
        background-color: #f1f1f1 !important;
      }
    }
  }
  .btn--float {
    position: absolute;
    right: 0.5rem;
    margin-top: -1.7rem;
    z-index: 2;
  }
  .blue .btn--icon--true-color.btn--disabled .icon {
    color: #fff !important;
  }
  .card--table {
    box-shadow: none;
  }
}
.dialog--tree-explore {
  .card-text--border {
    height: calc(100% - 19px);
    background-color: #ffffff;
    border: 1px solid #f1f1f1;
  }
  .card--table {
    padding: 0 !important;
    box-shadow: none;
    .table__overflow {
      border: none !important;
      margin-top: 0 !important;
    }
    .table {
      .datatable__actions__select {
        display: none;
      }
    }
  }
}
</style>

