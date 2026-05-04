import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Attaches `X-Client-Version` header on every outgoing request.
///
/// The version string is read once at startup via [PackageInfo].
class ClientVersionInterceptor extends Interceptor {
  ClientVersionInterceptor(this._version);

  final String _version;

  /// Creates the interceptor, fetching the package version once.
  static Future<ClientVersionInterceptor> create() async {
    final info = await PackageInfo.fromPlatform();
    final version = '${info.version}+${info.buildNumber}';
    return ClientVersionInterceptor(version);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Client-Version'] = _version;
    handler.next(options);
  }
}
