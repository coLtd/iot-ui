export default {
  methods: {
    // 不同业务系统，字段明可能不一样,operatorFiledName 可以设置
    setOperator (item, operatorFieldName = 'staff') {
      item[operatorFieldName] = this.$store.state['tenant.staff'].current._id
    }
  }
}
