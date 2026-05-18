import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Login gagal');
    }

    return UserModel.fromJson(body['data']);
  }
}