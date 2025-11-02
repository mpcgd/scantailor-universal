/*
    Scan Tailor Universal - Interactive post-processing tool for scanned
    pages. A fork of Scan Tailor by Joseph Artsimovich.
    Copyright (C) 2020 Alexander Trufanov <trufanovan@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "PngWriter.h"
#include <QFile>
#include <QImageWriter>

bool
PngWriter::writeImage(QString const& file_path, QImage const& image, int compression_level)
{
    if (image.isNull()) {
        return false;
    }

    QImageWriter writer(file_path, "PNG");

    // Optimize compression level mapping for PNG
    // Qt's QImageWriter uses quality 0-100, where lower values = higher compression
    // Map our 0-9 compression levels to appropriate quality values
    if (compression_level >= 0 && compression_level <= 9) {
        // More accurate mapping: compression 0-9 maps to quality 100-0
        // This gives better granularity and more predictable compression
        int quality = 100 - (compression_level * 11); // 100, 89, 78, 67, 56, 45, 34, 23, 12, 1
        writer.setQuality(quality);
    }

    // Optimize format handling - avoid unnecessary conversions
    QImage image_to_write = image;

    // Check if current format is already optimal for PNG
    bool needs_conversion = false;
    switch (image.format()) {
        case QImage::Format_RGB32:
        case QImage::Format_ARGB32:
        case QImage::Format_RGB888:
        case QImage::Format_RGBA8888:
        case QImage::Format_Indexed8:  // Keep indexed formats when possible
        case QImage::Format_Mono:      // Keep monochrome when possible
        case QImage::Format_MonoLSB:
            // These formats are well-supported by PNG
            needs_conversion = false;
            break;
        default:
            // Convert to optimal format based on alpha channel presence
            needs_conversion = true;
            break;
    }

    if (needs_conversion) {
        if (image.hasAlphaChannel()) {
            image_to_write = image.convertToFormat(QImage::Format_RGBA8888);
        } else {
            image_to_write = image.convertToFormat(QImage::Format_RGB888);
        }
    }

    // Set optimized PNG-specific options
    writer.setOptimizedWrite(true);

    // Ensure the writer can write to the file
    if (!writer.canWrite()) {
        return false;
    }

    // Write the image and check for errors
    bool success = writer.write(image_to_write);

    // If writing failed, check for specific error conditions
    if (!success) {
        // Ensure we don't leave a partially written file
        QFile::remove(file_path);
    }

    return success;
}
