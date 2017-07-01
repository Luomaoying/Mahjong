#include "score.h"
Score::Score(QObject *parent):QObject(parent)
{

}
int Score::calculate(int totalscore,int linelevel)
{
        totalscore += linelevel * 350;
        return totalscore;
}
