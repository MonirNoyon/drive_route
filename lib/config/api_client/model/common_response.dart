import 'package:dartz/dartz.dart';

typedef EitherResponse<T> = Future<Either<CommonResponse, T>>;
typedef ResultResponse<T> = Either<CommonResponse, T>;

enum RequestType { GET, POST, PUT, PATCH, DELETE, MULTIPART}

class CommonResponse{
  int statusCode;
  bool status;
  String statusMessage;

  CommonResponse({
    this.statusCode = 0,
    this.status = false,
    required this.statusMessage,
});

  factory CommonResponse.fromJson(Map<String, dynamic> json) => CommonResponse(
    statusCode: json["status_code"] ?? 0,
    status: json["status"],
    statusMessage: json["message"] ?? "",
  );

  Map<String, dynamic> toJson()=> {
    "status_code": statusCode,
    "status": status,
    "message": statusMessage,
  };

}