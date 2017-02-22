/**
 * @file
 * @author Emiliano Bergamaschini <ebergamaschini@mect.it>
 *
 * @section LICENSE
 * Copyright Mect s.r.l. 2013
 *
 * @brief Main page
 */
#ifndef PAGE300_H
#define PAGE300_H

#include "pagebrowser.h"

namespace Ui {
class page300;
}

class page300 : public page
{
    Q_OBJECT
    
public:
    explicit page300(QWidget *parent = 0);
    ~page300();
    virtual void reload(void);
    virtual void updateData();
    
private slots:
    void changeEvent(QEvent * event);
    void on_spinBox_valueChanged(int step);

    void on_comboBox_currentIndexChanged(const QString &recipe);

private:
    Ui::page300 *ui;

    int steps_number;
    int current_step;
    QList<u_int16_t> recipeIndexes;
    QList<u_int32_t> recipeTable[MAX_RCP_STEP];
    int do_write_step;
    bool justWroteRecipe;
};

#endif // PAGE300_H
