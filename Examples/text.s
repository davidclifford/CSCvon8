start:
    STO 0 __sypos
    STO 0 __sxpos
    LCA $07
    STO A __sink
    LHA mess
    STO A pos2
    LCB mess
    STO B pos
2:
    LAI pos2,B
    JAZ 1f
    STO A __schar
    LCB ' '
    JEQ 4f
    LCB '\n'
    JEQ 4f
5:
    JSR sys_spchar sys_spchar_ret
    LDB pos
    LDB B+1
    STO B pos
    JBZ 3f
    JMP 2b
1:
    JMP sys_cli
3:
    LDA pos2
    STO A+1 pos2
    JMP 2b
4:
    LDA __sink
    LDA A+1
    LCB $07
    LDA A&B
    STO A __sink
    JMP 5b

PAG
pos:    BYTE
pos2:   BYTE
mess:   STR "To be, or not to be, that is the question\nWhether 'tis nobler in the mind to suffer\nThe slings and arrows of outrageous fortune,\nOr to take Arms against a Sea of troubles,\nAnd by opposing end them to die, to sleep\nNo more and by a sleep, to say we end\nThe heart-ache, and the thousand natural shocks\nThat Flesh is heir to? 'Tis a consummation\nDevoutly to be wished. To die, to sleep,\nTo sleep, perchance to Dream aye, there's the rub,\nFor in that sleep of death, what dreams may come,\nWhen we have shuffled off this mortal coil,\nMust give us pause. There's the respect\nThat makes Calamity of so long life\nFor who would bear the Whips and Scorns of time,\nThe Oppressor's wrong, the proud man's Contumely,\nThe pangs of dispised Love, the Laws delay,\nThe insolence of Office, and the spurns\nThat patient merit of the unworthy takes,\nWhen he himself might his Quietus make\nWith a bare Bodkin? Who would Fardels bear,\nTo grunt and sweat under a weary life,\nBut that the dread of something after death,\nThe undiscovered country, from whose bourn\nNo traveller returns, puzzles the will,\nAnd makes us rather bear those ills we have,\nThan fly to others that we know not of.\nThus conscience does make cowards of us all,\nAnd thus the native hue of Resolution\nIs sicklied o'er, with the pale cast of Thought, ..."

#include "monitor.h"