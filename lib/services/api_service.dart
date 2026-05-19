import 'dart:convert';
import 'dart:io';
import 'dart:async';

/// API 服务类 - 调用云端大模型生成彩虹屁
class ApiService {
  // 智谱AI端点
  static const String _baseUrl = 'open.bigmodel.cn';
  
  // API Key - 从环境变量读取（通过 --dart-define 注入）
  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF',
  );
  
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  
  /// 生成彩虹屁
  static Future<String> generateRainbowPuff({
    String identity = '小学生',
    String event = '认真学习',
    int minWords = 10,
    int maxWords = 50,
  }) async {
    print('[ApiService] === Starting API call ===');
    print('[ApiService] Key prefix: ${_apiKey.substring(0, 8)}...');
    print('[ApiService] identity=$identity event=$event');
    
    // 构建提示词
    final prompt = _buildPrompt(identity, event, minWords, maxWords);
    
    // 构建请求体
    final requestBody = jsonEncode({
      'model': 'glm-4-flash',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.9,
      'max_tokens': 100,
    });
    
    print('[ApiService] Request body length: ${requestBody.length} chars');
    
    // 重试逻辑
    Exception? lastError;
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('[ApiService] Attempt $attempt/$_maxRetries...');
        return await _makeRequest(requestBody);
      } catch (e, stack) {
        lastError = _wrapError(e, attempt, stack);
        print('[ApiService] Attempt $attempt failed: $lastError');
        if (attempt < _maxRetries) {
          print('[ApiService] Retrying in ${attempt * 2}s...');
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
    
    print('[ApiService] All $_maxRetries attempts failed');
    throw lastError!;
  }
  
  /// 执行单次 HTTP 请求（使用 dart:io HttpClient）
  static Future<String> _makeRequest(String requestBody) async {
    final client = HttpClient();
    client.connectionTimeout = _timeout;
    
    try {
      final uri = Uri.https(_baseUrl, '/api/paas/v4/chat/completions');
      print('[ApiService] POST $uri');
      
      final request = await client.postUrl(uri).timeout(Duration(seconds: 10));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.write(requestBody);
      
      final response = await request.close().timeout(_timeout);
      final statusCode = response.statusCode;
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('[ApiService] Status: $statusCode');
      print('[ApiService] Response: ${responseBody.substring(0, responseBody.length > 300 ? 300 : responseBody.length)}');
      
      if (statusCode == 200) {
        final data = jsonDecode(responseBody);
        final content = data['choices'][0]['message']['content'] as String;
        print('[ApiService] SUCCESS');
        return content.trim();
      }
      
      // 非200响应
      String errorMsg = 'API 错误 ($statusCode)';
      try {
        final err = jsonDecode(responseBody);
        final serverMsg = err['error']?['message'];
        if (serverMsg != null) errorMsg += ': $serverMsg';
      } catch (_) {}
      throw Exception(errorMsg);
      
    } finally {
      client.close();
    }
  }
  
  /// 包装错误信息（包含类型、堆栈）
  static Exception _wrapError(dynamic e, int attempt, StackTrace stack) {
    final typeName = e.runtimeType.toString();
    final detail = e.toString().replaceAll('\n', ' | ');
    final stackLines = stack.toString().split('\n').take(3).join(' -> ');
    print('[ApiService] Error type: $typeName');
    print('[ApiService] Error detail: $detail');
    print('[ApiService] Stack: $stackLines');
    
    if (e is SocketException) {
      return Exception('网络连接失败: ${e.message} (地址: ${e.address?.host}, 端口: ${e.port})');
    }
    if (e is HandshakeException) {
      return Exception('SSL握手失败: ${e.message}');
    }
    if (e is TlsException) {
      return Exception('TLS证书错误: ${e.message}');
    }
    if (e is TimeoutException) {
      return Exception('请求超时 (${_timeout.inSeconds}秒)');
    }
    if (e is HttpException) {
      return Exception('HTTP协议错误: ${e.message}');
    }
    return Exception('[$typeName] $detail');
  }
  
  /// 构建提示词
  static String _buildPrompt(String identity, String event, int minWords, int maxWords) {
    return '''
请扮演一位极度热情、充满感染力的小学老师/家长，对一名【$identity】在【$event】这件事上进行"疯狂级别"的鼓励和表扬。

要求：
1. 语气夸张、亢奋，像看到偶像一样激动
2. 大量使用感叹号及表情符号（✨🚀🌟😱💪🎉等）
3. 需包含具体赞美点（如"认真""声音清晰""坚持""进步快"等）
4. 使用比喻或夸张修辞（如"比吃了一百颗糖还甜""像火箭一样进步"）
5. 重复强调"太棒了""厉害""最棒"等词，可叠加重复
6. 结尾要有强烈的鼓励动作（如"疯狂打call""给你一万个赞"）
7. 字数控制在$minWords-$maxWords字之间（随机）

请直接输出表扬内容，不要有任何前缀或解释。
''';
  }
  
  /// 测试 API 连接
  static Future<bool> testConnection() async {
    try {
      await generateRainbowPuff(identity: '测试', event: '测试', minWords: 10, maxWords: 20);
      return true;
    } catch (e) {
      print('[ApiService] Connection test failed: $e');
      return false;
    }
  }
}