#!/usr/bin/env python3
"""Build the xlsxio static libraries, named to match lib_name.odin.

    python3 build.py [clean] [--cc CC] [--ar AR] [--os OS] [--arch ARCH] [--out DIR]

Clones xlsxio (tag VERSION) into ./xlsxio if it is missing.
Outputs <out>/libxlsxio_{read,write}_<os>_<arch>.{a,lib}. The libzip and expat
headers are needed at build time; they are linked later by Odin (system:zip,
system:expat). --os/--arch only affect the output name and must match the
toolchain given by --cc/--ar (e.g. a cross compiler).
"""
import argparse, os, platform, shutil, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(ROOT, "xlsxio")
REPO = "https://github.com/brechtsanders/xlsxio"
VERSION = "0.2.37"  # git tag

# Same mapping as lib_name.odin.
OS_NAMES = {"Windows": "windows", "Darwin": "darwin", "Linux": "linux", "FreeBSD": "freebsd"}
ARCH_NAMES = {"x86_64": "x64", "amd64": "x64", "arm64": "arm64", "aarch64": "arm64"}

LIBS = {
    "read": ["lib/xlsxio_read.c", "lib/xlsxio_read_sharedstrings.c"],
    "write": ["lib/xlsxio_write.c"],
}


def run(cmd):
    print(" ".join(cmd))
    subprocess.run(cmd, check=True)


def fetch():
    if os.path.isfile(os.path.join(SRC, "lib", "xlsxio_read.c")):
        return
    if not shutil.which("git"):
        sys.exit("git is required to fetch xlsxio (or place it in ./xlsxio)")
    shutil.rmtree(SRC, ignore_errors=True)
    run(["git", "clone", "--depth", "1", "--branch", VERSION, REPO, SRC])


def include_flags():
    flags = []
    if shutil.which("pkg-config"):
        r = subprocess.run(["pkg-config", "--cflags", "libzip", "expat"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if r.returncode == 0:
            return r.stdout.split()
    for d in ("/opt/homebrew/include", "/usr/local/include"):
        if os.path.isdir(d):
            flags.append("-I" + d)
    return flags


def main():
    p = argparse.ArgumentParser()
    p.add_argument("action", nargs="?", default="build", choices=["build", "clean"])
    p.add_argument("--cc", default=os.environ.get("CC", "cc"))
    p.add_argument("--ar", default=os.environ.get("AR", "ar"))
    p.add_argument("--os", dest="os_name", default=OS_NAMES.get(platform.system(), "unknown"))
    p.add_argument("--arch", default=ARCH_NAMES.get(platform.machine().lower(), "unknown"))
    p.add_argument("--out", default=os.path.join(ROOT, "build"))
    a = p.parse_args()

    if a.action == "clean":
        shutil.rmtree(a.out, ignore_errors=True)
        return
    if "unknown" in (a.os_name, a.arch):
        sys.exit(f"unsupported platform {a.os_name}/{a.arch}; pass --os/--arch")

    fetch()
    ext = "lib" if a.os_name == "windows" else "a"
    os.makedirs(a.out, exist_ok=True)
    cflags = ["-O2", "-fPIC", "-DBUILD_XLSXIO", "-DBUILD_XLSXIO_STATIC", "-DUSE_LIBZIP",
              "-I" + os.path.join(SRC, "include"), "-I" + os.path.join(SRC, "lib")] + include_flags()
    if a.os_name == "windows":
        cflags.remove("-fPIC")

    for name, sources in LIBS.items():
        target = os.path.join(a.out, f"libxlsxio_{name}_{a.os_name}_{a.arch}.{ext}")
        with tempfile.TemporaryDirectory() as tmp:
            objs = []
            for s in sources:
                obj = os.path.join(tmp, os.path.basename(s) + ".o")
                run([a.cc, *cflags, "-c", os.path.join(SRC, s), "-o", obj])
                objs.append(obj)
            if os.path.exists(target):
                os.remove(target)
            run([a.ar, "rcs", target, *objs])
        print("built", os.path.relpath(target, ROOT))


if __name__ == "__main__":
    main()
