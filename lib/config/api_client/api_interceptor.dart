import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'model/app_status_code.dart';
import 'model/colored_logger.dart';

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('REQUEST[PARAMETERS] => ${options.queryParameters}');
    debugPrint('REQUEST[DATA] => ${options.data}');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'No internet connection',
            type: DioExceptionType.connectionError,
          ),
          true,
        );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler){
    if(kDebugMode){
      ColoredLogger.cyan.log("Response -> ${response.data}");
    }
    if(response.statusCode == AppStatusCode.unAuthorized){

    }
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    if(kDebugMode){
      ColoredLogger.red.log(err.response);
    }
    if(err.response?.statusCode == AppStatusCode.unAuthorized) {

    }
    super.onError(err, handler);
  }

}