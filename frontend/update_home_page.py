import re

file_path = r'lib\features\home\home_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove _buildGameRoomsSection from ListView children
content = re.sub(r'\s*_buildGameRoomsSection\(dataProvider, socketService\),\s*const SizedBox\(height: 10\),', '', content)

# Remove the three widget methods: _buildGameRoomsSection, _buildGameRoomItem, _buildSeeAllButton
content = re.sub(r'  Widget _buildGameRoomsSection\(Data dataProvider, SocketService socketService\) \{.*?(?=  Widget _buildPlayOptionsSection)', '', content, flags=re.DOTALL)

# Rename 'Play with a Friend' to 'Play Private'
content = content.replace("'Play with a Friend'", "'Play Private'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated home_page.dart")
