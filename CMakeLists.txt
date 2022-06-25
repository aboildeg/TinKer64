cmake_minimum_required(VERSION 3.12)
set(CMAKE_SYSTEM_NAME Generic)
project(tinker64 VERSION 0.1 LANGUAGES C)

SET(ARCH "x86_64" CACHE STRING "The architecture to be built")

if(WIN32)
    if(CYGWIN)
        message(FATAL_ERROR "No Cygwin Detected!")
    endif(CYGWIN)
endif(WIN32)

set(SYSROOT "${CMAKE_CURRENT_SOURCE_DIR}/sysroot")

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "In-source builds are not allowed!")
endif("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")

set(COMPILER_NAME "${ARCH}-elf")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -g -Wall -Wextra -Wpedantic -pipe") # Optional flags - change as neededs

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding -fno-builtin -fdiagnostics-color=always -I. -std=c11 -fno-stack-protector -fno-stack-check -fno-pic -mabi=sysv -mno-80387 -mno-mmx -mno-3dnow -mno-sse -mno-sse2 -mno-red-zone -mcmodel=kernel -MMD")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -nostdlib -static -z max-page-size=0x1000 -T ${CMAKE_CURRENT_SOURCE_DIR}/arch/${ARCH}/boot/linker.ld")

set(ARCH_PATH "${CMAKE_SOURCE_DIR}/arch/${ARCH}")

find_program(CMAKE_C_COMPILER "${COMPILER_NAME}-gcc")
if(NOT CMAKE_C_COMPILER)
    message(FATAL_ERROR "${ARCH} cross-compiler not found!")
endif(NOT CMAKE_C_COMPILER)
set(CMAKE_C_COMPILER_WORKS 1)

add_executable(tinker.kernel)
target_link_libraries(tinker.kernel gcc)
target_include_directories(tinker.kernel PRIVATE include)
add_subdirectory(arch)
add_subdirectory(kernel)

set(BOOT "/boot")
execute_process(COMMAND "export BUILD_PATH=${CMAKE_BINARY_DIR}")

set(KERNEL_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include/")


install(TARGETS tinker.kernel DESTINATION "${SYSROOT}${BOOT}")