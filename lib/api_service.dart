import 'package:dio/dio.dart';

class ApiService {
  static Dio dio = Dio();
  static String baseUrl = "https://hp-api.onrender.com/api/";

  static dynamic getData({required String endPoint}) async {
    final response = await dio.get("$baseUrl$endPoint");

    return response.data;
  }
}
