/**
 * @file
 * @author Emiliano Bergamaschini <ebergamaschini@mect.it>
 *
 * @section LICENSE
 * Copyright Mect s.r.l. 2013
 *
 * @brief Main page
 */
#ifndef PAGE100_H
#define PAGE100_H

#include "pagebrowser.h"

namespace Ui {
class page100;
}

class page100 : public page
{
    Q_OBJECT
    
public:
    explicit page100(QWidget *parent = 0);
    ~page100();
    virtual void reload(void);
    virtual void updateData();

    char *ntpServer(char *buffer, int size);
    void append(const char *text);
    void erase();

private slots:
    void changeEvent(QEvent * event);
    void on_atcmButton_clicked();

private:
    Ui::page100 *ui;
};

#endif // PAGE100_H

