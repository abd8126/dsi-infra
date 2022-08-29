import os
from typing import List, Tuple


def get_files_in_dir_with_ext(path: str, exts: list = [".py", ".whl", ".tar.gz", ".zip"]) -> List[Tuple[str, str]]:
    for file in os.listdir(path):
        for ext in exts:
            if file.endswith(ext):
                yield (os.path.join(path, file), file)

def get_root_dir() -> str:
    this_dir = os.path.dirname(__file__)
    return os.path.abspath(os.path.join(this_dir, "..", "src"))

def get_folders_at_path(path: str) -> List[str]:
    return [name for name in os.listdir(path) if os.path.isdir(os.path.join(path, name))]
