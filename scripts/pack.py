import os
import shutil
import zipfile
import re
import json


def read_packignore():
    packignore = []
    try:
        with open(".packignore", "r") as f:
            for line in f:
                line = line.strip()
                if line != "":
                    packignore.append(line)
    except FileNotFoundError:
        return []
    
    ignore_patterns = []
    for pattern in packignore:
        if pattern[-1] == "/":
            pattern += "*"
        pattern = f"./{pattern}$"
        ignore_patterns.append(re.compile(pattern.replace(".", "\.").replace("*", ".*")))

    return ignore_patterns


def read_packmcmeta():
    try:
        with open("pack.mcmeta", "r") as f:
            data = json.load(f)
            return data
    except FileNotFoundError or json.JSONDecodeError or KeyError as e:
        return {"name": "pack", "version": "1.0"}
    except Exception as e:
        print(f"Error: {e}")
        return {"name": "pack", "version": "1.0"}


def get_files(folder):
    files = []
    for root, dirs, filenames in os.walk(folder):
        for filename in filenames:
            files.append(os.path.join(root, filename))
    return files


def copy_files(files, ignore_patterns):
    for file in files:
        ignore = False
        file = file.replace("\\", "/")
        fp = os.path.relpath(file, ".")

        for pattern in ignore_patterns:
            # print("\t\t"+pattern.pattern)
            if pattern.match(file):
                ignore = True
                break
        if not ignore:
            print(f"Copying: {file}")
            if not os.path.exists(f"__build__/{os.path.dirname(fp)}"):
                os.makedirs(f"__build__/{os.path.dirname(fp)}")
            shutil.copy(file, f"__build__/{fp}")
    return


def zip_files(src, dst, name, version):
    with zipfile.ZipFile(f"{name}-{version}.zip", "w") as zipf:
        for root, dirs, files in os.walk(src):
            for file in files:
                zipf.write(os.path.join(root, file), os.path.relpath(os.path.join(root, file), src))
    
    print(f"Zipped: {name}-{version}.zip")
    return



def main():
    reg = read_packignore()
    pack = read_packmcmeta()

    files = get_files(".")

    if not os.path.exists("__build__"):
        os.makedirs("__build__")

    copy_files(files, reg)

    zip_files("__build__", ".", pack["name"], pack["version"])

    shutil.rmtree("__build__")





if __name__ == "__main__":
    main()