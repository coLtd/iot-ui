const direction2Text = params => {
  if (!params) return
  let para = params.replace('"', '').replace('"', '')
  switch (para) {
    case 'N':
      return '北风'
    case 'NE':
      return '东北风'
    case 'E':
      return '东风'
    case 'SE':
      return '东南风'
    case 'S':
      return '南风'
    case 'SW':
      return '西南风'
    case 'W':
      return '西风'
    case 'NW':
      return '西北风'
    default:
      return '-'
  }
}
export default {
  direction2Text
}
