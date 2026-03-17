import 'package:flutter/material.dart';
import 'utils/nameology_calculator.dart'; // 確保檔案路徑正確

void main() async {
  // 1. 這是啟動資產讀取的關鍵，沒加這行會讀不到 JSON
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. 務必加上 await，確保資料讀完才跑 APP
  await NameologyCalculator.loadDatabase(); 
  
  runApp(const NameologyApp());
}


class NameologyApp extends StatelessWidget {
  const NameologyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _data; // 儲存計算結果

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('姓名學三才五行分析')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller, 
              decoration: const InputDecoration(labelText: '輸入姓名', border: OutlineInputBorder())
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 呼叫計算器並更新狀態
                  setState(() { 
                    _data = NameologyCalculator.analyze(_controller.text); 
                  });
                }, 
                child: const Text('開始分析'),
              ),
            ),
            
            // 增加 isEmpty 判斷，確保資料結構完整才渲染 UI
            if (_data != null && _data!.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text('【五格數理】', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              // 修正點：使用顯性型別轉換，避免 dynamic 呼叫失敗
              ...(_data!['scores'] as Map<String, dynamic>).entries.map((e) {
                final scoreData = e.value as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(scoreData['wuxing'] ?? '')),
                    title: Text("${e.key}: ${scoreData['score']} 劃"),
                    trailing: Text("屬${scoreData['wuxing']}"),
                  ),
                );
              }),
              
              const Divider(),
              const Text('【三才配置分析】', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              // 修正點：對應 NameologyCalculator 回傳的 'sancai' 鍵值，並加入顏色判斷
              _buildSancaiCard(),
            ]
          ],
        ),
      ),
    );
  }

  // 獨立出的三才分析組件，增加易讀性與穩定性
  Widget _buildSancaiCard() {
    final sancai = _data!['sancai'] as Map<String, dynamic>;
    final result = sancai['result'] ?? '平';
    
    // 根據吉凶自動決定顏色
    final Color bgColor = result == '吉' ? Colors.green.shade50 : 
                          result == '凶' ? Colors.red.shade50 : Colors.orange.shade50;
    final Color textColor = result == '吉' ? Colors.green.shade700 : 
                            result == '凶' ? Colors.red.shade700 : Colors.orange.shade800;

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "${sancai['config']} ($result)",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Text(
              sancai['content'] ?? '暫無詳細分析',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
