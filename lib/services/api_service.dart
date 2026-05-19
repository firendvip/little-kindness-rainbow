import 'dart:convert';
import 'package:http/http.dart' as http;

/// API 服务类 - 调用云端大模型生成彩虹屁
class ApiService {
  // TODO: 请替换为实际的 API 端点
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // API Key - 从环境变量读取（通过 --dart-define 注入）
  // 默认值：用户提供的 Key（用于本地测试）
  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF',
  );
  
  // 注意：构建时需要通过 --dart-define=API_KEY=your_key 注入
  // 例如：flutter build apk --dart-define=API_KEY=72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF
  
  /// 生成彩虹屁
  /// [identity] 身份（默认"小学生"）
  /// [event] 具体要夸的事情（默认"认真学习"）
  /// [minWords] 最小字数（默认10）
  /// [maxWords] 最大字数（默认50）
  /// 
  /// 可能抛出异常：
  /// - [ApiException] 包含错误信息
  static Future<String> generateRainbowPuff({
    String identity = '小学生',
    String event = '认真学习',
    int minWords = 10,
    int maxWords = 50,
  }) async {
    try {
      // 构建提示词
      final prompt = _buildPrompt(identity, event, minWords, maxWords);
      
      // 构建请求体
      final requestBody = jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.9,
        'max_tokens': 100,
      });
      
      // 发送请求
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: requestBody,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else if (response.statusCode == 401) {
        // 401: Unauthorized - API Key 无效或被删除
        throw ApiException('API Key 无效，请检查配置');
      } else if (response.statusCode == 429) {
        // 429: Too Many Requests - 额度用完或请求频率超限
        throw ApiException('使用额度已用完，请稍后再试 🌟');
      } else {
        throw ApiException('请求失败 (${response.statusCode}): ${response.body}');
      }
    } on ApiException {
      // 重新抛出 API 异常
      rethrow;
    } catch (e) {
      throw ApiException('网络错误: $e');
    }
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
      return false;
    }
  }
}
