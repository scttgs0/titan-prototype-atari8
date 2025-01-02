
mkdir -p obj/

# -------------------------------------

64tass  --m65xx \
        --atari-xex \
        -o obj/animat1.bin \
        --list=obj/animat1.lst \
        --labels=obj/animat1.lbl \
        data/animat1.inc

64tass  --m65xx \
        --atari-xex \
        -o obj/animat2.bin \
        --list=obj/animat2.lst \
        --labels=obj/animat2.lbl \
        data/animat2.inc

64tass  --m65xx \
        --atari-xex \
        -o obj/craters.bin \
        --list=obj/craters.lst \
        --labels=obj/craters.lbl \
        data/craters.inc

64tass  --m65xx \
        --atari-xex \
        -o obj/mntns.bin \
        --list=obj/mntns.lst \
        --labels=obj/mntns.lbl \
        data/mntns.inc

64tass  --m65xx \
        --atari-xex \
        -o obj/saturn.bin \
        --list=obj/saturn.lst \
        --labels=obj/saturn.lbl \
        data/saturn.inc

# -------------------------------------

64tass  --m65xx \
        --atari-xex \
        --nostart \
        -o obj/bootstrap.bin \
        --list=obj/bootstrap.lst \
        --labels=obj/bootstrap.lbl \
        bootstrap.asm

64tass  --m65xx \
        --atari-xex \
        -o obj/titan.xex \
        --list=obj/titan.lst \
        --labels=obj/titan.lbl \
        titan.asm
