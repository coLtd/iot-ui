export default {
  Mongo: {
    iss: {
      database: 'iov',
      base: 'http://mongo-rest.agrithings.cn'
    },
    iot: {
      database: 'iot',
      base: 'http://mongo-rest.agrithings.cn'
    }
  },
  Redis: {
    base: 'http://redis-rest.agrithings.cn'
  },
  Grpc: {
    ws: 'ws://access-websocket-server.agrithings.cn/api/access/ws'
  },
  OAuth2: {
    server: 'http://oauth2-server-api.agrithings.cn',
    clientId: '102'
  },
  FS: {
    server: 'http://file-server.agrithings.cn'
  },
  Kafka: {
    server: 'http://kafka-rest.agrithings.cn',
    tenantId: '5a71f99bf7f331c05f5c4272'
  },
  IOT: {
    issServer: 'http://iss.agrithings.cn',
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
    server: 'http://pv-server.agrithings.cn'
  }
}
