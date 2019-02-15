package com.cheyun.mylocation;

import android.Manifest;
import android.app.Activity;
import android.app.Service;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.support.v4.app.ActivityCompat;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.Poi;
//import com.baidu.mapapi.SDKInitializer;

import com.cheyun.mylocation.service.LocationService;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * MyLocationPlugin
 */
public class MyLocationPlugin implements MethodCallHandler, StreamHandler {

  private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

  static private LocationService locationService;
  private PluginRegistry.RequestPermissionsResultListener mPermissionsResultListener;

  private EventSink events;
  private Result result;

  private final Activity activity;

  MyLocationPlugin(Activity activity) {
    Log.d("MyLocationPlugin", "MyLocationPlugin");
    this.activity = activity;

    createPermissionsResultListener();
    initBDLocation();
//    createLocationRequest();
  }

  public PluginRegistry.RequestPermissionsResultListener getPermissionsResultListener() {
    return mPermissionsResultListener;
  }

  private void createPermissionsResultListener() {
    mPermissionsResultListener = new PluginRegistry.RequestPermissionsResultListener() {
      @Override
      public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE && permissions.length == 1 && permissions[0].equals(Manifest.permission.ACCESS_FINE_LOCATION)) {
          if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            if (result != null) {
              getLocation(result);
            } else if (events != null) {
              getLocation(null);
            }
          } else {
            if (!shouldShowRequestPermissionRationale()) {
              if (result != null) {
                result.error("PERMISSION_DENIED_NEVER_ASK", "Location permission denied forever- please open app settings", null);
              } else if (events != null) {
                events.error("PERMISSION_DENIED_NEVER_ASK", "Location permission denied forever - please open app settings", null);
                events = null;
              }
            } else {
              if (result != null) {
                result.error("PERMISSION_DENIED", "Location permission denied", null);
              } else if (events != null) {
                events.error("PERMISSION_DENIED", "Location permission denied", null);
                events = null;
              }
            }
          }
          return true;
        }

        return false;
      }
    };
  }

  private void initBDLocation() {
    Log.d("MyLocationPlugin", "initBDLocation");
    locationService = new LocationService(activity.getApplication());

    locationService.registerListener(mListener);
    //注册监听

    locationService.setLocationOption(locationService.getDefaultLocationClientOption());


  }

  void getLocation(Result result) {
    Log.d("MyLocationPlugin", "getLocation");
    this.result = result;
    // -----------location config ------------
    //获取locationservice实例，建议应用中只初始化1个location实例，然后使用，可以参考其他示例的activity，都是通过此种方式获取locationservice实例的

    if (!checkPermissions()) {
      requestPermissions();
      return;
    }

    initBDLocation();
    locationService.start();// 定位SDK
    // start之后会默认发起一次定位请求，开发者无须判断isstart并主动调用request

  }

  /*****
   *
   * 定位结果回调，重写onReceiveLocation方法，可以直接拷贝如下代码到自己工程中修改
   *
   */
  private BDAbstractLocationListener mListener = new BDAbstractLocationListener() {

    @Override
    public void onReceiveLocation(BDLocation location) {
      // TODO Auto-generated method stub

      Log.d("MyLocationPlugin", "onReceiveLocation");

      if (null != location && location.getLocType() != BDLocation.TypeServerError) {
        HashMap<String, Double> map = new HashMap<String, Double>();

        StringBuffer sb = new StringBuffer(256);
        sb.append("time : ");
        /**
         * 时间也可以使用systemClock.elapsedRealtime()方法 获取的是自从开机以来，每次回调的时间；
         * location.getTime() 是指服务端出本次结果的时间，如果位置不发生变化，则时间不变
         */
        sb.append(location.getTime());
        sb.append("\nlocType : ");// 定位类型
        sb.append(location.getLocType());
        sb.append("\nlocType description : ");// *****对应的定位类型说明*****
        sb.append(location.getLocTypeDescription());
        sb.append("\nlatitude : ");// 纬度
        sb.append(Double.toString(location.getLatitude()));
        sb.append("\nlontitude : ");// 经度
        sb.append(Double.toString(location.getLongitude()));

        map.put("longitude", location.getLongitude());
        map.put("latitude", location.getLatitude());

        sb.append("\nradius : ");// 半径
        sb.append(location.getRadius());
        sb.append("\nCountryCode : ");// 国家码
        sb.append(location.getCountryCode());
        sb.append("\nCountry : ");// 国家名称
        sb.append(location.getCountry());
        sb.append("\ncitycode : ");// 城市编码
        sb.append(location.getCityCode());
        sb.append("\ncity : ");// 城市
        sb.append(location.getCity());
        sb.append("\nDistrict : ");// 区
        sb.append(location.getDistrict());
        sb.append("\nStreet : ");// 街道
        sb.append(location.getStreet());
        sb.append("\naddr : ");// 地址信息
        sb.append(location.getAddrStr());
        sb.append("\nUserIndoorState: ");// *****返回用户室内外判断结果*****
        sb.append(location.getUserIndoorState());
        sb.append("\nDirection(not all devices have value): ");
        sb.append(location.getDirection());// 方向
        sb.append("\nlocationdescribe: ");
        sb.append(location.getLocationDescribe());// 位置语义化信息
        sb.append("\nPoi: ");// POI信息
        if (location.getPoiList() != null && !location.getPoiList().isEmpty()) {
          for (int i = 0; i < location.getPoiList().size(); i++) {
            Poi poi = (Poi) location.getPoiList().get(i);
            sb.append(poi.getName() + ";");
          }
        }
        if (location.getLocType() == BDLocation.TypeGpsLocation) {// GPS定位结果
          sb.append("\nspeed : ");
          sb.append(location.getSpeed());// 速度 单位：km/h
          sb.append("\nsatellite : ");
          sb.append(location.getSatelliteNumber());// 卫星数目
          sb.append("\nheight : ");
          sb.append(location.getAltitude());// 海拔高度 单位：米
          sb.append("\ngps status : ");
          sb.append(location.getGpsAccuracyStatus());// *****gps质量判断*****
          sb.append("\ndescribe : ");
          sb.append("gps定位成功");
        } else if (location.getLocType() == BDLocation.TypeNetWorkLocation) {// 网络定位结果
          // 运营商信息
          if (location.hasAltitude()) {// *****如果有海拔高度*****
            sb.append("\nheight : ");
            sb.append(location.getAltitude());// 单位：米
          }
          sb.append("\noperationers : ");// 运营商信息
          sb.append(location.getOperators());
          sb.append("\ndescribe : ");
          sb.append("网络定位成功");
        } else if (location.getLocType() == BDLocation.TypeOffLineLocation) {// 离线定位结果
          sb.append("\ndescribe : ");
          sb.append("离线定位成功，离线定位结果也是有效的");
        } else if (location.getLocType() == BDLocation.TypeServerError) {
          sb.append("\ndescribe : ");
          sb.append("服务端网络定位失败，可以反馈IMEI号和大体定位时间到loc-bugs@baidu.com，会有人追查原因");
        } else if (location.getLocType() == BDLocation.TypeNetWorkException) {
          sb.append("\ndescribe : ");
          sb.append("网络不同导致定位失败，请检查网络是否通畅");
        } else if (location.getLocType() == BDLocation.TypeCriteriaException) {
          sb.append("\ndescribe : ");
          sb.append("无法获取有效定位依据导致定位失败，一般是由于手机的原因，处于飞行模式下一般会造成这种结果，可以试着重启手机");
        }
        Log.d("MyLocationPlugin", sb.toString());
        Log.d("MyLocationPlugin", map.toString());

        if (result != null) {
          result.success(map);
        }
      }

      locationService.unregisterListener(mListener);
      locationService.stop();
    }

  };

  @Override
  public void onListen(Object arguments, final EventSink eventsSink) {
    events = eventsSink;
    if (!checkPermissions()) {
      requestPermissions();
      return;
    }
//    getLastLocation(null);
    /**
     * Requests location updates from the FusedLocationApi. Note: we don't call this unless location
     * runtime permission has been granted.
     */

  }

  @Override
  public void onCancel(Object arguments) {
    locationService.stop();
//    events = null;
  }

  /**
   * Return the current state of the permissions needed.
   */
  private boolean checkPermissions() {
    int permissionState = ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION);
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }

  private void requestPermissions() {
    ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
            REQUEST_PERMISSIONS_REQUEST_CODE);
  }

  private boolean shouldShowRequestPermissionRationale() {
    return ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_FINE_LOCATION);
  }


  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    Log.d("MyLocationPlugin", "registerWith");
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "my_location");
    MyLocationPlugin locationWithMethodChannel = new MyLocationPlugin(registrar.activity());
    channel.setMethodCallHandler(locationWithMethodChannel);
    registrar.addRequestPermissionsResultListener(locationWithMethodChannel.getPermissionsResultListener());

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getLocation":
        getLocation(result);
        break;
      default:
        result.notImplemented();
    }
  }
}
