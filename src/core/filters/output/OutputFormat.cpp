/*
    Scan Tailor - Interactive post-processing tool for scanned pages.
    Copyright (C)  Joseph Artsimovich <joseph.artsimovich@gmail.com>

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

#include "OutputFormat.h"
#include <QString>

namespace output
{

OutputFormat::Format
OutputFormat::DefaultFormat()
{
    return TIFF;
}

QString
OutputFormat::toString(Format format)
{
    switch (format) {
        case TIFF: return QStringLiteral("TIFF");
        case PNG: return QStringLiteral("PNG");
        default: return QStringLiteral("TIFF");
    }
}

OutputFormat::Format
OutputFormat::fromString(QString const& str)
{
    if (str.compare(QStringLiteral("PNG"), Qt::CaseInsensitive) == 0) {
        return PNG;
    }
    return TIFF;
}

} // namespace output
