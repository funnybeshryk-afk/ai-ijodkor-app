import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'env.dart';
import 'sentry_scrub.dart';

/// Runs the app, with Sentry error reporting only when `SENTRY_DSN` was
/// passed via `--dart-define`. Without it Sentry is never started.
///
/// Errors only: no performance tracing, no screenshots or widget-tree
/// attachments (view hierarchy is off by default), no default PII; every event and breadcrumb goes through
/// [scrubEvent] / [scrubBreadcrumb] first.
Future<void> runWithMonitoring(FutureOr<void> Function() appRunner) async {
  if (Env.sentryDsn.isEmpty) {
    await appRunner();
    return;
  }
  await SentryFlutter.init((options) {
    options.dsn = Env.sentryDsn;
    options.sendDefaultPii = false;
    options.tracesSampleRate = 0;
    options.attachScreenshot = false;
    options.attachThreads = false;
    options.beforeSend = scrubEvent;
    options.beforeBreadcrumb = scrubBreadcrumb;
  }, appRunner: appRunner);
}
