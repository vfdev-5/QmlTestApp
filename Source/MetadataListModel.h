#ifndef METADATALISTMODEL_H
#define METADATALISTMODEL_H

#include <QAbstractListModel>

//****************************************************************************

class MetadataItem {

public:
    MetadataItem(const QString & name, const QString & value) :
        _name(name), _value(value)
    {}

    QString getName() const
    { return _name; }

    QString getValue() const
    { return _value; }

protected:
    QString _name;
    QString _value;


};

class MetadataListModel : public QAbstractListModel
{
    Q_OBJECT

public:

    enum Roles {
        NameRole = Qt::UserRole + 1,
        ValueRole
    };

    explicit MetadataListModel(QObject *parent = 0);
    ~MetadataListModel();

    Q_INVOKABLE bool read(const QUrl &filename);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QString errorMessage() const
    { return _errorMessage; }

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<MetadataItem> _metadata;
    QString _errorMessage;
};

//****************************************************************************


#endif // METADATALISTMODEL_H
