<template> 
    <v-container>  
      <template v-for="item in 10">
         <v-card>
          <v-layout>
            <v-flex xs12>
              <v-card color="" class="red--text">
                <v-card-title primary-title>
                  <div class=""> 
                    <span>规则名称:生长期白天规则</span>
                    <span>预置点:5</span>
                  </div>
                </v-card-title>
                <v-card-actions>
                  <span>&nbsp;&nbsp;</v-spacer> 触发时间:10.23</span>
                   <v-layout row wrap>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期日"
                        v-model="ex4"
                        color="red"
                        value="red"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期一"
                        v-model="ex4"
                        color="red darken-3"
                        value="red darken-3"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期二"
                        v-model="ex4"
                        color="indigo"
                        value="indigo"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期三"
                        v-model="ex4"
                        color="indigo darken-3"
                        value="indigo darken-3"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期四"
                        v-model="ex4"
                        color="orange"
                        value="orange"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期五"
                        v-model="ex4"
                        color="orange darken-3"
                        value="orange darken-3"
                        hide-details
                      ></v-checkbox>
                    </v-flex>
                    <v-flex xs1 sm1 md1>
                      <v-checkbox
                        label="星期六"
                        v-model="ex4"
                        color="orange darken-3"
                        value="orange darken-3"
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
  name: 'poto-edit-rule',
  data () {
    return {
      ex4: ['red', 'indigo', 'orange', 'primary', 'secondary', 'success', 'info', 'warning', 'error', 'red darken-3', 'indigo darken-3', 'orange darken-3']
    }
  },
  methods: {
  }
}
</script>

