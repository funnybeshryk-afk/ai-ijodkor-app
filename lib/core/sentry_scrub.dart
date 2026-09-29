import 'package:sentry_flutter/sentry_flutter.dart';

/// Strips children's personal data from Sentry events before they leave the
/// device (used as `beforeSend` / `beforeBreadcrumb` in monitoring.dart).
///
/// Removed: the user, `extra`, request details (headers, cookies, body,
/// query), the device name, local context such as Flutter's widget-tree
/// dump (it can contain on-screen text: names, answers), and every
/// breadcrumb except navigation and HTTP. Masked in the remaining text:
/// e-mail addresses and phone numbers.
final _email = RegExp(
  r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
  caseSensitive: false,
);

// 9–15 digits, optionally with +, spaces, dashes or brackets between them.
final _phone = RegExp(r'\+?\d(?:[\s\-()]*\d){8,14}');

const _keptContexts = {
  'device',
  'os',
  'app',
  'runtime',
  'runtimes',
  'culture',
  'trace',
  'gpu',
};
const _keptBreadcrumbs = {'navigation', 'http'};

String maskText(String text) =>
    text.replaceAll(_email, '[email]').replaceAll(_phone, '[phone]');

String _maskUrl(String url) {
  final cut = url.indexOf(RegExp(r'[?#]'));
  return maskText(cut == -1 ? url : url.substring(0, cut));
}

SentryEvent scrubEvent(SentryEvent event, Hint hint) {
  event.user = null;
  // Deprecated, but plugins may still fill it.
  // ignore: deprecated_member_use
  event.extra = null;
  event.serverName = null;

  final request = event.request;
  if (request != null) {
    final url = request.url;
    event.request = SentryRequest(
      method: request.method,
      url: url == null ? null : _maskUrl(url),
    );
  }

  event.contexts.removeWhere((key, _) => !_keptContexts.contains(key));
  event.contexts.device?.name = null;

  final message = event.message;
  if (message != null) {
    event.message = SentryMessage(maskText(message.formatted));
  }

  for (final exception in event.exceptions ?? const <SentryException>[]) {
    final value = exception.value;
    if (value != null) exception.value = maskText(value);
  }

  event.breadcrumbs = [
    for (final b in event.breadcrumbs ?? const <Breadcrumb>[])
      ?scrubBreadcrumb(b, hint),
  ];
  return event;
}

Breadcrumb? scrubBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
  if (breadcrumb == null || !_keptBreadcrumbs.contains(breadcrumb.category)) {
    return null;
  }
  final data = breadcrumb.data ?? const <String, dynamic>{};
  final kept = <String, dynamic>{
    for (final key in const ['method', 'status_code', 'from', 'to', 'url'])
      if (data[key] != null)
        key: data[key] is String ? _maskUrl(data[key] as String) : data[key],
  };
  final message = breadcrumb.message;
  return Breadcrumb(
    category: breadcrumb.category,
    type: breadcrumb.type,
    level: breadcrumb.level,
    timestamp: breadcrumb.timestamp,
    message: message == null ? null : maskText(message),
    data: kept,
  );
}
