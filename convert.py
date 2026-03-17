import csv
import os

# 定義檔案路徑
csv_file_path = 'kangxi-strokecount.csv'
json_file_path = 'assets/stroke_db.json'

# 確保 assets 目錄存在
if not os.path.exists('assets'):
    os.makedirs('assets')

# 讀取數據
data_dict = {}
with open(csv_file_path, mode='r', encoding='utf-8-sig', errors='ignore') as f:
    lines = f.readlines()
    start_line = 0
    for i, line in enumerate(lines):
        if "Character" in line:
            start_line = i
            break
    
    reader = csv.DictReader(lines[start_line:])
    for row in reader:
        try:
            char = row['Character'].strip()
            strokes = row['Strokes'].strip()
            # 確保是單一漢字且筆畫為數字
            if len(char) == 1 and strokes.isdigit():
                data_dict[char] = strokes
        except:
            continue

# 💡 核心修正：手動構建 JSON 字串，強制保留原始漢字編碼
json_content = "{\n"
items = [f'  "{k}": {v}' for k, v in data_dict.items()]
json_content += ",\n".join(items)
json_content += "\n}"

# 寫入檔案
with open(json_file_path, 'w', encoding='utf-8') as f:
    f.write(json_content)

print(f"✅ 強制編碼修正完成！共轉換 {len(data_dict)} 個字。")