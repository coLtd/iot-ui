<template>
  <v-dialog :value="show"
            @input="close"
            scrollable
            max-width="1030px"
            max-height="1230px">
    <v-card v-if="show">
      <v-toolbar card
                 color="grey lighten-4">
        <v-toolbar-title>{{ device.name }}
          <small> ({{ device.code }})</small>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon
               small
               @click.native="close">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
      <v-card-text class="pt-0">
        <span>历史图片</span>
        <v-card>
          <v-container grid-list-md>
            <div v-if="!isShow"
                 style="text-align:center;">
              <img src="/static/img/loading.gif" />
            </div>
            <div style="padding:0px"
                 v-else-if="failed">
              <v-flex text-xs-center
                      style="color:rgb(170, 170, 170);font-size:16px;padding-top:50px">暂无数据</v-flex>
            </div>
            <v-layout row
                      wrap
                      v-else>
              <v-flex v-for="(card,index) in cards"
                      xs3
                      :key="index">
                <v-card height="180px"
                        width="220px"
                        style="text-align:center">
                  <img :src="card.data['v']"
                         height="160px"
                         width="220px"
                         @click="openDialog('detail',{card,index,list:[...cards.slice(index), ...cards.slice(0, index)]})">
                  </img>
                  <span>{{card.time}}</span>
                </v-card>
              </v-flex>
            </v-layout>
          </v-container>
          <div class="text-xs-center">
            <div>
              <v-btn small
                     color="primary"
                     depressed
                     :disabled="displayed"
                     @click="getMore(++skip)">{{!displayed? '查看更多' : '没有更多了'}} </v-btn>
            </div>
          </div>
        </v-card>
        <photo-carousel :show.sync="dialog.detail"
                        :item="dialog.item"></photo-carousel>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import mongo from '@vehiclecloud/mongo-rest-client'
import PhotoCarousel from './PhotoCarousel'
import ItemDialog from '@vehiclecloud/commons/mixins/item-dialog'
import moment from 'moment'
export default {
  name: 'photo-list',
  mixins: [ItemDialog],
  components: {
    PhotoCarousel
  },
  data () {
    return {
      items: [],
      cards: [],
      isShow: false,
      failed: false,
      dialog: {
        detail: false
      },
      displayName: undefined,
      total: 0,
      pageSize: 12,
      displayed: true,
      skip: 0
    }
  },
  props: {
    show: {
      type: Boolean,
      required: true
    },
    device: { type: Object }
  },
  computed: {
    initShow () {
      return !this.show
    }
  },
  watch: {
    'initShow' () {
      if (this.show) {
        this.getMore(this.skip)
      }
    }
  },
  methods: {
    close () {
      this.displayed = false
      this.skip = 0
      this.cards = []
      this.$emit('update:show', this.initShow)
    },
    getMore (skip) {
      mongo.db().collection('tenant.device_powerview_data').find({ filter: { device: { '$oid': this.device._id.$oid } }, sort: { 'time': -1 }, 'limit': this.pageSize, 'skip': skip * this.pageSize }).then(data => {
        console.log(data)
        if (data.items.length > 0) {
          this.isShow = true
          this.total = data.total.$numberLong
          this.displayed = !(this.total > this.pageSize * (skip + 1))
          this.items = [...this.cards, ...data.items]
          this.items.forEach(element => {
            let time = moment(parseInt(element.createdOn.$numberLong)).format('YYYY-MM-DD HH:mm:ss')
            element.time = time
          })
          this.cards = this.items
        } else {
          this.isShow = true
          this.failed = true
        }
      }, error => {
        console.log(error)
        this.isShow = true
        this.failed = true
      })
    }
  }
}
</script>
<style>
</style>
