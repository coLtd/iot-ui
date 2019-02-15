<template>
<v-container style="background-color:#fff">
<!-- 第1条 -->
    <v-layout row wrap >
        <div style="line-height:5.5" class="mr-4">
            <v-btn-toggle v-model="text">
                <v-btn flat value="left">
                今天
                </v-btn>
                <v-btn flat value="center">
                近7天
                </v-btn>
                <v-btn flat value="right">
                近30天
                </v-btn>
            </v-btn-toggle>
        </div>
        <v-flex xs6>
            <vc-schema-form :schema="search.schema" :ui-schema="search.uiSchema" v-model="params"  >        
            </vc-schema-form>
        </v-flex>
        <v-flex xs2>
            <v-btn color="primary" small  style="margin-left:30px;">导出</v-btn>
            <v-btn color="primary" small  style="margin-left:5px;">设置</v-btn>
        </v-flex>
    </v-layout >
     <v-layout row wrap >
        <div style="width:100%;background-color:#fff;" class="pt-3">
            <div style="float:left;margin-left:10px;cursor:pointer" v-for="item in 20" class="my-3" @click="openDialog">
            <v-card width="160px">
                <v-card-media src="../../../../static/img/1.png" height="150px" >
                </v-card-media>
                <v-card-title primary-title>
                <div>
                    <h4>2017-10-{{item}}</h4>
                </div>
                </v-card-title>
            </v-card>
            </div>
        </div>
    </v-layout>
    <v-layout row justify-center>
        <v-dialog v-model="dialog" max-width="690">
            <v-card>
                 <v-carousel  hide-delimiters='true'>
                    <v-carousel-item v-for="(item,i) in items" :src="item.src" :key="i"></v-carousel-item>
                </v-carousel>
            </v-card>
        </v-dialog>
    </v-layout>
  </v-container>
</template>
<script>
export default {
  name: 'poto-list',
  data () {
    return {
      dialog: false,
      params: {
        text: 'center',
        sdate: null,
        edate: null,
        page: 1
      },
      search: {
        schema: {
          type: 'object',
          'properties': {
            sdate: {
              type: 'number',
              title: '开始日期',
              format: 'date'
            },
            edate: {
              type: 'number',
              title: '结束日期',
              format: 'date'
            }
          }
        },
        uiSchema: {
          'ui:class': { layout: true, row: true },
          sdate: { 'ui:class': { flex: true, xs3: true, 'pr-3': true }, 'ui:props': { clearable: true } },
          edate: { 'ui:class': { flex: true, xs3: true, 'pr-3': true }, 'ui:props': { clearable: true } }
        }
      },
      items: [
        {
          src: '../../../../static/img/1.png'
        },
        {
          src: '../../../../static/img/1.png'
        },
        {
          src: '../../../../static/img/1.png'
        },
        {
          src: '../../../../static/img/1.png'
        }
      ]
    }
  },
  methods: {
    filter () {
      let result = {}
      if (this.params.name) {
        result.name = { '$regex': this.params.name }
      }
      if (this.params.devType) {
        result.type = this.params.devType
      }
      return result
    },
    openDialog () {
      if (this.dialog) {
        this.dialog = false
      } else {
        this.dialog = true
      }
    }
  },
  created () {}
}
</script>
<style>
</style>


