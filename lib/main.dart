import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化缓存服务（预生成20条彩虹屁）
  await CacheService().initCache();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小善彩虹屁',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E72E4),
          primary: const Color(0xFF5E72E4),
          secondary: const Color(0xFF825EE4),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
