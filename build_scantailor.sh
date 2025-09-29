#!/bin/bash

# ScanTailor Universal Build Script with PDF Support
# Sets up environment variables and builds the project

echo "=== ScanTailor Universal Build Script ==="
echo "Setting up environment for PDF support..."

# Set up environment variables for Homebrew libraries
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:/opt/homebrew/share/pkgconfig:/opt/homebrew/opt/qt@5/lib/pkgconfig:/opt/homebrew/opt/poppler-qt5/lib/pkgconfig:/opt/homebrew/opt/jpeg/lib/pkgconfig:/opt/homebrew/opt/libpng/lib/pkgconfig:/opt/homebrew/opt/libtiff/lib/pkgconfig:/opt/homebrew/opt/boost/lib/pkgconfig"
export Qt5_DIR="/opt/homebrew/opt/qt@5/lib/cmake/Qt5"
export CMAKE_PREFIX_PATH="/opt/homebrew/opt/qt@5/lib/cmake:/opt/homebrew/opt/poppler-qt5/lib/cmake"
export LDFLAGS="-L/opt/homebrew/opt/poppler-qt5/lib -L/opt/homebrew/opt/jpeg/lib -L/opt/homebrew/opt/libpng/lib -L/opt/homebrew/opt/libtiff/lib -L/opt/homebrew/opt/boost/lib"
export CPPFLAGS="-I/opt/homebrew/opt/poppler-qt5/include -I/opt/homebrew/opt/jpeg/include -I/opt/homebrew/opt/libpng/include -I/opt/homebrew/opt/libtiff/include -I/opt/homebrew/opt/boost/include"

echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo "Qt5_DIR: $Qt5_DIR"
echo "CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"

# Navigate to project directory
cd "$(dirname "$0")"

# Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Run CMake configuration
echo "Configuring with CMake..."
cmake .. \
  -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt@5/lib/cmake;/opt/homebrew/opt/poppler-qt5/lib/cmake" \
  -DQt5_DIR="/opt/homebrew/opt/qt@5/lib/cmake/Qt5" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MODULE_PATH="$(pwd)/../cmake" \
  -DPoppler_ROOT="/opt/homebrew/opt/poppler-qt5" \
  -G "Unix Makefiles"

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
