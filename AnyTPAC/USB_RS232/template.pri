#
# @file
#
# @section LICENSE
# Copyright Mect s.r.l. 2013
#
# @brief Qmake project file for TP1057_01_A
#

contains(QMAKE_HOST.os,Windows){
        QT_ROOTFS = C:/Qt485/imx28/rootfs
        QT_LUPDATE_PATH = C:/Qt485/desktop/bin
        QT_LRELEASE_PATH = C:/Qt485/imx28/qt-everywhere-opensource-src-4.8.5/bin
        ATCM_TEMPLATE_BASE_DIR = C:/Qt485/desktop/share/qtcreator/templates/wizards
}
!contains(QMAKE_HOST.os,Windows){
        QT_ROOTFS=$$(MECT_RFSDIR)
        QT_LUPDATE_PATH = 
        QT_LRELEASE_PATH = $$(MECT_QT_INSTALL_DIR)/bin
        ATCM_TEMPLATE_BASE_DIR = 
}

isEmpty(QT_ROOTFS) {
        error(QT_ROOTFS is empty)
}
isEmpty(QT_LUPDATE_PATH) {
        warning(QT_LUPDATE_PATH is empty)
}
isEmpty(QT_LRELEASE_PATH) {
        warning(QT_LRELEASE_PATH is empty)
}
isEmpty(ATCM_TEMPLATE_BASE_DIR) {
        warning(ATCM_TEMPLATE_BASE_DIR is empty)
}

ATCM_ARM_LIBRARY_LIBPATH = $$QT_ROOTFS/usr/lib
ATCM_ARM_PLUGINS_LIBPATH = $$QT_ROOTFS/usr/lib
ATCM_ARM_LIBRARY_INCPATH = $$QT_ROOTFS/usr/include
ATCM_ARM_PLUGINS_INCPATH = $$QT_ROOTFS/usr/include

QMAKE_CXXFLAGS_RELEASE -= -O2
QMAKE_CXXFLAGS_RELEASE += -O3
QMAKE_CXXFLAGS_RELEASE += -Wno-psabi
QMAKE_CXXFLAGS_DEBUG   += -Wno-psabi

TARGET = hmi
TEMPLATE = app

target.path = /local/root
INSTALLS += target

config.files = config/Crosstable.csv config/system.ini
config.path = /local/etc/sysconfig

splash.files = config/splash.png
splash.path = /local/etc/sysconfig/img

customtrend.files = config/trend1.csv
customtrend.path = /local/data/customtrend

INSTALLS += config splash

INSTALLS += customtrend

DEFINES+=ENABLE_STORE
DEFINES+=ENABLE_ALARMS
DEFINES+=ENABLE_TREND
DEFINES+=ENABLE_RECIPE

DEFINES += TRANSLATION

INCLUDEPATH += .\
	./config

LIBS += \
-lts \
-lqwt \
-lATCMcommon \
-lATCMutility \
-lATCMcommunication \
-lATCMplugin \
-lATCMinputdialog \
-lATCMlogger \
-lATCMstore \
-lATCMalarms \
-lATCMrecipe \
-lATCMtrend \
-lATCMsystem

# Input
HEADERS += \
        config/crosstable.h \
        style.h \
        pages.h

SOURCES += \
        config/crosstable.cpp \
        pages.cpp

!isEmpty(ATCM_TEMPLATE_BASE_DIR) {
	# pre-elaboration
	check_missing_file.commands = @perl $${ATCM_TEMPLATE_BASE_DIR}/ATCM-template-project/cleanmissingpage.pl $$_PRO_FILE_ $$_PRO_FILE_PWD_
	check_undeclared_variable.commands = @perl $${ATCM_TEMPLATE_BASE_DIR}/ATCM-template-project/check_cross_var.pl $$_PRO_FILE_PWD_
	check_gotopage_bind.commands = @perl $${ATCM_TEMPLATE_BASE_DIR}/ATCM-template-project/connectbutton.pl $$_PRO_FILE_PWD_
	check_systemini.commands = @perl $${ATCM_TEMPLATE_BASE_DIR}/ATCM-template-project/check_systemini.pl $$_PRO_FILE_ $$_PRO_FILE_PWD_

	QMAKE_EXTRA_TARGETS += check_missing_file check_undeclared_variable check_gotopage_bind check_systemini
	PRE_TARGETDEPS += check_missing_file check_undeclared_variable check_gotopage_bind check_systemini
}

# language
!isEmpty(QT_LUPDATE_PATH) {
update.commands = $${QT_LUPDATE_PATH}/lupdate $$_PRO_FILE_
updates.depends = $$SOURCES $$HEADERS $$FORMS $$TRANSLATIONS
release.depends = update
        QMAKE_EXTRA_TARGETS += update
        PRE_TARGETDEPS += update
}
!isEmpty(QT_LRELEASE_PATH) {
        release.commands = $${QT_LRELEASE_PATH}/lrelease $$_PRO_FILE_
        QMAKE_EXTRA_TARGETS += release
        PRE_TARGETDEPS += release
}

RESOURCES += \
    languages.qrc

OTHER_FILES += \
    languages_it.ts \
    languages_en.ts

include(./languages.pri)

TYPE = "AnyTPAC"

# display size
MODEL = "<width>480</width><height>272</height>"

equals(MODEL, "<width>320</width><height>240</height>") {
    DEFINES+=WIDTH=320
    DEFINES+=HEIGHT=240
    DEFINES+=ROTATION=0
}
equals(MODEL, "<width>240</width><height>320</height>") {
    DEFINES+=WIDTH=240
    DEFINES+=HEIGHT=320
    DEFINES+=ROTATION=90
}
equals(MODEL, "<width>480</width><height>272</height>") {
    DEFINES+=WIDTH=480
    DEFINES+=HEIGHT=272
    DEFINES+=ROTATION=0
}
equals(MODEL, "<width>272</width><height>480</height>") {
    DEFINES+=WIDTH=272
    DEFINES+=HEIGHT=480
    DEFINES+=ROTATION=90
}
equals(MODEL, "<width>800</width><height>480</height>") {
    DEFINES+=WIDTH=800
    DEFINES+=HEIGHT=480
    DEFINES+=ROTATION=0
}
equals(MODEL, "<width>480</width><height>800</height>") {
    DEFINES+=WIDTH=240
    DEFINES+=HEIGHT=240
    DEFINES+=ROTATION=90
}

