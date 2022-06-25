#!/bin/bash

SOURCE_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BUILD_DIR="${SOURCE_DIR}/build"

cd "${SOURCE_DIR}"

for i in "$@"
do
    case $i in
        --build_dir=*|--build_directory=*)
            BUILD_DIR="$( cd "$(dirname "${i#*=}")" && pwd)/build"
            shift
            ;;
        --help|-h)
            echo "  --build_dir=    set the build directory to search for kernel (relative path)"
            exit 0
            ;;
        *)
            echo "Unknown option $i. Type -h/--help for usage"
            exit 1
            ;;
    esac
done


if [ ! -d "${BUILD_DIR}" ]
then
    echo "Build directory does not exist!"
    exit 1
fi
 
if [ ! -f "${BUILD_DIR}/tinker.kernel" ] # Builds the kernel if not present
then
    CURRENT_DIR="${PWD}"
    cd "${BUILD_DIR}"
    cmake ../ && make
    cd "${CURRENT_DIR}"
fi

LIMINE="$( cd "$(dirname "$(find ${SOURCE_DIR} -type d -name 'limine')")" && pwd)/limine"

if [ ! -d "${LIMINE}" ]
then
    git clone https://github.com/limine-bootloader/limine.git --branch=v3.0-branch-binary --depth=1
    make -C limine
    LIMINE="$( cd "$(dirname "$(find ${SOURCE_DIR} -type d -name 'limine')")" && pwd)/limine"
fi

mkdir -p iso_root
cp -v "${BUILD_DIR}/tinker.kernel" limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/
xorriso -as mkisofs -b limine-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table --efi-boot limine-cd-efi.bin -efi-boot-part --efi-boot-image --protective-msdos-label iso_root -o image.iso

${LIMINE}/limine-deploy image.iso
    