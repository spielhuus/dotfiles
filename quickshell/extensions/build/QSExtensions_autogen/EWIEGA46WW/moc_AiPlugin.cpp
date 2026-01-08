/****************************************************************************
** Meta object code from reading C++ file 'AiPlugin.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../AiPlugin.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'AiPlugin.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.10.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN8AiPluginE_t {};
} // unnamed namespace

template <> constexpr inline auto AiPlugin::qt_create_metaobjectdata<qt_meta_tag_ZN8AiPluginE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "AiPlugin",
        "QML.Element",
        "auto",
        "streamReceived",
        "",
        "content",
        "streamFinished",
        "streamError",
        "error",
        "onReadyRead",
        "onReplyFinished",
        "generateText",
        "prompt",
        "parseChat",
        "QVariantMap",
        "createChatFile",
        "path",
        "config",
        "QVariantList",
        "messages",
        "appendMessage",
        "role",
        "createChatPayload",
        "settings",
        "sendChatRequest",
        "url",
        "payload",
        "apiKey",
        "cancelRequest"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'streamReceived'
        QtMocHelpers::SignalData<void(QString)>(3, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 5 },
        }}),
        // Signal 'streamFinished'
        QtMocHelpers::SignalData<void()>(6, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'streamError'
        QtMocHelpers::SignalData<void(QString)>(7, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 },
        }}),
        // Slot 'onReadyRead'
        QtMocHelpers::SlotData<void()>(9, 4, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onReplyFinished'
        QtMocHelpers::SlotData<void()>(10, 4, QMC::AccessPrivate, QMetaType::Void),
        // Method 'generateText'
        QtMocHelpers::MethodData<QString(const QString &)>(11, 4, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 12 },
        }}),
        // Method 'parseChat'
        QtMocHelpers::MethodData<QVariantMap(const QString &)>(13, 4, QMC::AccessPublic, 0x80000000 | 14, {{
            { QMetaType::QString, 5 },
        }}),
        // Method 'createChatFile'
        QtMocHelpers::MethodData<bool(const QString &, const QVariantMap &, const QVariantList &)>(15, 4, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 16 }, { 0x80000000 | 14, 17 }, { 0x80000000 | 18, 19 },
        }}),
        // Method 'appendMessage'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &)>(20, 4, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 16 }, { QMetaType::QString, 21 }, { QMetaType::QString, 5 },
        }}),
        // Method 'createChatPayload'
        QtMocHelpers::MethodData<QString(const QVariantMap &, const QVariantList &)>(22, 4, QMC::AccessPublic, QMetaType::QString, {{
            { 0x80000000 | 14, 23 }, { 0x80000000 | 18, 19 },
        }}),
        // Method 'sendChatRequest'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &)>(24, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 25 }, { QMetaType::QString, 26 }, { QMetaType::QString, 27 },
        }}),
        // Method 'sendChatRequest'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(24, 4, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 25 }, { QMetaType::QString, 26 },
        }}),
        // Method 'cancelRequest'
        QtMocHelpers::MethodData<void()>(28, 4, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    QtMocHelpers::UintData qt_constructors {};
    QtMocHelpers::ClassInfos qt_classinfo({
            {    1,    2 },
    });
    return QtMocHelpers::metaObjectData<AiPlugin, void>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums, qt_constructors, qt_classinfo);
}
Q_CONSTINIT const QMetaObject AiPlugin::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8AiPluginE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8AiPluginE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN8AiPluginE_t>.metaTypes,
    nullptr
} };

void AiPlugin::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<AiPlugin *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->streamReceived((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 1: _t->streamFinished(); break;
        case 2: _t->streamError((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 3: _t->onReadyRead(); break;
        case 4: _t->onReplyFinished(); break;
        case 5: { QString _r = _t->generateText((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 6: { QVariantMap _r = _t->parseChat((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->createChatFile((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QVariantMap>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[3])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 8: { bool _r = _t->appendMessage((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 9: { QString _r = _t->createChatPayload((*reinterpret_cast<std::add_pointer_t<QVariantMap>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 10: _t->sendChatRequest((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3]))); break;
        case 11: _t->sendChatRequest((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 12: _t->cancelRequest(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (AiPlugin::*)(QString )>(_a, &AiPlugin::streamReceived, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (AiPlugin::*)()>(_a, &AiPlugin::streamFinished, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (AiPlugin::*)(QString )>(_a, &AiPlugin::streamError, 2))
            return;
    }
}

const QMetaObject *AiPlugin::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *AiPlugin::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8AiPluginE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int AiPlugin::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 13)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 13;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 13)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 13;
    }
    return _id;
}

// SIGNAL 0
void AiPlugin::streamReceived(QString _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1);
}

// SIGNAL 1
void AiPlugin::streamFinished()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void AiPlugin::streamError(QString _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1);
}
QT_WARNING_POP
