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

#ifndef PNGWRITER_H
#define PNGWRITER_H

#include <QString>
#include <QImage>

class PngWriter
{
public:
    /**
     * \brief Writes a QImage to a PNG file.
     *
     * \param file_path The file to write to. If the file exists, it will be overwritten.
     * \param image The image to write. If it's null, false is returned.
     * \param compression_level The compression level (0-9). 0 for no compression, 9 for maximum compression. Default is -1 (Qt's default).
     * \return True on success, false on failure.
     */
    static bool writeImage(QString const& file_path, QImage const& image, int compression_level = -1);
};

#endif // PNGWRITER_H
