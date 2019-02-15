<template>
  <v-app id="app">
    <vc-navigation-authed-drawer v-model="drawer.show">
    </vc-navigation-authed-drawer>
    <v-toolbar color="blue" dark app clipped-left fixed>
      <v-toolbar-title :style="$vuetify.breakpoint.smAndUp ? 'width: 300px; min-width: 250px' : 'min-width: 72px'" class="ml-0 pl-3">
        <v-toolbar-side-icon @click.stop="drawer.show = !drawer.show"></v-toolbar-side-icon>
        <span class="hidden-xs-only">物联网管理平台</span>
      </v-toolbar-title>
      <div class="d-flex align-center" style="margin-left: auto">
        <v-btn icon @click="$router.push('/tenant/device/alarm')" title="当日告警">
          <v-icon>alarm</v-icon>
        </v-btn>
        <v-btn icon>
          <v-icon>notifications</v-icon>
        </v-btn>
        <vc-staff-popup :me="$store.state['tenant.staff'].current" @logout="logout"></vc-staff-popup>
      </div>
    </v-toolbar>
    <v-content>
      <v-container fluid fill-height>
        <v-layout>
          <v-flex class="pb-4 mr-3" :class="{ 'ml-3': !drawer.show }">
            <v-breadcrumbs divider="/">
              <v-breadcrumbs-item v-for="item in breadcrumbs" :key="item.text" :disabled="item.disabled" :to="item.to">
                {{ item.text }}
              </v-breadcrumbs-item>
            </v-breadcrumbs>
            <router-view></router-view>
          </v-flex>
        </v-layout>
      </v-container>
    </v-content>
  </v-app>
</template>

<script>
import VcNavigationAuthedDrawer from '@vehiclecloud/commons/components/VcNavigationAuthedDrawer'
import VcStaffPopup from '@vehiclecloud/commons/components/VcStaffPopup'
import RouterBreadcrumbs from '@vehiclecloud/commons/mixins/router-breadcrumbs'
import Oauth2 from '@vehiclecloud/oauth2-client'

export default {
  name: 'app',
  mixins: [RouterBreadcrumbs],
  watch: {
    '$route' () {
      this.$store.commit('set', { name: 'search', k: 'keyword', v: null })
    }
  },
  data () {
    return {
      drawer: {
        show: null
      }
    }
  },
  methods: {
    logout () {
      Oauth2.logout()
    }
  },
  components: {
    VcNavigationAuthedDrawer,
    VcStaffPopup
  }
}
</script>
