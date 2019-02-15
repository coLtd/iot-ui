import { env } from '@vehiclecloud/commons/util/config-helper'

export default {
  Mongo: {
    iss: {
      database: env('$AG_MONGO_ISS_DATABASE', 'iov'),
      base: env('$AG_MONGO_ISS_BASE', 'http://47.104.162.6:9000')
    },
    iot: {
      database: env('$AG_MONGO_IOT_DATABASE', 'iot'),
      base: env('$AG_MONGO_IOT_BASE', 'http://47.104.162.6:9000')
    }
  },
  Redis: {
    base: env('$AG_REDIS_BASE', 'http://47.104.162.6:9100')
  },
  Grpc: {
    ws: env('$AG_GRPC_WS', 'ws://47.104.162.6:9200/api/access/ws')
  },
  OAuth2: {
    server: env('$AG_OAUTH2_SERVER', 'http://47.104.162.6:9300'),
    clientId: env('$AG_OAUTH2_CLIENT_ID', 'iot-test')
  },
  FS: {
    server: env('$AG_FS_SERVER', 'http://47.104.162.6:9400')
  },
  Kafka: {
    server: env('$AG_KAFKA_SERVER', 'http://47.104.162.6:9500'),
    tenantId: env('$AG_KAFKA_TENANT_ID', '5a71f99bf7f331c05f5c4272')
  },
  IOT: {
    iotServer: env('$AG_IOT_SERVER', 'http://47.104.162.6:8200'),
    province: {
      _id: { $oid: env('$AG_IOT_PROVINCE_ID', '530000000000530000000000') },
      level: 2,
      name: env('$AG_IOT_PROVINCE_NAME', '云南'),
      code: env('$AG_IOT_PROVINCE_CODE', '530000000000'),
      center: { lat: env('$AG_IOT_PROVINCE_LAT', 24.267), lng: env('$AG_IOT_PROVINCE_LNG', 101.7554) }
    }
  },
    // 动力视讯代理服务的配置参数
  PvServer: {
    server: env('$AG_PV_SERVER', 'http://39.108.99.15:8080')
  }
}
