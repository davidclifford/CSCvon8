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
    STO 0 colour
9:
    STO 0 y
7:
    LDB 0
    STI 0 y,B
    LDB B+1
    STI 0 y,B
    LDB B+1
    STI 0 y,B
    LDA colour
    STO A+1 colour
    LCB $3f
    LDA A&B
    LCB $40
    LDA A|B
    LCB @2
    STI A y,B
    LDA y
    STO A+1 y
    LCB @119
    JNE 7b
8:
    LDA 0
    LDB 0
10:
    LDA A+1
    JAZ 11f
    JMP 10b
11:
    LDB B+1
    JBZ 9b
    JMP 10b
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
y:      BYTE
colour: BYTE
mess:   STR " To be, or not to be, that is the question\n Whether 'tis nobler in the mind to suffer\n The slings and arrows of outrageous fortune,\n Or to take Arms against a Sea of troubles,\n And by opposing end them to die, to sleep\n No more and by a sleep, to say we end\n The heart-ache, and the thousand natural shocks\n That Flesh is heir to? 'Tis a consummation\n Devoutly to be wished. To die, to sleep,\n To sleep, perchance to Dream aye, there's the rub,\n For in that sleep of death, what dreams may come,\n When we have shuffled off this mortal coil,\n Must give us pause. There's the respect\n That makes Calamity of so long life\n For who would bear the Whips and Scorns of time,\n The Oppressor's wrong, the proud man's Contumely,\n The pangs of dispised Love, the Laws delay,\n The insolence of Office, and the spurns\n That patient merit of the unworthy takes,\n When he himself might his Quietus make\n With a bare Bodkin? Who would Fardels bear,\n To grunt and sweat under a weary life,\n But that the dread of something after death,\n The undiscovered country, from whose bourn\n No traveller returns, puzzles the will,\n And makes us rather bear those ills we have,\n Than fly to others that we know not of.\n Thus conscience does make cowards of us all,\n And thus the native hue of Resolution\n Is sicklied o'er, with the pale cast of Thought, ..."

#include "monitor.h"