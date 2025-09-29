#!/bin/bash

# ScanTailor Universal Build Script with PDF Support
# Sets up environment variables and builds the project
# Usage: ./build_scantailor.sh [build_type]
# build_type: Release (default) or Debug

BUILD_TYPE="${1:-Release}"

echo "=== ScanTailor Universal Build Script ==="
echo "Build type: $BUILD_TYPE"
echo "Setting up environment for PDF support..."

# Set up environment variables - detect package manager and paths
setup_environment() {
    local brew_prefix=""
    local pkg_config_path=""
    local ld_flags=""
    local cpp_flags=""
    local cmake_prefix=""

    # Detect Homebrew (macOS)
    if command -v brew >/dev/null 2>&1; then
        brew_prefix="/opt/homebrew"
        pkg_config_path="${brew_prefix}/lib/pkgconfig:${brew_prefix}/share/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/qt@5/lib/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/poppler-qt5/lib/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/jpeg/lib/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/libpng/lib/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/libtiff/lib/pkgconfig"
        pkg_config_path="${pkg_config_path}:${brew_prefix}/opt/boost/lib/pkgconfig"

        export Qt5_DIR="${brew_prefix}/opt/qt@5/lib/cmake/Qt5"
        cmake_prefix="${brew_prefix}/opt/qt@5/lib/cmake:${brew_prefix}/opt/poppler-qt5/lib/cmake"

        ld_flags="-L${brew_prefix}/opt/poppler-qt5/lib -L${brew_prefix}/opt/jpeg/lib"
        ld_flags="${ld_flags} -L${brew_prefix}/opt/libpng/lib -L${brew_prefix}/opt/libtiff/lib -L${brew_prefix}/opt/boost/lib"

        cpp_flags="-I${brew_prefix}/opt/poppler-qt5/include -I${brew_prefix}/opt/jpeg/include"
        cpp_flags="${cpp_flags} -I${brew_prefix}/opt/libpng/include -I${brew_prefix}/opt/libtiff/include -I${brew_prefix}/opt/boost/include"

        export Poppler_ROOT="${brew_prefix}/opt/poppler-qt5"
    fi

    # Allow user overrides
    export PKG_CONFIG_PATH="${pkg_config_path}:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="${cmake_prefix}:${CMAKE_PREFIX_PATH:-}"
    export LDFLAGS="${ld_flags} ${LDFLAGS:-}"
    export CPPFLAGS="${cpp_flags} ${CPPFLAGS:-}"
}

# Library directory hints for CMake - use system paths or Homebrew if available
detect_homebrew_paths() {
    local lib_prefix=""
    local lib_suffix=""

    if command -v brew >/dev/null 2>&1; then
        lib_prefix="/opt/homebrew/opt"
    fi

    # JPEG library
    if [ -n "${JPEG_DIR:-}" ]; then
        export JPEG_DIR
    elif [ -f "${lib_prefix}/jpeg/include/jpeglib.h" ]; then
        export JPEG_DIR="${lib_prefix}/jpeg"
    fi

    # ZLIB library
    if [ -n "${ZLIB_DIR:-}" ]; then
        export ZLIB_DIR
    elif [ -f "${lib_prefix}/zlib/include/zlib.h" ]; then
        export ZLIB_DIR="${lib_prefix}/zlib"
    fi

    # PNG library
    if [ -n "${PNG_DIR:-}" ]; then
        export PNG_DIR
    elif [ -f "${lib_prefix}/libpng/include/png.h" ]; then
        export PNG_DIR="${lib_prefix}/libpng"
    fi

    # TIFF library
    if [ -n "${TIFF_DIR:-}" ]; then
        export TIFF_DIR
    elif [ -f "${lib_prefix}/libtiff/include/tiff.h" ]; then
        export TIFF_DIR="${lib_prefix}/libtiff"
    fi

    # OpenJPEG library
    if [ -n "${JPEG2000_DIR:-}" ]; then
        export JPEG2000_DIR
    elif [ -f "${lib_prefix}/openjpeg/include/openjpeg-2.5/openjpeg.h" ] 2>/dev/null; then
        export JPEG2000_DIR="${lib_prefix}/openjpeg"
    fi

    # EXIV2 library
    if [ -n "${EXIV2_DIR:-}" ]; then
        export EXIV2_DIR
    elif [ -f "${lib_prefix}/exiv2/include/exiv2/exiv2.hpp" ]; then
        export EXIV2_DIR="${lib_prefix}/exiv2"
    fi

    # POPPLER library
    if [ -n "${POPPLER_DIR:-}" ]; then
        export POPPLER_DIR
    elif [ -f "${lib_prefix}/poppler-qt5/include/poppler/qt5/poppler-qt5.h" ]; then
        export POPPLER_DIR="${lib_prefix}/poppler-qt5"
    fi
}

echo "Setting up build environment..."
setup_environment
detect_homebrew_paths

echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo "Qt5_DIR: $Qt5_DIR"
echo "CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"

# Navigate to project directory
cd "$(dirname "$0")"

# Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Prepare CMake arguments dynamically
cmake_args=(
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
  -DCMAKE_MODULE_PATH="$(pwd)/../cmake"
  -G "Unix Makefiles"
)

# Add CMake prefix path and Qt5 directory if detected
if [ -n "${CMAKE_PREFIX_PATH:-}" ] && [[ "$CMAKE_PREFIX_PATH" != *":"* ]]; then
  cmake_args+=(-DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH")
elif [ -n "${CMAKE_PREFIX_PATH:-}" ]; then
  # If CMAKE_PREFIX_PATH contains multiple paths (colon-separated), split them
  IFS=':' read -ra CMAKE_PATHS <<< "$CMAKE_PREFIX_PATH"
  cmake_args+=(-DCMAKE_PREFIX_PATH="${CMAKE_PATHS[*]}")
fi

if [ -n "${Qt5_DIR:-}" ]; then
  cmake_args+=(-DQt5_DIR="$Qt5_DIR")
fi

if [ -n "${Poppler_ROOT:-}" ]; then
  cmake_args+=(-DPoppler_ROOT="$Poppler_ROOT")
fi

# Run CMake configuration
echo "Configuring with CMake..."
cmake .. "${cmake_args[@]}"

if [ $? -ne 0 ]; then
    echo "❌ CMake configuration failed!"
    exit 1
fi

# Build the project
echo "Building ScanTailor Universal..."
make -j$(sysctl -n hw.ncpu)

if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "Binary location: $(pwd)/app/scantailor-universal"
    echo "CLI binary location: $(pwd)/app_cli/scantailor-cli"
else
    echo "❌ Build failed!"
    exit 1
fi
