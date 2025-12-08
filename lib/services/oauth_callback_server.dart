import 'dart:io';
import 'dart:async';

/// Service for handling OAuth callbacks on desktop platforms using a local HTTP server
class OAuthCallbackServer {
  HttpServer? _server;
  Completer<Map<String, String>>? _completer;
  int? _port;

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

      // Send appropriate page
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(
          hasError
              ? _getErrorHtml(params['error'] ?? 'Unknown error')
              : _getSuccessHtml(),
        )
        ..close();

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

  /// Get HTML for error page
  String _getErrorHtml(String error) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Error - GitScribe</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #f87171 0%, #dc2626 100%);
            color: #333;
        }
        .container {
            background: white;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 400px;
            width: 90%;
        }
        .error-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 1.5rem;
            background: #ef4444;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .error-icon::before {
            content: '✕';
            color: white;
            font-size: 48px;
            font-weight: bold;
        }
        h1 {
            font-size: 1.75rem;
            margin-bottom: 0.5rem;
            color: #1f2937;
        }
        p {
            color: #6b7280;
            font-size: 1rem;
            line-height: 1.5;
        }
        .error-message {
            margin-top: 1rem;
            padding: 1rem;
            background: #fef2f2;
            border-radius: 8px;
            color: #991b1b;
            font-size: 0.875rem;
        }
        .close-hint {
            margin-top: 1.5rem;
            font-size: 0.875rem;
            color: #9ca3af;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="error-icon"></div>
        <h1>Authentication Failed</h1>
        <p>There was an error during authentication.</p>
        <div class="error-message">${_escapeHtml(error)}</div>
        <p class="close-hint">You can close this window and try again.</p>
    </div>
    <script>
        // Auto-close after 5 seconds
        setTimeout(() => {
            window.close();
        }, 5000);
    </script>
</body>
</html>
''';
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

  /// Get HTML for success page
  String _getSuccessHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Successful - GitScribe</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
        }
        .container {
            background: white;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 400px;
            width: 90%;
        }
        .success-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 1.5rem;
            background: #10b981;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: scaleIn 0.5s ease-out;
        }
        .success-icon::before {
            content: '✓';
            color: white;
            font-size: 48px;
            font-weight: bold;
        }
        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }
        h1 {
            font-size: 1.75rem;
            margin-bottom: 0.5rem;
            color: #1f2937;
        }
        p {
            color: #6b7280;
            font-size: 1rem;
            line-height: 1.5;
        }
        .close-hint {
            margin-top: 1.5rem;
            font-size: 0.875rem;
            color: #9ca3af;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon"></div>
        <h1>Authentication Successful!</h1>
        <p>You have successfully authenticated with GitHub. You can close this window and return to GitScribe.</p>
        <p class="close-hint">This window will close automatically in a few seconds...</p>
    </div>
    <script>
        // Auto-close after 3 seconds
        setTimeout(() => {
            window.close();
        }, 3000);
    </script>
</body>
</html>
''';
  }
}
