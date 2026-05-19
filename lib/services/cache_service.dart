import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// API 调用失败的特殊异常
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

/// 缓存服务类 - 管理20条彩虹屁缓存
class CacheService {
  static const String _cacheKey = 'rainbow_puff_cache';
  static const int _cacheSize = 20;
  
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();
  
  SharedPreferences? _prefs;
  
  /// 初始化缓存（首次启动时预生成20条通用版）
  Future<void> initCache() async {
    _prefs = await SharedPreferences.getInstance();
    
    final cache = _getCache();
    if (cache.isEmpty) {
      // 首次启动，预生成20条通用版
      await _preGenerateCache();
    }
  }
  
  /// 预生成20条通用版彩虹屁
  Future<void> _preGenerateCache() async {
    final List<String> cache = [];
    
    // 并行生成20条（提高效率）
    final futures = List.generate(_cacheSize, (_) => _generateOne());
    final results = await Future.wait(futures);
    
    cache.addAll(results.where((item) => item != null).cast<String>());
    await _saveCache(cache);
  }
  
  /// 生成一条彩虹屁（通用版）
  Future<String?> _generateOne() async {
    try {
      return await ApiService.generateRainbowPuff(
        identity: '小学生',
        event: '认真学习',
      );
    } catch (e) {
      // 生成失败，返回备用内容
      return _getFallbackPuff();
    }
  }
  
  /// 获取一条彩虹屁（从缓存中取）
  Future<String> getOne() async {
    final cache = _getCache();
    
    if (cache.isEmpty) {
      // 缓存为空（理论上不会发生），生成一条
      return await _generateOne() ?? _getFallbackPuff();
    }
    
    // 随机取一条
    cache.shuffle();
    final item = cache.removeAt(0);
    
    // 保存更新后的缓存
    await _saveCache(cache);
    
    // 后台补充一条新内容（不阻塞用户操作）
    _refillCache();
    
    return item;
  }
  
  /// 后台补充缓存（保持20条）
  Future<void> _refillCache() async {
    final cache = _getCache();
    
    if (cache.length < _cacheSize) {
      final newItem = await _generateOne();
      if (newItem != null) {
        cache.add(newItem);
        await _saveCache(cache);
      }
    }
  }
  
  /// 生成定制彩虹屁（用户输入特定事件）
  /// 
  /// [identity] 身份
  /// [event] 具体要夸的事情
  /// 
  /// 如果 API 调用失败，会抛出 [ApiException] 异常
  /// 调用者应该捕获此异常并显示友好提示
  Future<String> generateCustom({String identity = '小学生', required String event}) async {
    try {
      final puff = await ApiService.generateRainbowPuff(
        identity: identity,
        event: event,
      );
      
      // 后台补充一条通用版到缓存
      _refillCache();
      
      return puff;
    } on ApiException {
      // 重新抛出 API 异常，让 UI 层处理
      rethrow;
    } catch (e) {
      // 其他异常，包装成 ApiException
      throw ApiException('网络请求失败: $e');
    }
  }
  
  /// 获取缓存列表
  List<String> _getCache() {
    final jsonStr = _prefs?.getString(_cacheKey);
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.cast<String>();
    } catch (e) {
      return [];
    }
  }
  
  /// 保存缓存列表
  Future<void> _saveCache(List<String> cache) async {
    final jsonStr = jsonEncode(cache);
    await _prefs?.setString(_cacheKey, jsonStr);
  }
  
  /// 备用彩虹屁（当API调用失败时使用）
  String _getFallbackPuff() {
    final fallbacks = [
      '你真是太棒了！✨ 认真学习的小朋友最耀眼！💪',
      '哇塞！你的进步速度像火箭一样快！🚀 继续加油！',
      '太厉害了！你的认真劲儿让老师都感动了！😭🎉',
      '天呐！你怎么可以这么优秀！给你一万个赞！👍👍👍',
      '我的天！你就是学习小天才！✨ 继续保持哦！',
    ];
    fallbacks.shuffle();
    return fallbacks.first;
  }
  
  /// 清空缓存（用于测试或重置）
  Future<void> clearCache() async {
    await _prefs?.remove(_cacheKey);
  }
  
  /// 历史记录功能
  static const String _historyKey = 'rainbow_puff_history';
  
  /// 添加一条到历史记录
  Future<void> addToHistory(String content) async {
    final history = _getHistory();
    history.insert(0, content); // 添加到开头（最新的在前面）
    
    // 只保留最近100条
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    await _saveHistory(history);
  }
  
  /// 获取历史记录
  List<String> getHistory() {
    return _getHistory();
  }
  
  /// 清空历史记录
  Future<void> clearHistory() async {
    await _prefs?.remove(_historyKey);
  }
  
  /// 获取历史记录列表（内部）
  List<String> _getHistory() {
    final jsonStr = _prefs?.getString(_historyKey);
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.cast<String>();
    } catch (e) {
      return [];
    }
  }
  
  /// 保存历史记录列表（内部）
  Future<void> _saveHistory(List<String> history) async {
    final jsonStr = jsonEncode(history);
    await _prefs?.setString(_historyKey, jsonStr);
  }
}
