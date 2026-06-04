import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SnifferViewState {
  const SnifferViewState({
    this.currentUrl = '',
    this.pageTitle,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.lastError,
  });

  final String currentUrl;
  final String? pageTitle;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final String? lastError;

  SnifferViewState copyWith({
    String? currentUrl,
    String? pageTitle,
    bool? isLoading,
    bool? canGoBack,
    bool? canGoForward,
    String? lastError,
    bool clearError = false,
  }) {
    return SnifferViewState(
      currentUrl: currentUrl ?? this.currentUrl,
      pageTitle: pageTitle ?? this.pageTitle,
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

abstract class SnifferViewController {
  ValueListenable<SnifferViewState> get stateListenable;
  Widget buildView();
  Future<void> loadUrl(String url);
  Future<void> reload();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> dispose();
}

class SnifferService {
  const SnifferService();

  SnifferViewController createController() => WebViewSnifferController();
}

class WebViewSnifferController implements SnifferViewController {
  WebViewSnifferController()
      : _webViewController = WebViewController(),
        _state = ValueNotifier<SnifferViewState>(const SnifferViewState()) {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _setState(
              _state.value.copyWith(
                currentUrl: url,
                isLoading: true,
                clearError: true,
              ),
            );
          },
          onPageFinished: (url) async {
            await _refreshNavigationState(currentUrl: url, isLoading: false);
          },
          onWebResourceError: (error) {
            _setState(
              _state.value.copyWith(
                isLoading: false,
                lastError: error.description,
              ),
            );
          },
        ),
      );
  }

  final WebViewController _webViewController;
  final ValueNotifier<SnifferViewState> _state;

  @override
  ValueListenable<SnifferViewState> get stateListenable => _state;

  @override
  Widget buildView() => WebViewWidget(controller: _webViewController);

  @override
  Future<void> loadUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      _setState(
        _state.value.copyWith(
          lastError: '请输入有效的 http 或 https 地址',
          isLoading: false,
        ),
      );
      return;
    }
    await _webViewController.loadRequest(uri);
  }

  @override
  Future<void> reload() => _webViewController.reload();

  @override
  Future<void> goBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      await _refreshNavigationState();
    }
  }

  @override
  Future<void> goForward() async {
    if (await _webViewController.canGoForward()) {
      await _webViewController.goForward();
      await _refreshNavigationState();
    }
  }

  @override
  Future<void> dispose() async {
    _state.dispose();
  }

  Future<void> _refreshNavigationState({String? currentUrl, bool? isLoading}) async {
    final canGoBack = await _webViewController.canGoBack();
    final canGoForward = await _webViewController.canGoForward();
    final title = await _webViewController.getTitle();
    _setState(
      _state.value.copyWith(
        currentUrl: currentUrl ?? _state.value.currentUrl,
        pageTitle: title,
        isLoading: isLoading ?? _state.value.isLoading,
        canGoBack: canGoBack,
        canGoForward: canGoForward,
        clearError: true,
      ),
    );
  }

  void _setState(SnifferViewState nextState) {
    if (_state.value == nextState) {
      return;
    }
    _state.value = nextState;
  }
}
