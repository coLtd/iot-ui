<template> 
    <v-container>  
      <template v-for="item in 10">
         <v-card>
          <v-layout>
            <v-flex xs12>
              <v-card color="" class="">
                <v-card-title primary-title>
                  <div class=""> 
                    <span>规则名称: 生长期白天规则</span>
                    <span>预置点: 5</span>
                  </div>
                </v-card-title>
                <v-card-actions>
                  <span>&nbsp;&nbsp;&nbsp;触发时间:10.23</span>
                   <v-layout row wrap>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期日"
                        v-model="weekCheck.sun"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期一"
                        v-model="weekCheck.mon"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期二"
                        v-model="weekCheck.tues"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期三"
                        v-model="weekCheck.wen"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期四"
                        v-model="weekCheck.thur"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期五"
                        v-model="weekCheck.fri"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期六"
                        v-model="weekCheck.sta"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                      <div style="margin-left:300px;">
                        <v-btn flat icon >
                          <i class="material-icons">border_color</i>
                        </v-btn>
                        <v-btn flat icon ><i class="material-icons">content_copy</i></v-btn>
                        <v-btn flat icon ><i class="material-icons">delete</i></v-btn>
                      </div>
                  </v-layout>
                </v-card-actions>
              </v-card>
            </v-flex>
          </v-layout>
         </v-card>
      </template>
    </v-container>
</template>
<script>

export default {
  name: 'vedio-rule-edit',
  data () {
    return {
      weekCheck: {
        mon: 0,
        tues: 1,
        wen: 2,
        thur: 3,
        fri: 4,
        sta: 5,
        sun: 6
      }
    }
  },
  methods: {
  }
}
</script>

