// Qt
#include <QFileInfo>
#include <QUrl>

// GDAL
#include <gdal_priv.h>

// Project
#include "MetadataListModel.h"

//****************************************************************************

MetadataListModel::MetadataListModel(QObject * parent) :
    QAbstractListModel(parent)
{
    GDALAllRegister();
}

//****************************************************************************

MetadataListModel::~MetadataListModel()
{
    GDALDestroyDriverManager();
}

//****************************************************************************

int MetadataListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return _metadata.count();
}

//****************************************************************************

QVariant MetadataListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= _metadata.count())
        return QVariant();

    const MetadataItem & item = _metadata[index.row()];
    if (role == NameRole)
        return item.getName();
    else if (role == ValueRole)
        return item.getValue();

    return QVariant();
}

//****************************************************************************

QHash<int, QByteArray> MetadataListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[ValueRole] = "value";
    return roles;
}

//****************************************************************************
namespace {
void fetchMetadata(GDALDataset * dataset, QList<MetadataItem> &metadata);
}

bool MetadataListModel::read(const QUrl &path)
{
    beginResetModel();

    _metadata.clear();
    QString filename = QFileInfo(path.toLocalFile()).absoluteFilePath();
    GDALDataset * dataset = static_cast<GDALDataset*>(GDALOpen(filename.toStdString().c_str(), GA_ReadOnly));
    if (!dataset)
    {
        _errorMessage = QString(CPLGetLastErrorMsg());
        return false;
    }
    fetchMetadata(dataset, _metadata);
    GDALClose(dataset);

    endResetModel();
    return true;
}

//****************************************************************************

void MetadataListModel::clear()
{
    beginResetModel();
    _metadata.clear();
    _errorMessage.clear();
    endResetModel();
}

//****************************************************************************
namespace{
//****************************************************************************

void fetchMetadata(char ** papszMetadata, QList<MetadataItem> &metadata)
{
    CPLStringList list(papszMetadata, false);
    for( int i = 0; i < list.size(); i++ )
    {
        char * name = 0;
        const char * value = CPLParseNameValue(list[i], &name);
        CPLValueType type = CPLGetValueType(value);
        size_t len = CPLStrnlen(value, (size_t) 2);
        if (len == 1)
        {
            metadata << MetadataItem(QString(name), QString::number((uint)value[0]));
        }
        else
        {
            metadata << MetadataItem(QString(name), QString(value));
        }

//        QString line = QString::fromUtf8(papszMetadata[i]);
//        qDebug("line: %s", line.toStdString().c_str());
    }
}

//****************************************************************************

void fetchMetadata(GDALDataset * dataset, QList<MetadataItem> &metadata)
{
    // get metadata from the subsets
    char **papszSubdatasets = GDALGetMetadata(dataset, "SUBDATASETS");
    int nSubdatasets = CSLCount(papszSubdatasets);
    if (nSubdatasets != 0)
    {
        for (int i=0; i<nSubdatasets; i+=2)
        {
            QString subsetName=papszSubdatasets[i];
            subsetName = subsetName.section("=",1);
            QString subsetDescription=papszSubdatasets[i+1];
            subsetDescription = subsetDescription.section("=", 1);
            // test if subset is not a QuickLook :
            if (!subsetDescription.contains("QLK", Qt::CaseInsensitive))
            {
                GDALDataset * dataset = static_cast<GDALDataset*>(GDALOpen(subsetName.toStdString().c_str(), GA_ReadOnly));
                if (!dataset)
                {
                    qDebug("Failed to open file '%s'", subsetName);
                    continue;
                }
                fetchMetadata(dataset, metadata);
                GDALClose(dataset);
            }
        }
    }
    else
    {
        char ** papszMetadata = dataset->GetMetadata();
        if( CSLCount(papszMetadata) > 0 )
        {
            fetchMetadata(papszMetadata, metadata);
        }

        papszMetadata = dataset->GetMetadata("GEOLOCATION");
        if( CSLCount(papszMetadata) > 0 )
        {
            fetchMetadata(papszMetadata, metadata);
        }

        // get metadata from bands:
        int nbBands = dataset->GetRasterCount();
        for (int i=0; i<nbBands; i++)
        {
            GDALRasterBand * poBand = dataset->GetRasterBand(i+1);
            if (poBand == 0)
            {
                continue;
            }
            char ** papszBandMetadata = poBand->GetMetadata();
            if (CSLCount(papszBandMetadata) > 0)
            {
                fetchMetadata(papszBandMetadata, metadata);
            }
        }
    }
}
//****************************************************************************
}
//****************************************************************************
