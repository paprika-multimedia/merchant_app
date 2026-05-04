import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/session.dart';

/// Attaches `Accept-Language: id|en` to every outgoing request.
///
/// Must be the FIRST interceptor in the chain (Spec §1.3).
class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final lang = _ref.read(localeProvider);
    options.headers['Accept-Language'] = lang;
    handler.next(options);
  }
}
