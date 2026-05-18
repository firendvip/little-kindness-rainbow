import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../services/cache_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CacheService _cacheService = CacheService();
  List<String> _history = [];
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  /// 加载历史记录
  void _loadHistory() {
    setState(() {
      _history = _cacheService.getHistory();
    });
  }
  
  /// 复制 to 剪贴板
  Future<void> _copyToClipboard(String content) async {
    await FlutterClipboard.copy(content);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板 ✨')),
      );
    }
  }
  
  /// 清空历史记录
  Future<void> _clearHistory() async {
    await _cacheService.clearHistory();
    setState(() {
      _history.clear();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('历史记录已清空')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF525F7F),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认清空'),
                    content: const Text('确定要清空所有历史记录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearHistory();
                        },
                        child: const Text('清空', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: '清空历史',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFF0F4F8),
              Color(0xFFE2E8F0),
              Color(0xFFD5E0F0),
            ],
          ),
        ),
        child: _history.isEmpty
            ? const Center(
                child: Text(
                  '暂无历史记录\n生成彩虹屁后会自动保存到这里 ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return _buildHistoryItem(item);
                },
              ),
      ),
    );
  }
  
  /// 历史记录条目
  Widget _buildHistoryItem(String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 10,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _copyToClipboard(content),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF525F7F),
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // 复制图标
            const Icon(
              Icons.copy,
              color: Color(0xFF9933FF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
