function filterFn (level, parentField) {
  return (option, ctx, self, item) =>
    option.level === level &&
    item && item[parentField] &&
    option.parent.$oid === item[parentField].$oid
}

function params (level, parentField) {
  return (ctx, self, item) => {
    if (!item || !item[parentField]) return false
    return ({ filter: { level: level, parent: item[parentField] } })
  }
}

function option (level, parentField) {
  return { filter: filterFn(level, parentField), params: params(level, parentField) }
}

function uiSchema (width = 'xs2') {
  return {
    'ui:class': { layout: true, row: true, wrap: true },
    'ui:title': { 'ui:class': { flex: true, xs12: true, 'label--title': true } },
    province: { 'ui:class': { flex: true, [width]: true, 'pr-3': true }, 'ui:options': { filter: option => option.level === 2, params: { filter: { level: 2 } } } },
    city: { 'ui:class': { flex: true, [width]: true, 'pr-3': true }, 'ui:show': () => true, 'ui:options': option(3, 'province') },
    district: { 'ui:class': { flex: true, [width]: true, 'pr-3': true }, 'ui:show': () => true, 'ui:options': option(4, 'city') },
    town: { 'ui:class': { flex: true, [width]: true, 'pr-3': true }, 'ui:show': () => true, 'ui:options': option(5, 'district') },
    village: { 'ui:class': { flex: true, [width]: true, 'pr-3': true }, 'ui:show': () => true, 'ui:options': option(6, 'town') }
  }
}

export default {
  filterFn,
  uiSchema
}
