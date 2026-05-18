import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CacheService _cacheService = CacheService();
  final TextEditingController _eventController = TextEditingController();
  
  String _currentPuff = ''; // 当前显示的彩虹屁
  bool _isGenerating = false; // 是否正在生成
  String _identity = '小学生'; // 当前身份（默认"小学生"）
  
  @override
  void initState() {
    super.initState();
    _loadInitialPuff();
  }
  
  /// 加载初始彩虹屁（从缓存取一条）
  Future<void> _loadInitialPuff() async {
    setState(() {
      _isGenerating = true;
    });
    
    try {
      final puff = await _cacheService.getOne();
      setState(() {
        _currentPuff = puff;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _currentPuff = '加载失败，请重试 🌟';
        _isGenerating = false;
      });
    }
  }
  
  /// 生成彩虹屁
  Future<void> _generatePuff() async {
    setState(() {
      _isGenerating = true;
    });
    
    try {
      final event = _eventController.text.trim();
      String puff;
      
      if (event.isEmpty) {
        // 不输入事件，从缓存取
        puff = await _cacheService.getOne();
      } else {
        // 输入了事件，生成定制版
        puff = await _cacheService.generateCustom(
          identity: _identity,
          event: event,
        );
      }
      
      // 添加到历史记录
      await _cacheService.addToHistory(puff);
      
      setState(() {
        _currentPuff = puff;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _currentPuff = '生成失败，请重试 🌟';
        _isGenerating = false;
      });
    }
  }
  
  /// 分享到微信
  void _shareToWeChat() {
    if (_currentPuff.isEmpty) return;
    
    Share.share(
      _currentPuff,
      subject: '小善彩虹屁 🌈',
    );
  }
  
  /// 复制 to 剪贴板
  Future<void> _copyToClipboard() async {
    if (_currentPuff.isEmpty) return;
    
    await FlutterClipboard.copy(_currentPuff);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板 ✨')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              _buildTopBar(),
              
              // 主内容区
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 主卡片（显示彩虹屁）
                      _buildMainCard(),
                      
                      const SizedBox(height: 30),
                      
                      // 输入框
                      _buildInputField(),
                      
                      const SizedBox(height: 20),
                      
                      // 生成按钮
                      _buildGenerateButton(),
                      
                      const SizedBox(height: 20),
                      
                      // 操作按钮（转发、复制）
                      if (_currentPuff.isNotEmpty) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
              
              // 底部固定文案
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 顶部栏
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题
          const Text(
            '小善彩虹屁',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF525F7F),
            ),
          ),
          
          // 历史按钮
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF525F7F)),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            tooltip: '历史记录',
          ),
        ],
      ),
    );
  }
  
  /// 主卡片
  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF), // rgba(255,255,255,0.95)
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xB3E6E6FA), // rgba(230,230,250,0.7)
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 10,
            color: Color(0x0D000000), // rgba(0,0,0,0.05)
          ),
          BoxShadow(
            offset: Offset(0, 15),
            blurRadius: 50,
            color: Color(0x33000000), // rgba(0,0,0,0.2)
          ),
        ],
      ),
      child: _isGenerating
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Text(
              _currentPuff.isEmpty ? '点击生成按钮开始 ✨' : _currentPuff,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF525F7F),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
  
  /// 输入框
  Widget _buildInputField() {
    return Container(
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
      child: TextField(
        controller: _eventController,
        maxLength: 50,
        decoration: const InputDecoration(
          hintText: '具体要夸的事情（选填，默认"认真学习"）',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
          counterText: '', // 隐藏字数统计
        ),
      ),
    );
  }
  
  /// 生成按钮
  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF5E72E4),
            Color(0xFF825EE4),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 10,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generatePuff,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '生成彩虹屁 ✨',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
  
  /// 操作按钮（转发、复制）
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 转发按钮
        IconButton(
          icon: const Icon(Icons.share, color: Color(0xFF9933FF)),
          onPressed: _shareToWeChat,
          tooltip: '分享到微信',
        ),
        
        const SizedBox(width: 20),
        
        // 复制按钮
        IconButton(
          icon: const Icon(Icons.copy, color: Color(0xFF9933FF)),
          onPressed: _copyToClipboard,
          tooltip: '复制到剪贴板',
        ),
      ],
    );
  }
  
  /// 底部固定文案
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        '小朋友专属彩虹屁生成器',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF525F7F),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}
