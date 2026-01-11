import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

/// Service for handling OAuth callbacks on desktop platforms using a local HTTP server
class OAuthCallbackServer {
  HttpServer? _server;
  Completer<Map<String, String>>? _completer;
  int? _port;
  String? _successHtmlTemplate;
  String? _errorHtmlTemplate;

  /// Load HTML templates from Flutter assets
  Future<void> _loadTemplates() async {
    if (_successHtmlTemplate != null && _errorHtmlTemplate != null) {
      return; // Already loaded
    }

    _successHtmlTemplate = await rootBundle.loadString(
      'assets/oauth_templates/success.html',
    );
    _errorHtmlTemplate = await rootBundle.loadString(
      'assets/oauth_templates/error.html',
    );
  }

  /// Start the local HTTP server
  /// Returns the callback URL and a Future that completes with the callback URL parameters
  Future<({String callbackUrl, Future<Map<String, String>> callbackFuture})>
  startServer({int? port}) async {
    if (_server != null) {
      throw Exception('Server is already running');
    }

    _completer = Completer<Map<String, String>>();

    // Use provided port or default to 3000, try to find available port if default is in use
    _port = port ?? await _findAvailablePort(startPort: 3000);

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _port!);

    // Handle requests
    _server!.listen((HttpRequest request) {
      _handleRequest(request);
    });

    final callbackUrl = getCallbackUrl();
    return (callbackUrl: callbackUrl, callbackFuture: _completer!.future);
  }

  /// Get the callback URL for OAuth redirect
  String getCallbackUrl() {
    if (_port == null) {
      throw Exception('Server not started');
    }
    return 'http://127.0.0.1:$_port/auth/callback';
  }

  /// Get the current port
  int? get port => _port;

  /// Handle incoming HTTP requests
  void _handleRequest(HttpRequest request) {
    final uri = request.uri;

    if (uri.path == '/auth/callback') {
      // Extract query parameters
      final params = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        params[key] = value;
      });

      // Check for error in callback
      final hasError = params.containsKey('error');

      // Send appropriate page (async to load templates)
      _sendResponse(request, hasError, params['error'] ?? 'Unknown error');

      // Complete the future with the parameters
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.complete(params);
      }
    } else {
      // 404 for other paths
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
    }
  }

  /// Send HTML response (async to load templates from assets)
  Future<void> _sendResponse(
    HttpRequest request,
    bool hasError,
    String error,
  ) async {
    final html = hasError
        ? await _getErrorHtml(error)
        : await _getSuccessHtml();

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html)
      ..close();
  }

  /// Stop the server
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _port = null;
      _completer = null;
    }
  }

  /// Find an available port starting from 3000
  Future<int> _findAvailablePort({
    int startPort = 3000,
    int maxAttempts = 10,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final port = startPort + i;
      try {
        final server = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          port,
        );
        await server.close();
        return port;
      } catch (e) {
        // Port is in use, try next one
        continue;
      }
    }
    throw Exception('Could not find an available port');
  }

  /// Get HTML for error page - matches Material 3 design
  Future<String> _getErrorHtml(String error) async {
    await _loadTemplates();
    final escapedError = _escapeHtml(error);
    return _errorHtmlTemplate!.replaceAll('{{ERROR_MESSAGE}}', escapedError);
  }

  /// Get HTML for success page - matches Material 3 design
  Future<String> _getSuccessHtml() async {
    await _loadTemplates();
    return _successHtmlTemplate!;
  }

  /// Escape HTML special characters
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
