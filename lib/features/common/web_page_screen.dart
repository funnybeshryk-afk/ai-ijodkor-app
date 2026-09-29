import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../core/locale_controller.dart';
import '../../core/platform_session.dart';
import '../../data/providers.dart';
import '../../core/theme.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';

/// Returns the platform auth cookies for the current session, refreshing
/// the session first when it is about to expire — so the web page does not
/// have to refresh it itself (that would rotate the refresh token the app
/// still holds).
final platformCookiesProvider =
    Provider<Future<Map<String, String>> Function()>(
      (ref) => () async {
        final client = ref.read(supabaseClientProvider);
        if (client == null) return const {};
        var session = client.auth.currentSession;
        if (session == null) return const {};
        final expiresAt = session.expiresAt;
        final soon =
            DateTime.now()
                .add(const Duration(minutes: 10))
                .millisecondsSinceEpoch ~/
            1000;
        if (expiresAt == null || expiresAt < soon) {
          session = (await client.auth.refreshSession()).session ?? session;
        }
        return PlatformSessionCookies.build(
          supabaseUrl: Env.supabaseUrl,
          sessionJson: session.toJson(),
        );
      },
    );

/// Full-screen WebView. With [withPlatformSession] the student's Supabase
/// session is handed to the platform as cookies, so trainers open signed
/// in, and in the app's language (`aiij_lang` cookie plus `?lang=`). Links
/// leaving [url]'s host open in the external browser.
class WebPageScreen extends ConsumerStatefulWidget {
  const WebPageScreen({
    super.key,
    required this.url,
    required this.title,
    this.withPlatformSession = false,
  });

  final Uri url;
  final String title;
  final bool withPlatformSession;

  @override
  ConsumerState<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends ConsumerState<WebPageScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          onNavigationRequest: (request) {
            final target = Uri.tryParse(request.url);
            final external =
                widget.withPlatformSession &&
                request.isMainFrame &&
                target != null &&
                target.host.isNotEmpty &&
                target.host != widget.url.host;
            if (external) {
              launchUrl(target, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    var url = widget.url;
    try {
      if (widget.withPlatformSession) {
        final lang = ref.read(localeControllerProvider).languageCode;
        url = PlatformSessionCookies.withLang(url, lang);
        final cookies = {
          ...await ref.read(platformCookiesProvider)(),
          PlatformSessionCookies.langCookie: lang == 'ru' ? 'ru' : 'uz',
        };
        final manager = WebViewCookieManager();
        await manager.clearCookies();
        for (final entry in cookies.entries) {
          await manager.setCookie(
            WebViewCookie(
              name: entry.key,
              value: entry.value,
              domain: widget.url.host,
            ),
          );
        }
      }
      await _controller.loadRequest(url);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.backLabel,
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.title, style: AppText.bodyStrong),
          actions: [
            IconButton(
              tooltip: l10n.openInBrowser,
              icon: const Icon(LucideIcons.externalLink),
              onPressed: () =>
                  launchUrl(widget.url, mode: LaunchMode.externalApplication),
            ),
          ],
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(AppSize.progressThin),
                  child: LinearProgressIndicator(value: _progress / 100),
                )
              : null,
        ),
        body: _failed
            ? MessageView(
                icon: LucideIcons.wifiOff,
                title: l10n.errorGeneric,
                actions: [
                  PrimaryButton(label: l10n.retryButton, onPressed: _load),
                ],
              )
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
