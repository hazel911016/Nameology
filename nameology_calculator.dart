import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/sancai_data.dart'; 

class NameologyCalculator {
  // 建立一個靜態 Map 來儲存從 JSON 載入的 6 萬多筆資料
  static Map<String, int> _fullDb = {};

  // 🔥 關鍵修正：這是 main.dart 在找的「loadDatabase」，沒這段 main.dart 就會紅底線
  static Future<void> loadDatabase() async {
    try {
      final String response = await rootBundle.loadString('assets/stroke_db.json');
      final Map<String, dynamic> data = json.decode(response);
      _fullDb = data.map((key, value) => MapEntry(key, value as int));
      print("✅ 康熙字典載入成功，共計 ${_fullDb.length} 字。");
    } catch (e) {
      print("❌ 載入失敗: $e");
    }
  }

  static Map<String, dynamic> analyze(String name) {
    if (name.length < 2) return {};

    // 這裡改用修正後的 _getStroke
    int s1 = _getStroke(name[0]); 
    int n1 = _getStroke(name[1]); 
    int n2 = name.length > 2 ? _getStroke(name[2]) : 0; 
    
    bool isSingleName = name.length == 2;
    int tiange = s1 + 1; 
    int renge = s1 + n1; 
    int dige = isSingleName ? (n1 + 1) : (n1 + n2); 
    int zongge = s1 + n1 + n2; 
    int waige = zongge - renge; 

    String tW = _calculateWuxing(tiange);
    String rW = _calculateWuxing(renge);
    String dW = _calculateWuxing(dige);
    String zW = _calculateWuxing(zongge);
    String wW = _calculateWuxing(waige);

    String config = "$tW$rW$dW";
    Map<String, String> sancaiInfo = sancaiTable[config] ?? {
      "result": "平",
      "content": "此三才配置 [$config] 尚在收集分析中。"
    };

    return {
      "scores": {
        "天格": {"score": tiange, "wuxing": tW},
        "人格": {"score": renge, "wuxing": rW},
        "地格": {"score": dige, "wuxing": dW},
        "總格": {"score": zongge, "wuxing": zW},
        "外格": {"score": waige, "wuxing": wW},
      },
      "sancai": {
        "config": config,
        "result": sancaiInfo["result"],
        "content": sancaiInfo["content"],
      }
    };
  }

  // 🔥 關鍵修正：改查 _fullDb，名字筆畫才不會是 0
  static int _getStroke(String char) {
    return _fullDb[char] ?? 0;
  }

  static String _calculateWuxing(int score) {
    int mod = score % 10;
    if (mod == 0) mod = 10;
    if (mod <= 2) return "木";
    if (mod <= 4) return "火";
    if (mod <= 6) return "土";
    if (mod <= 8) return "金";
    return "水";
  }
}