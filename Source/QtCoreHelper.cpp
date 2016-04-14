
// Qt
#include <QFileInfo>
#include <QClipboard>
#include <QApplication>

// Project
#include "QtCoreHelper.h"

//****************************************************************************

QString QtCoreHelper::absoluteFilePath(const QString & path) const
{
    QFileInfo fi(path);
    return fi.absoluteFilePath();
}

//****************************************************************************

QString QtCoreHelper::absoluteFilePathFromUrl(const QUrl &url) const
{
    return absoluteFilePath(url.toLocalFile());
}

//****************************************************************************

bool QtCoreHelper::clipboardCopy(const QString &data)
{
    QClipboard *clipboard = QApplication::clipboard();
    if (!clipboard) return false;

    clipboard->setText(data);
    return true;
}

//****************************************************************************
