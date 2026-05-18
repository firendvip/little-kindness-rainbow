import 'dart:convert';

/// 彩虹屁数据模型
class RainbowPuff {
  final String content;
  final DateTime timestamp;
  final String? event; // 具体要夸的事情（可选）
  final String? identity; // 身份（可选）
  
  RainbowPuff({
    required this.content,
    required this.timestamp,
    this.event,
    this.identity,
  });
  
  /// 从 JSON 创建
  factory RainbowPuff.fromJson(Map<String, dynamic> json) {
    return RainbowPuff(
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      event: json['event'] as String?,
      identity: json['identity'] as String?,
    );
  }
  
  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'event': event,
      'identity': identity,
    };
  }
  
  /// 从字符串创建（简单版本）
  factory RainbowPuff.fromString(String content) {
    return RainbowPuff(
      content: content,
      timestamp: DateTime.now(),
    );
  }
  
  @override
  String toString() {
    return 'RainbowPuff(content: $content, timestamp: $timestamp)';
  }
}
