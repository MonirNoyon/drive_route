import 'dart:async';
import 'package:car_routing_application/config/api_client/model/common_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'model/app_status_code.dart';
import 'api_interceptor.dart';
import 'model/upload_file_model.dart';


class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
    baseUrl: "",
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    validateStatus: (status) => status != null && status < 510,
  )) {
    _dio.interceptors.add(CustomInterceptors());
  }

  Future<Either<CommonResponse, T>> handleRequest<T>({
    required String endPoint,
    required RequestType method,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    bool isCustomUrl=false,
    List<UploadFileModel> uploadFile = const [],
    T Function(Map<String, dynamic> json)? fromJson,
    Function(double)? onProgressFileUpload,
  }) async {
    try {
      Response response;
      String url = _dio.options.baseUrl+endPoint;
      if(isCustomUrl){
        url=endPoint;
      }
      if (method == RequestType.GET) {
        response = await _getRequest(endPoint: url, queryParams: queryParams);
      } else if (method == RequestType.POST) {
        response = await _postRequest(endPoint: url, body: body ?? {}, queryParams: queryParams);
      } else if (method == RequestType.DELETE) {
        response = await _deleteRequest(endPoint: url, body: body ?? {}, queryParams: queryParams);
      } else if (method == RequestType.PUT) {
        response = await _putRequest(endPoint: url, body: body ?? {}, queryParams: queryParams);
      } else if (method == RequestType.PATCH) {
        response = await _patchRequest(endPoint: url, body: body ?? {}, queryParams: queryParams);
      } else if(method == RequestType.MULTIPART){
        response = await _postRequestMultipart(
          endPoint: url,
          body: body ?? {},
          uploadedFile: uploadFile,
          onProgress: (value){
            if(onProgressFileUpload != null){
              onProgressFileUpload(value);
            }
          }
        );
      }
      else {
        throw Exception("Unsupported Request Type");
      }
      return parseResponse(response: response,fromJson: fromJson);
    } catch (e) {
      if(e is DioException){
        if(e.type == DioExceptionType.connectionError){
          return Left(CommonResponse(statusMessage: "No Internet Connection"));
        }
        return Left(CommonResponse(statusCode: e.response?.statusCode ?? 0,statusMessage: e.response?.statusMessage ?? "Something went wrong"));
      }
      return Left(CommonResponse(statusCode: 0,statusMessage: e.toString()));
    }
  }

  Future<Either<CommonResponse,T>> parseResponse<T>({
    required Response response,
    T Function(Map<String, dynamic> json)? fromJson
})async{
    try{
      String message = _formatErrors(response.data);
      switch(response.statusCode){
        case AppStatusCode.success:
        case AppStatusCode.created:
        case AppStatusCode.updated:
        case AppStatusCode.deleted:
          if(fromJson != null){
            return right(fromJson(response.data));
          }else{
            return right(response.data);
          }
        case AppStatusCode.badRequest:
        case AppStatusCode.inValidRequest:
          return left(CommonResponse(statusMessage: message.isNotEmpty ? message : "Invalid Request"));
        case AppStatusCode.entityTooLarge:
          return left(CommonResponse(statusMessage: message.isNotEmpty ? message : "Your Request Entity is Too Large."));
        case AppStatusCode.severError:
          return left(CommonResponse(statusMessage: message.isNotEmpty ? message : "Internal Server Error"));
        case AppStatusCode.notFound:
          return left(CommonResponse(statusMessage: message.isNotEmpty ? message : "Path Not Found"));
          default:
            return left(CommonResponse(statusMessage: message.isNotEmpty ? message : "Something went wrong"));
      }
    }catch(e){
      return left(CommonResponse(statusCode: 0,statusMessage: e.toString()));
    }
  }

  Future<Response> _getRequest({
    required String endPoint,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.get(endPoint, queryParameters: queryParams);
  }

  Future<Response> _postRequest({
    required String endPoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.post(endPoint, data: body,queryParameters: queryParams);
  }

  Future<Response> _deleteRequest({
    required String endPoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.delete(endPoint, data: body,queryParameters: queryParams);
  }

  Future<Response> _putRequest({
    required String endPoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.put(endPoint, data: body,queryParameters: queryParams);
  }

  Future<Response> _patchRequest({
    required String endPoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.patch(endPoint, data: body,queryParameters: queryParams);
  }

  Future<Response> _postRequestMultipart({
    required String endPoint,
    required Map<String, dynamic> body,
    List<UploadFileModel> uploadedFile = const [],
    required Function(double) onProgress,
  }) async {
    final formData = FormData.fromMap({
      ...body,
      for (var upload in uploadedFile)
        upload.fileName: await MultipartFile.fromFile(
          upload.file.path,
          filename: upload.file.path.split('/').last,
          contentType: DioMediaType('multipart','form-data'),
        ),
    });

    return await _dio.post(
      endPoint,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (total != 0) {
          onProgress((sent * 100) / total);
        }
      },
    );
  }

   String _formatErrors(Map<String, dynamic> errors) {
    String errorMessage = '';
    if(!errors.containsKey("errors") && errors.containsKey("message")){
      errorMessage = errors["message"];
      return errorMessage;
    }
    if(errors.containsKey("errors")){
      if (errors["errors"] is List && errors["errors"].length == 1) {
        errors["errors"] = errors["errors"][0];
      }
      errors["errors"].forEach((key, value) {
        errorMessage += '-> $value\n';
      });
    }
    return  errorMessage;
  }

}
