<template>
  <v-card class="card--gis">
    <div class="table-search">
      <v-card-title class="pa-0 layout">
        <vc-schema-form tag="div"
                        :schema="search.schema"
                        :ui-schema="search.uiSchema"
                        v-model="search.params"></vc-schema-form>
        <div style="width: 300px;flex-shrink: 0;">
          <ul v-if="map.type === 'devices'"
              class="status-legend pr-5">
            <li class="status-3"
                :class="{ 'legend-active': devices.accessState.status === 3 }"
                @click="devicesUpdateState(3)">故障</li>
            <li class="status-2"
                :class="{ 'legend-active': devices.accessState.status === 2 }"
                @click="devicesUpdateState(2)">告警</li>
            <li class="status-4"
                :class="{ 'legend-active': devices.accessState.code === 2003 }"
                @click="devicesUpdateState(null, 2003)">离线</li>
            <li class="status-1"
                :class="{ 'legend-active': devices.accessState.status === 1 }"
                @click="devicesUpdateState(1)">正常</li>
          </ul>
        </div>
      </v-card-title>
    </div>
    <c-map-layers v-bind="map.layers"
                  ref="mapLayers">
      <c-cartogram v-if="map.type === 'fourColor'">
        <c-cartogram-four-color v-model="fourColor.data"
                                v-bind="fourColor.props">
          <cc-label v-for="p in fourColor.data"
                    :key="p.code"
                    :latlng="{lat: p.bunds[5], lng: p.bunds[4]}"
                    :label-color="fourColorLabelColor(p.code)"
                    className="cc-label"
                    @label-click="fourColorPolyClick(p.code)"
                    @label-mouseover="fourColorPolyMouseover(p.code)"
                    @label-mouseleave="fourColorPolyMouseleave(p.code)">
            <div>{{ p.name }}</div>
          </cc-label>
          <cc-label v-for="(count, code) in fourColor.counts.map"
                    :key="'c_' + code"
                    :latlng="fourColorCenterOf(code)"
                    :offset-y="-17"
                    :label-color="fourColorLabelColor(code)"
                    className="cc-label"
                    @label-click="fourColorPolyClick(code)"
                    @label-mouseover="fourColorPolyMouseover(code)"
                    @label-mouseleave="fourColorPolyMouseleave(code)">
            <div>{{ count }}个</div>
          </cc-label>
        </c-cartogram-four-color>
      </c-cartogram>
      <template v-else-if="map.type === 'farmlands'">
        <c-polygon v-for="f in farmlands.items"
                   :key="f._id.$oid"
                   :latlngs="f.gis"
                   :fill="true"
                   fill-color="#229af0"
                   :fill-opacity="1"
                   :popup-event="null"
                   @polygon-click="farmlandsPolygonClick(f)"
                   @polygon-mouseover="farmlandsLayerMouseover(f, 'p')"
                   @polygon-mouseleave="farmlandsLayerMouseleave('p')">
        </c-polygon>
        <template v-if="farmlands.hover.item">
          <cc-label :latlng="{ lat: farmlands.hover.item.lat, lng: farmlands.hover.item.lng }"
                    className="cc-label cc-label-farmlands"
                    @label-click="farmlandsPolygonClick(farmlands.hover.item)"
                    @label-mouseover="farmlandsLayerMouseover(null, 'l1')"
                    @label-mouseleave="farmlandsLayerMouseleave('l1')">
            <div>{{ farmlands.hover.item.name }}</div>
            <div>IOT数量: {{ farmlands.counts.map[farmlands.hover.item._id.$oid] || '0' }}个</div>
            <div>地块面积: {{ (farmlands.hover.item.acreage !== undefined && (farmlands.hover.item.acreage + '亩')) || '未知' }}</div>
          </cc-label>
        </template>
      </template>
      <template v-else-if="map.type === 'devices'">
        <c-polygon :latlngs="devices.farmland.gis"
                   :stroke="true"
                   :fill="true"
                   fill-color="#229af0"
                   :fill-opacity="0.3"
                   :popup-event="null">
        </c-polygon>
        <c-marker-cluster>
          <c-marker v-for="device in devices.items"
                    :key="device._id.$oid"
                    v-if="device.lat && device.lng"
                    :title="device.name"
                    :latlng="{ lat: device.lat, lng: device.lng }"
                    :icon="{image: devicesMarkerIconOf(device), iconSize: [30, 'auto'], iconAnchor: [15, 45]}"
                    :popup-props="{offset: [0, -38]}"
                    @c-popupopen="devicesPopupopen(device)"
                    @c-popupclose="devicesPopupclose(device)"
                    :ref="devicesMarkerRefOf(device)">
            <ag-device-popup :device="device"></ag-device-popup>
            <div slot="icon"
                 c-slot
                 v-if="(devicesDeviceTypeOf(device) ? devicesDeviceTypeOf(device).gisIcon : 1) === 1"
                 class="div-icon"
                 :class="'div-icon-1-' + devicesIconStatusOf(device)">{{ devicesAccessDataOf(device, '3') }}</div>
          </c-marker>
        </c-marker-cluster>
        <ag-monitor-gis-devices-search :farmland="devices.farmland"
                                       v-model="devices.items"
                                       :access-state="devices.accessState"
                                       :current-device="devices.current"
                                       @update:currentDevice="devicesUpdateCurrent"
                                       ref="devicesSearch"></ag-monitor-gis-devices-search>
      </template>
      <div class="leaflet-bottom leaflet-right leaflet-icon leaflet-refresh">
        <div class="leaflet-bar leaflet-control">
          <a v-show="navigator.stack.length > 1"
             title="返回"
             @click="navigatorBack">
            <v-icon>arrow_back</v-icon>
          </a>
          <a title="刷新"
             @click="refresh">
            <v-icon>autorenew</v-icon>
          </a>
        </div>
      </div>
    </c-map-layers>
  </v-card>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'

import CMapLayers from '@agrithings/cmap/CMapLayers'
import CMarkerCluster from '@agrithings/cmap/overlay/CMarkerCluster'
import CMarker from '@agrithings/cmap/overlay/CMarker'
import CPolygon from '@agrithings/cmap/overlay/CPolygon'
import CCartogram from '@agrithings/cmap/cartogram/c-cartogram'
import CCartogramFourColor from '@agrithings/cmap/cartogram/c-cartogram-four-color'
import CcLabel from '@agrithings/cmap/cartogram/cc-label'

import { types, mixMapTypeOfArea } from '@agrithings/cmap/util'

import searchUtil from '@vehiclecloud/commons/util/search'

import AgMonitorAgrithingsPopup from './agrithings/Popup'
import AgBloomskyRainPopup from './bloomsky/RainPopup'
import AgMonitorBloomskyPopup from './bloomsky/Popup'
import AgMonitorPtzPopup from './ptz/Popup'
import AgMonitorPowerViewPopup from './powerview/Popup'
import AgMonitorGisDevicesSearch from './components/DevicesSearch'

import { accessDataOf, Schema, Dependencies, UiSchema, Params } from '../tenant/util'

const keySearchParams = ['province', 'city', 'district', 'town', 'tenant', 'farmland']

const MapNavigator = {
  data () {
    return {
      navigator: {
        stack: [], // [params: {}]
        backing: false
      }
    }
  },
  methods: {
    navigatorSave () {
      if (this.navigator.backing) {
        this.navigator.backing = false
        return
      }

      let p = keySearchParams.reduce((o, k) => {
        o[k] = this.search.params[k]
        return o
      }, {})
      this.navigator.stack.push(JSON.stringify(p))
    },
    navigatorBack () {
      this.navigator.backing = true
      this.navigator.stack.pop()
      let params = JSON.parse(this.navigator.stack[this.navigator.stack.length - 1])
      this.search.params = { ...this.search.params, ...params }
    }
  }
}

// abstract showForuColor(), showFarmlands()
const Search = {
  created () {
    this.search.inited = Promise.all([
      this.$store.dispatch('init', { collection: 'tenant.farmland' }).then(() => this.showForuColor()),
      // 在此处初始化，防止popup处异步加载出现问题
      this.$store.dispatch('init', { collection: 'base.device.type' }),
      this.$store.dispatch('init', { collection: 'base.sensor.type' })
    ])
  },
  data () {
    const searchAddressUiSchema = searchUtil.addressUiSchema();

    ['city', 'district', 'town'].forEach(name => {
      let ui = searchAddressUiSchema[name]
      let oriFilter = ui['ui:options'].filter
      let filter = (option, ctx, el, item) => {
        return oriFilter(option, ctx, el, item) &&
          this.$store.state['tenant.farmland'].items.some(f => f.address[name] && f.address[name].$oid === option._id.$oid)
      }
      ui['ui:options'].filter = filter
    })

    return {
      search: {
        inited: null,
        schema: {
          type: 'object',
          properties: {
            ...Schema.Address,
            ...Schema.TenantFarmland
          },
          dependencies: {
            ...Dependencies.Address,
            ...Dependencies.TenantFarmland
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          ...searchAddressUiSchema,
          ...UiSchema.TenantFarmland()
        },
        params: {
          ...Params.Address,
          // province: this.$store.state.config.province._id,
          ...Params.TenantFarmland
        },
        event: {
          source: null
        }
      }
    }
  },
  watch: ['province', 'city', 'district', 'town', 'tenant', 'farmland'].reduce((r, k) => {
    r[`search.params.${k}`] = function (v) {
      if (this.search.event.source) return

      this.search.event.source = k
      this.$nextTick(() => {
        if (this.search.params.town || this.search.params.tenant || this.search.params.farmland) {
          this.showFarmlands()
        } else {
          this.showForuColor()
        }
        this.search.event.source = null
      })
    }
    return r
  }, {}),
  computed: {
    searchAreaCurrentLevelField () {
      if (this.search.params.town) return 'village'
      if (this.search.params.district) return 'town'
      if (this.search.params.city) return 'district'
      if (this.search.params.province) return 'city'
      return 'province'
    }
  }
}

function fullCode (code) {
  if (code.length === 12) return code
  return code + (code.length === 6 ? '000000' : '000')
}

function simpleCode (code) {
  if (code.length < 12) return code
  return code.substr(6, 6) === '000000' ? code.substr(0, 6) : code.substr(0, 9)
}

const AreaNames = {
  2: 'province',
  3: 'city',
  4: 'district',
  5: 'town',
  6: 'village'
}

const FourColorStyle = {
  Common: {
    poly: { color: '#444444', weight: 0.5, opacity: 0.6, fillColor: '#444444', fillOpacity: 0, labelColor: '#000000' },
    label: { color: '#000000' }
  },
  Hover: {
    poly: { color: '#444444', weight: 1, opacity: 1, fillColor: 'rgba(255,215,0,0.8)', fillOpacity: 1, labelColor: 'rgb(100,0,0)' },
    label: { color: '#000000' }
  },
  Active: {
    poly: { color: '#444444', weight: 0, opacity: 0, fillColor: '#05abf2', fillOpacity: 1, labelColor: '#ffffff' },
    label: { color: '#ffffff' }
  }
}

const FourColor = {
  data () {
    let self = this
    return {
      fourColor: {
        data: null,
        counts: {
          map: {}
        },
        props: {
          maincode: null,
          params: {
            colors: {},
            fillopacity: 0
          },
          styles: {}, // {code: {count: 0, style: {}}}
          polyClick (e) {
            self.fourColorPolyClick(e.target.code)
          },
          polyMouseover (e) {
            self.fourColorPolyMouseover(e.target.code)
          },
          polyMouseleave (e) {
            self.fourColorPolyMouseleave(e.target.code)
          }
        }
      }
    }
  },
  watch: {
    'fourColor.data' (v) {
      if (!v) return
      this.farmlands.counts.promise.then(() => {
        this.map.layers.bounds = [
          [
            Math.min.apply(null, v.map(d => d.bunds[1])),
            Math.min.apply(null, v.map(d => d.bunds[0]))
          ], [
            Math.max.apply(null, v.map(d => d.bunds[3])),
            Math.max.apply(null, v.map(d => d.bunds[2]))
          ]
        ]
      })
      this.fourColorUpdateCounts()
    }
  },
  methods: {
    showForuColor () {
      this.navigatorSave()
      this.$store.state['base.area'].promise.then(() => {
        this.fourColor.data = null
        this.fourColor.counts.map = {}
        this.fourColor.props.styles = {}
        let areaId = this.search.params.town || this.search.params.district || this.search.params.city || this.search.params.province || this.search.params.country
        this.map.layers.mapType = types.HIDDENMAP
        this.fourColor.props.maincode = simpleCode(this.$store.state['base.area'].items.find(a => a._id.$oid === areaId.$oid).code)
        this.map.type = 'fourColor'
      })
    },
    fourColorPolyClick (oriCode) {
      let code = fullCode(oriCode)
      if (!this.fourColor.counts.map[code]) return
      let area = this.$store.state['base.area'].items.find(a => a.code === code)
      this.search.params[AreaNames[area.level]] = area._id
    },
    fourColorPolyMouseover (code) {
      if (this.fourColor.counts.map[fullCode(code)]) return
      this.$set(this.fourColor.props.styles, simpleCode(code), FourColorStyle.Hover.poly)
    },
    fourColorPolyMouseleave (code) {
      this.fourColor.props.styles[simpleCode(code)] = this.fourColor.counts.map[fullCode(code)] ? FourColorStyle.Active.poly : FourColorStyle.Common.poly
    },
    fourColorLabelColor (code) {
      return this.fourColor.counts.map[fullCode(code)] ? FourColorStyle.Active.label.color : FourColorStyle.Common.label.color
    },
    fourColorCenterOf (code) {
      let p = this.fourColor.data.find(d => d.code === simpleCode(code))
      if (!p) return null
      return { lat: p.bunds[5], lng: p.bunds[4] }
    },
    fourColorUpdateCounts () {
      this.fourColor.counts.map = {}
      this.fourColor.props.styles = {}

      Promise.all([this.$store.state['tenant.farmland'].promise, this.farmlands.counts.promise]).then(() => {
        this.search.params.farmlands.forEach(f => {
          let count = this.farmlands.counts.map[f.value]
          if (!count) return
          let areaId = f.address[this.searchAreaCurrentLevelField]
          if (!areaId) return
          let area = this.$store.state['base.area'].items.find(a => a._id.$oid === areaId.$oid)
          if (!area) return
          let code = area.code
          let sCode = simpleCode(code)
          if (!this.fourColor.data.some(d => d.code === sCode)) return
          this.fourColor.counts.map[code] = count + (this.fourColor.counts.map[code] || 0)
        })
        Object.keys(this.fourColor.counts.map).forEach(code => {
          this.$set(this.fourColor.props.styles, simpleCode(code), FourColorStyle.Active.poly)
        })
      })
    }
  }
}

// 经纬度最大跨度
const MaxSize = { lat: 0.017303, lng: 0.041156 }

const Farmlands = {
  data () {
    return {
      farmlands: {
        items: [],
        hover: {
          item: null,
          latch: 0
        },
        counts: {
          items: [],
          map: {},
          promise: null
        },
        skipShow: false // skip show fn if polygon click
      }
    }
  },
  created () {
    this.farmlandsQueryCounts()
  },
  watch: {
    // 'search.params.farmlands' () {
    //   this.farmlandsQueryCounts()
    // },
    'map.type' () {
      this.farmlandsHoverReset()
    }
  },
  methods: {
    showFarmlands () {
      this.navigatorSave()
      if (this.farmlands.skipShow) {
        this.farmlands.skipShow = false
        return
      }
      this.farmlandsHoverReset()
      let items = this.search.params.farmland ? [this.search.params.farmlands.find(f => f._id.$oid === this.search.params.farmland.$oid)] : this.search.params.farmlands

      const showNoGisWarning = () => {
        alert('没有包含有效GIS信息的地块，请先完善地块GIS信息')
      }

      if (!items.length) {
        showNoGisWarning()
        return
      }
      let itemsNoInitGis = items.filter(f => !f.gis)

      const doShow = _items => {
        this.farmlands.items = _items
        this.map.layers.mapType = this.farmlandsMixMapType()
        this.farmlandsUpdateBounds()
        this.map.type = 'farmlands'
      }

      if (!itemsNoInitGis.length) {
        doShow(items)
        return
      }
      let itemsIds = []
      let itemsMap = {}
      itemsNoInitGis.forEach(item => {
        itemsIds.push(item._id)
        itemsMap[item._id.$oid] = item
      })

      mongo.db(this.$store.state['tenant.farmland'].database).collection('tenant.farmland').find({
        filter: { _id: { $in: itemsNoInitGis.map(item => item._id) } },
        projection: { gis: 1 }
      }).then(({ items: itemsWithGis }) => {
        if (!itemsWithGis.length) {
          showNoGisWarning()
          return
        }
        itemsWithGis.forEach(item => {
          this.$store.commit('update', { name: 'tenant.farmland', k: 'items', f: items => items.find(f => f._id.$oid === item._id.$oid), p: 'gis', v: item.gis })
          itemsMap[item._id.$oid].gis = item.gis
        })
        doShow(items.filter(item => !!item.gis))
      })
    },
    farmlandsUpdateBounds () {
      let items = this.farmlands.items
      let bounds = [
        [
          Math.min.apply(null, items.map(f => Math.min.apply(null, f.gis.map(g => g.lat)))),
          Math.min.apply(null, items.map(f => Math.min.apply(null, f.gis.map(g => g.lng))))
        ], [
          Math.max.apply(null, items.map(f => Math.max.apply(null, f.gis.map(g => g.lat)))),
          Math.max.apply(null, items.map(f => Math.max.apply(null, f.gis.map(g => g.lng))))
        ]
      ]
      if (bounds[1][0] - bounds[0][0] > MaxSize.lat || bounds[1][1] - bounds[0][1] > MaxSize.lng) {
        let minLat = bounds[0][0]
        let minLng = bounds[0][1]

        let grids = items.reduce((r, item) => {
          let x = Math.ceil((item.lat - minLat) / MaxSize.lat)
          let y = Math.ceil((item.lng - minLng) / MaxSize.lng)
          let key = `${x}:${y}`
          if (!r[key]) r[key] = 0
          r[key] += 1
          return r
        }, {})
        let max = Math.max.apply(null, Object.values(grids))
        let maxKey = Object.keys(grids).find(k => grids[k] === max)
        let axis = maxKey.split(':')

        this.map.layers.center = { lat: minLat + axis[0] * MaxSize.lat - MaxSize.lat / 2, lng: minLng + axis[1] * MaxSize.lng - MaxSize.lng / 2 }
        this.map.layers.zoom = 15
      } else {
        this.map.layers.bounds = bounds
      }
    },
    farmlandsMixMapType () {
      let farmland = (this.search.params.farmland && this.$store.state['tenant.farmland'].items.find(item => item._id.$oid === this.search.params.farmland.$oid)) || (this.search.params.farmlands.length && this.search.params.farmlands[0])
      if (!farmland || !farmland.address) return mixMapTypeOfArea()

      return mixMapTypeOfArea([farmland.address.district.$oid, farmland.address.city.$oid, farmland.address.province.$oid])
    },
    farmlandsQueryCounts () {
      return this.search.inited.then(() => this.$store.state['tenant.farmland'].promise.then(() => {
        this.farmlands.counts.promise = mongo.db().collection('tenant.device').aggregate([
          { $match: { status: 1, _removed: { $exists: false } } },
          { $group: { _id: '$farmland', count: { $sum: 1 } } }
        ]).then(counts => {
          this.farmlands.counts.items = counts
          this.farmlands.counts.map = counts.reduce((m, c) => {
            if (!c._id) return m // skip record farmland is null

            m[c._id.$oid] = c.count
            return m
          }, {})
        })
      }))
    },
    farmlandsPolygonClick (farmland) {
      if (this.search.params.farmland !== farmland) {
        this.farmlands.skipShow = true
        this.search.params.farmland = farmland._id
      }
      this.showDevices()
    },
    farmlandsLayerMouseover (f, s) {
      if (f) this.farmlands.hover.item = f
      this.farmlands.hover.latch += 1
    },
    farmlandsLayerMouseleave (s) {
      this.farmlands.hover.latch -= 1
      if (this.farmlands.hover.latch) return

      setTimeout(() => {
        if (!this.farmlands.hover.latch) this.farmlands.hover.item = null
      }, 10)
    },
    farmlandsHoverReset () {
      this.farmlands.hover.latch = 0
      this.farmlands.hover.item = null
    }
  }
}

const Devices = {
  created () {
    this.$store.dispatch('init', { collection: 'base.device.type' })
  },
  watch: {
    'map.type' () {
      if (this.devices.current === null) return
      this.devices.current = null
    }
  },
  data () {
    return {
      devices: {
        farmland: null,
        items: [],
        accessState: null,
        current: null,
        popupopened: false
      }
    }
  },
  methods: {
    showDevices () {
      this.devices.farmland = this.$store.state['tenant.farmland'].items.find(f => f._id.$oid === this.search.params.farmland.$oid)
      this.devicesUpdateBounds()
      this.devices.accessState = { status: null, code: null }
      this.map.type = 'devices'
    },
    devicesUpdateBounds () {
      this.map.layers.bounds = [
        [
          Math.min.apply(null, this.devices.farmland.gis.map(p => p.lat)),
          Math.min.apply(null, this.devices.farmland.gis.map(p => p.lng))
        ], [
          Math.max.apply(null, this.devices.farmland.gis.map(p => p.lat)),
          Math.max.apply(null, this.devices.farmland.gis.map(p => p.lng))
        ]
      ]
    },
    devicesDeviceTypeOf (device) {
      return this.$store.state['base.device.type'].items.find(t => t._id.$oid === device.type.$oid)
    },
    devicesIconStatusOf (device) {
      if (!device.accessState) return 1
      if (device.accessState.code && device.accessState.code.includes(2003)) return 4 // offline
      return (device.accessState.status && device.accessState.status.length && device.accessState.status[0]) || 1
    },
    devicesMarkerIconOf (device) {
      let type = this.devicesDeviceTypeOf(device)
      let status = this.devicesIconStatusOf(device)
      let gisIcon = type ? type.gisIcon : 1
      return `/static/gis/icon/${gisIcon}/${status}.png`
    },
    devicesUpdateState (status, code = null) {
      this.devices.accessState = {
        status: this.devices.accessState.status === status ? null : status,
        code: this.devices.accessState.code === code ? null : code
      }
    },
    devicesMarkerRefOf (device) {
      return 'marker-' + device._id.$oid
    },
    devicesUpdateCurrent (v) {
      let ref = this.$refs[this.devicesMarkerRefOf(v)]
      ref && ref.length && ref[0].popupOpen()
    },
    devicesPopupopen (device) {
      this.devices.popupopened = true
      this.devices.current = device
    },
    devicesPopupclose (device) {
      if (this.devices.current === device) {
        this.devices.popupopened = false
        this.devices.current = null
      }
    },
    devicesAccessDataOf: accessDataOf
  }
}

const providerPopup = {
  1: AgMonitorAgrithingsPopup,
  2: AgMonitorBloomskyPopup,
  3: AgMonitorPtzPopup,
  4: AgMonitorPowerViewPopup,
  5: AgBloomskyRainPopup
}

const AgDevicePopup = {
  name: 'ag-device-popup',
  functional: true,
  props: {
    device: {
      type: Object,
      required: true
    }
  },
  render (h, ctx) {
    let device = ctx.props.device
    let parent = ctx.parent
    if (!device) return null
    let type = parent.devicesDeviceTypeOf(device)
    if (!type) return null
    let provider = type.provider
    if (provider === 2) {
      if (type.code === 105) provider = 5
    }
    return h(providerPopup[provider], { props: ctx.props })
  }
}

export default {
  name: 'monitor-gis',
  mixins: [MapNavigator, Search, FourColor, Farmlands, Devices],
  data () {
    return {
      map: {
        type: null, // fourColor | farmlands | devices
        layers: {
          mapTypes: [types.MIXMAP, types.VECTORMAP],
          mapType: types.HIDDENMAP,
          zoomControl: { position: 'bottomright' },
          center: this.$store.state.config.province.center,
          zoom: 15,
          bounds: null
        }
      }
    }
  },
  methods: {
    refresh () {
      if (this.map.type === 'devices') {
        this.$refs.devicesSearch.search()
        this.devicesUpdateBounds()
      } else {
        this.farmlandsQueryCounts().then(() => {
          if (this.map.type === 'fourColor') {
            this.fourColorUpdateCounts()
          } else if (this.map.type === 'farmlands') {
            this.farmlandsUpdateBounds()
          }
        })
      }
    }
  },
  components: {
    CMapLayers,
    CMarkerCluster,
    CMarker,
    CPolygon,
    CCartogram,
    CCartogramFourColor,
    CcLabel,
    AgMonitorAgrithingsPopup,
    AgMonitorBloomskyPopup,
    AgBloomskyRainPopup,
    AgMonitorPtzPopup,
    AgMonitorPowerViewPopup,
    AgDevicePopup,
    AgMonitorGisDevicesSearch
  }
}
</script>

<style lang="scss">
.status-legend {
  list-style: none;
  display: flex;
  li {
    padding: 3px 10px;
    border-radius: 2px;
    flex: 1;
    cursor: pointer;
    &::before {
      content: " ";
      width: 10px;
      height: 10px;
      display: inline-block;
      margin-right: 0.5rem;
      border-radius: 50%;
    }
    &.status-1 {
      &::before {
        background: #2298f2;
      }
    }
    &.status-2 {
      &::before {
        background: #faba52;
      }
    }
    &.status-3 {
      &::before {
        background: #f04643;
      }
    }
    &.status-4 {
      &::before {
        background: #acb1bf;
      }
    }
    &.legend-active {
      background-color: #f0f0f0;
    }
  }
}
.card--gis {
  padding: 0rem 1rem 1rem;
  .cmap-container {
    width: 100%;
    height: calc(100vh - 264px);
    .leaflet-popup {
      .leaflet-popup-close-button {
        width: 29px;
        height: 29px;
        right: -12px;
        top: -12px;
        border-radius: 50%;
        z-index: 2;
        color: #333333;
        background: #fff;
        font-size: 25px;
        font-weight: 100;
        padding: 7px 0;
      }
      .leaflet-popup-content-wrapper {
        padding: 0;
        .leaflet-popup-content {
          margin: 0;
          .flex strong {
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            display: block;
            margin-right: 10px;
          }
        }
      }
    }
  }
  .leaflet-bottom {
    bottom: 1.2rem;
  }
  .leaflet-right {
    right: 1rem;
  }
  .leaflet-bar {
    border-radius: 0;
    background-color: #575859;
    padding: 0 5px;
    a {
      background-color: rgb(87, 88, 89);
      color: #ffffff;
      border-radius: 0;
      width: 20px;
      height: 30px;
      line-height: 28px;
    }
  }
  .leaflet-icon {
    bottom: 28px;
    margin-right: 1rem;
    .leaflet-bar {
      padding: 0 5px;
      a {
        width: 100%;
        .icon {
          font-size: 20px;
          color: #ffffff;
        }
      }
    }
  }
  .leaflet-refresh {
    bottom: 98px;
  }
  .cc-label {
    white-space: nowrap;
    &.cc-label-farmlands {
      color: #ffffff;
      background-color: rgba(16, 16, 16, 0.8);
      width: auto !important;
      text-align: left !important;
      border: 1px solid #bbbbbb;
      padding: 0.8rem 0.2rem;
      font-size: 13px !important;
    }
  }
}
.leaflet-div-icon {
  background-color: inherit;
  border: none;
  .div-icon {
    height: 45px;
    background-size: 30px 40px;
    line-height: 28px;
    font-size: 11px;
    text-align: center;
    color: white;
    &.div-icon-1-1 {
      background-image: url(/static/gis/icon/1/1.png);
    }
    &.div-icon-1-2 {
      background-image: url(/static/gis/icon/1/2.png);
    }
    &.div-icon-1-3 {
      background-image: url(/static/gis/icon/1/3.png);
    }
    &.div-icon-1-4 {
      background-image: url(/static/gis/icon/1/4.png);
    }
  }
}
</style>
