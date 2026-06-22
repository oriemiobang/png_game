import re

file_path = r'lib\main.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove import
content = re.sub(r'import \'package:png_game/screens/rooms_page\.dart\';\n', '', content)

# Remove route
content = re.sub(r'\s*GoRoute\(\s*path: \'/rooms_page\',\s*builder: \(context, state\) => const RoomsPage\(\),\s*\),', '', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated main.dart")
