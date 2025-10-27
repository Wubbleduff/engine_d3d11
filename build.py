
import os
import shutil
import subprocess
import sys

################################################################################
# Build config.
program_name = "engine_d3d11"

src_dir = "src"
build_dir = "build"

common_compile_flags = [
    "/c",
    "/W4",
    "/WX",
    "/EHsc",
    "/std:c17",
    # Avoid C runtime library
    # https://hero.handmade.network/forums/code-discussion/t/94-guide_-_how_to_avoid_c_c++_runtime_on_windows
    "/GS-",
    "/Gs9999999",
    "/nologo",
]

include_dirs = [
    "src",

    # TODO: Remove common include dir here!
    "../common",
]
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
print("########")
print("######## TODO: Remove the 'common' include dir from config (and this message)!")
print("########")
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
common_debug_compile_flags = [
    "/Od",
    "/Zi",
    "/DDEBUG",
]

common_release_compile_flags = [
    "/O2",
]

libs = [
    "kernel32.lib",
    "user32.lib",
    "gdi32.lib",
    "d3d11.lib",
    "dxgi.lib",
    "dxguid.lib",
]

common_link_flags = [
    "/NODEFAULTLIB",
    "/STACK:0x100000,0x100000",
    "/SUBSYSTEM:WINDOWS",
    "/MACHINE:X64",
]

# Build definition for all compilers and configurations.
build = [
    {
        "name" : "clang",
        "cc_cmd" : "clang-cl",
        "link_cmd" : "lld-link",
        "configs": [
            {
                "name" : "debug",
                "cc_flags" : [
                    *common_compile_flags,
                    *common_debug_compile_flags,
                    *[f"/I{s}" for s in include_dirs],
                    "-march=skylake",
                ],
                "link_flags" : [
                    *common_link_flags,
                    "/DEBUG:FULL",
                ],
            },
            {
                "name" : "release",
                "cc_flags" : [
                    *common_compile_flags,
                    *common_release_compile_flags,
                    *[f"/I{s}" for s in include_dirs],
                    "-march=skylake",
                ],
                "link_flags" : [
                    *common_link_flags,
                ],
            },
        ]
    },

    {
        "name" : "msvc",
        "cc_cmd" : "cl",
        "link_cmd" : "link",
        "configs": [
            {
                "name" : "debug",
                "cc_flags" : [
                    *common_compile_flags,
                    *common_debug_compile_flags,
                    *[f"/I{s}" for s in include_dirs],
                ],
                "link_flags" : [
                    *common_link_flags,
                    "/DEBUG:FULL",
                ],
            },
            {
                "name" : "release",
                "cc_flags" : [
                    *common_compile_flags,
                    *common_release_compile_flags,
                    *[f"/I{s}" for s in include_dirs],
                ],
                "link_flags" : [
                    *common_link_flags,
                ],
            },
        ]
    },
]
################################################################################


################################################################################
# Run build.

def print_help():
    print("Usage: 'build.py <compiler> <configuration>'")
    print("       <compiler> and <configuration> are optional.")
    print("Available compilers and configs:")
    for compiler in build:
        for config in compiler["configs"]:
            print(f"    build.py {compiler['name']} {config['name']}")

if len(sys.argv) == 1:
    filter_compiler = None
    filter_config = None
elif len(sys.argv) == 2:
    filter_compiler = sys.argv[1]
    filter_config = None
elif len(sys.argv) == 3:
    filter_compiler = sys.argv[1]
    filter_config = sys.argv[2]
else:
    print_help()
    exit(1)

if filter_compiler and filter_compiler not in [c["name"] for c in build]:
    print_help()
    exit(1)

if filter_config and filter_config not in [config["name"] for compiler in build for config in compiler["configs"]]:
    print_help()
    exit(1)

# Clean build.
try:
    shutil.rmtree(build_dir)
except FileNotFoundError:
    pass

# Do build.
for compiler in build:

    if filter_compiler and filter_compiler != compiler["name"]:
        continue

    for config in compiler["configs"]:

        if filter_config and filter_config != config["name"]:
            continue

        working_dir = os.path.join(build_dir, f"intermediate_{compiler['name']}_{config['name']}")
        os.makedirs(working_dir, exist_ok=True)

        # Copy the src directory to the intermediate build directory and gather all ".c"
        # files under it.
        src_files = []
        shutil.copytree(src_dir, os.path.join(working_dir, src_dir))
        for root, dirs, files in os.walk(working_dir):
            for src_file in files:
                if os.path.splitext(src_file)[1] == ".c":
                    src_files.append(os.path.join(root, src_file))
        
        # Compile all src files.
        compile_success = True
        obj_files = []
        for src_file in src_files:
            obj_file = f"{os.path.splitext(src_file)[0]}.obj"
            pdb_file = f"{os.path.splitext(src_file)[0]}.pdb"

            cmd_list = []
            cmd_list.append(compiler["cc_cmd"])
            cmd_list.extend(config["cc_flags"])
            cmd_list.append(f"/Fo{obj_file}")
            cmd_list.append(f"/Fd{pdb_file}")
            cmd_list.append(src_file)
            
            cmd_str = " ".join(cmd_list)
            print(f"Compiling '{src_file}'...")
            proc = subprocess.run(cmd_str, capture_output=True)
            if proc.returncode != 0:
                print(proc.stdout.decode("utf-8"))
                print(proc.stderr.decode("utf-8"))
                compile_success = False
            obj_files.append(obj_file)
        
        if not compile_success:
            exit(1)
        
        working_program_file = os.path.join(working_dir, f"{program_name}.exe")

        # Link all object files.
        cmd_list = []
        cmd_list.append(compiler["link_cmd"])
        cmd_list.extend(config["link_flags"])
        cmd_list.extend(libs)
        cmd_list.append(f"/OUT:{working_program_file}")
        cmd_list.extend(obj_files)
        cmd_str = " ".join(cmd_list)
        print("Linking...")
        proc = subprocess.run(cmd_str, capture_output=True)
        if proc.returncode != 0:
            print(proc.stdout.decode("utf-8"))
            print(proc.stderr.decode("utf-8"))
            exit(1)

        # Copy files for deploy.
        deploy_dir = os.path.join(build_dir, f"deploy_{compiler['name']}_{config['name']}")
        os.makedirs(deploy_dir, exist_ok=True)
        deploy_program_file = os.path.join(deploy_dir, f"{program_name}.exe")
        shutil.copyfile(working_program_file, deploy_program_file)
        print(f"{deploy_program_file}")
