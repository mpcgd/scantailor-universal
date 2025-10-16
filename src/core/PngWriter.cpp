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

    if (compression_level >= 0 && compression_level <= 9) {
        writer.setQuality(compression_level * 10); // Qt uses 0-100 scale, so map 0-9 to 0-90, but this isn't exactly compression level
        // Actually, for PNG, Qt's quality setting affects compression. Higher quality = lower compression.
        // Since we want compression level where higher number = more compression,
        // we need to invert: compression_level 9 (max compression) should be quality 0 (max compression)
        writer.setQuality((9 - compression_level) * 11); // This gives a rough mapping from 0 to 99
    }

    // For PNG, we want to ensure the image has the right format
    QImage image_to_write = image;
    if (image.format() != QImage::Format_RGB32 && image.format() != QImage::Format_ARGB32 &&
        image.format() != QImage::Format_RGB888 && image.format() != QImage::Format_RGBA8888) {
        // Convert to RGB32 which is well supported for PNG
        if (image.hasAlphaChannel()) {
            image_to_write = image.convertToFormat(QImage::Format_ARGB32);
        } else {
            image_to_write = image.convertToFormat(QImage::Format_RGB32);
        }
    }

    return writer.write(image_to_write);
}
