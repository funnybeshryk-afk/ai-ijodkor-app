import 'dart:convert';

import 'package:ai_ijodkor/core/sentry_scrub.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('maskText', () {
    test('masks e-mails and phone numbers', () {
      expect(maskText('login aziz.karimov@ijodkor.uz'), 'login [email]');
      expect(maskText('+998 90 123 45 67 band'), '[phone] band');
      expect(maskText('Key (phone)=(901234567)'), 'Key (phone)=([phone])');
    });

    test('keeps short numbers', () {
      expect(
        maskText("350000 so'm, 3-dars, 2026-09"),
        "350000 so'm, 3-dars, 2026-09",
      );
    });
  });

  SentryEvent event() => SentryEvent(
    message: SentryMessage('Failed for aziz@example.com'),
    user: SentryUser(
      id: 'u1',
      email: 'aziz@example.com',
      username: 'Aziz Karimov',
    ),
    serverName: 'host',
    request: SentryRequest(
      method: 'POST',
      url: 'https://x.supabase.co/rest/v1/homework?student_id=eq.1&name=Aziz',
      cookies: 'sb=secret',
      headers: {'Authorization': 'Bearer secret'},
      data: {'content_text': 'Mening uy vazifam'},
    ),
    contexts: Contexts(
      device: SentryDevice(name: "Aziz's phone", model: 'Pixel'),
    )..['flutter_error_details'] = {'information': 'Text("Aziz Karimov")'},
    exceptions: [
      SentryException(
        type: 'PostgrestException',
        value: 'duplicate key (email)=(ota.ona@mail.uz), phone +998901112233',
      ),
    ],
    breadcrumbs: [
      Breadcrumb(category: 'console', message: 'Aziz Karimov answered for'),
      Breadcrumb(category: 'ui.click', message: 'Aziz'),
      Breadcrumb(
        category: 'navigation',
        data: {'from': '/', 'to': '/lesson/1?x=Aziz'},
      ),
      Breadcrumb(
        category: 'http',
        data: {
          'method': 'POST',
          'url': '/rest/v1/x?email=a@b.uz',
          'status_code': 500,
          'body': 'secret',
        },
      ),
    ],
  );

  test('drops user, request details, device name and unknown contexts', () {
    final e = scrubEvent(event(), Hint());
    expect(e.user, isNull);
    expect(e.serverName, isNull);
    expect(e.request?.method, 'POST');
    expect(e.request?.url, 'https://x.supabase.co/rest/v1/homework');
    expect(e.request?.cookies, isNull);
    expect(e.request?.headers, isEmpty);
    expect(e.request?.data, isNull);
    expect(e.contexts.device?.name, isNull);
    expect(e.contexts.device?.model, 'Pixel');
    expect(e.contexts.containsKey('flutter_error_details'), isFalse);
  });

  test('masks messages and exception values', () {
    final e = scrubEvent(event(), Hint());
    expect(e.message?.formatted, 'Failed for [email]');
    expect(
      e.exceptions?.single.value,
      'duplicate key (email)=([email]), phone [phone]',
    );
  });

  test('keeps only navigation and http breadcrumbs without query or body', () {
    final crumbs = scrubEvent(event(), Hint()).breadcrumbs!;
    expect(crumbs.map((b) => b.category), ['navigation', 'http']);
    expect(crumbs[0].data, {'from': '/', 'to': '/lesson/1'});
    expect(crumbs[1].data, {
      'method': 'POST',
      'url': '/rest/v1/x',
      'status_code': 500,
    });
  });

  test('no personal value survives serialization', () {
    final json = jsonEncode(scrubEvent(event(), Hint()).toJson());
    for (final secret in [
      'Aziz',
      'aziz@',
      'ota.ona',
      '998901112233',
      'vazifam',
      'secret',
    ]) {
      expect(json.contains(secret), isFalse, reason: secret);
    }
  });

  test('drops console and UI breadcrumbs', () {
    expect(scrubBreadcrumb(Breadcrumb(category: 'console'), Hint()), isNull);
    expect(scrubBreadcrumb(Breadcrumb(category: 'ui.click'), Hint()), isNull);
    expect(scrubBreadcrumb(null, Hint()), isNull);
  });
}
