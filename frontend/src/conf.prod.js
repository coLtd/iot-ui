export default {
  Mongo: {
    iss: {
      database: 'iov',
      base: 'http://mongo.dev.agrithings.cn:29000'
    },
    iot: {
      database: 'iot',
      base: 'http://mongo.dev.agrithings.cn:29000'
    }
  },
  Redis: {
    base: 'http://redis.dev.agrithings.cn:29100'
  },
  Grpc: {
    ws: 'ws://ac.dev.agrithings.cn:29200/api/access/ws'
  },
  OAuth2: {
    server: 'http://oauth2.dev.agrithings.cn:29300',
    clientId: '2'
  },
  FS: {
    server: 'http://file.dev.agrithings.cn:29400'
  },
  Kafka: {
    server: 'http://kafka.dev.agrithings.cn:29500',
    tenantId: '5a71f99bf7f331c05f5c4272'
  },
  IOT: {
    issServer: 'http://iss.dev.agrithings.cn:28100',
    province: {
      _id: { $oid: '530000000000530000000000' },
      level: 2,
      name: '云南',
      code: '530000000000',
      center: { lat: 24.267, lng: 101.7554 }
    }
  },
  // 动力视讯代理服务的配置参数
  PvServer: {
    server: 'http://pv.dev.agrithings.cn:8080'
  }
}
