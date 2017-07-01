#ifndef SCORE_H
#define SCORE_H
#include <QObject>
class Score:public QObject{
    Q_OBJECT
public:
    Score(QObject *parent = 0);
    Q_INVOKABLE int calculate(int totalscore,int linelevel);


};

#endif // SCORE_H
