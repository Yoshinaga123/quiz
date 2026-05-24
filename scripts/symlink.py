import os
from pathlib import Path

# リンク元（実体）とリンク先（シンボリックリンク）を指定
target = Path("target_file.txt")
link   = Path("link_to_target.txt")

# # 実体ファイルを作成
target.write_text("Hello from target!")

# # シンボリックリンクを作成
link.unlink(missing_ok=True)
link.symlink_to(target.resolve())

print(f"target : {target.resolve()}")
print(f"symlink: {link.resolve()}")
print(f"link -> {os.readlink(link)}")