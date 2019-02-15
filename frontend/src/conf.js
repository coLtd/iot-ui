export default {
  Mongo: {
    iss: {
      database: 'iov',
      base: 'http://139.198.13.191:9000'
    },
    iot: {
      database: 'iot',
      base: 'http://139.198.13.191:9000'
    }
  },
  Redis: {
    base: 'http://139.198.13.191:9100'
  },
  Grpc: {
    ws: 'ws://139.198.13.191:9200/api/access/ws'
  },
  OAuth2: {
    server: 'http://139.198.13.191:9300',
    clientId: '102'
  },
  FS: {
    server: 'http://139.198.13.191:9400'
  },
  Kafka: {
    server: 'http://139.198.13.191:9500',
    tenantId: '5a71f99bf7f331c05f5c4272'
  },
  IOT: {
    issServer: 'http://139.198.13.191:8100',
    province: {
      _id: {
        $oid: '530000000000530000000000'
      },
      level: 2,
      name: '云南',
      code: '530000000000',
      center: {
        lat: 24.267,
        lng: 101.7554
      }
    }
  },
  // 动力视讯代理服务的配置参数
  PvServer: {
    server: 'http://pv.dev.agrithings.cn:8080'
  }
}
