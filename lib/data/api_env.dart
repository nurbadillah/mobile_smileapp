class ApiEnv {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static const String fileBaseUrl = String.fromEnvironment(
    'FILE_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );
}