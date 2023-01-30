      /IF NOT DEFINED(COZTOOLS_FKEYS)
      /DEFINE COZTOOLS_FKEYS

      /IF NOT DEFINED(IQUERY)
      /IF DEFINED(SYSEXITKEY)
     D getExitKey      PR             1A   extProc('COZZI_getExitFkey')
     D  rtnF3                         1A   OPTIONS(*NOPASS:*OMIT)
     D  rtnF12                        1A   OPTIONS(*NOPASS:*OMIT)

     D setExitKey      PR                  extProc('COZZI_setExitFkey')
     D  exitkey                      10A   OPTIONS(*VARSIZE:*NOPASS:*OMIT)
     D                                      Const
      /ENDIF
      /ELSE
      /DEFINE IQUERY_FKEYS
      /ENDIF

      **********************************************************
      ** (c) Copyright 1989 - 2003 by Robert Cozzi, Jr.
      **********************************************************
      **             COZTOOLS - Cozzi Tools                   **
      **      -----------------------------------------       **
      **  Description  . . . . . Function key named constants **
      **                                                      **
      **  Features . . . . . . . The Attention ID Byte        **
      **                         for each function key        **
      **                         is defined here.             **
      **                                                      **
      **********************************************************
      /IF NOT DEFINED(NO_FKEY_CONST)
      /DEFINE NO_FKEY_CONST
     D F1              C                   CONST(X'31')
     D F2              C                   CONST(X'32')
     D F3              C                   CONST(X'33')
     D F4              C                   CONST(X'34')
     D F5              C                   CONST(X'35')
     D F6              C                   CONST(X'36')
     D F7              C                   CONST(X'37')
     D F8              C                   CONST(X'38')
     D F9              C                   CONST(X'39')
     D F10             C                   CONST(X'3A')
     D F11             C                   CONST(X'3B')
     D F12             C                   CONST(X'3C')
     D F13             C                   CONST(X'B1')
     D F14             C                   CONST(X'B2')
     D F15             C                   CONST(X'B3')
     D F16             C                   CONST(X'B4')
     D F17             C                   CONST(X'B5')
     D F18             C                   CONST(X'B6')
     D F19             C                   CONST(X'B7')
     D F20             C                   CONST(X'B8')
     D F21             C                   CONST(X'B9')
     D F22             C                   CONST(X'BA')
     D F23             C                   CONST(X'BB')
     D F24             C                   CONST(X'BC')
     D CLEAR           C                   CONST(X'BD')
     D ENTER           C                   CONST(X'F1')
     D HELP            C                   CONST(X'F3')
     D PAGEUP          C                   CONST(X'F4')
     D PAGEDN          C                   CONST(X'F5')
     D PAGEDOWN        C                   CONST(X'F5')
     D ROLLDN          C                   CONST(X'F4')
     D ROLLUP          C                   CONST(X'F5')
     D PRINTKEY        C                   CONST(X'F6')
     D RCBKSP          C                   CONST(X'F8')
     D AUTENT          C                   CONST(X'3F')
      /ENDIF

      /if NOT DEFINED(NO_FN_KEYS)
      /DEFINE NO_FN_KEYS

     D fn              DS                  Qualified
     D F1                             1A   INZ(X'31')
     D F2                             1A   INZ(X'32')
     D F3                             1A   INZ(X'33')
     D F4                             1A   INZ(X'34')
     D F5                             1A   INZ(X'35')
     D F6                             1A   INZ(X'36')
     D F7                             1A   INZ(X'37')
     D F8                             1A   INZ(X'38')
     D F9                             1A   INZ(X'39')
     D F10                            1A   INZ(X'3A')
     D F11                            1A   INZ(X'3B')
     D F12                            1A   INZ(X'3C')
     D F13                            1A   INZ(X'B1')
     D F14                            1A   INZ(X'B2')
     D F15                            1A   INZ(X'B3')
     D F16                            1A   INZ(X'B4')
     D F17                            1A   INZ(X'B5')
     D F18                            1A   INZ(X'B6')
     D F19                            1A   INZ(X'B7')
     D F20                            1A   INZ(X'B8')
     D F21                            1A   INZ(X'B9')
     D F22                            1A   INZ(X'BA')
     D F23                            1A   INZ(X'BB')
     D F24                            1A   INZ(X'BC')
     D CLEAR                          1A   INZ(X'BD')
     D ENTER                          1A   INZ(X'F1')
     D HELP                           1A   INZ(X'F3')
     D PAGEUP                         1A   INZ(X'F4')
     D PAGEDN                         1A   INZ(X'F5')
     D PAGEDOWN                       1A   INZ(X'F5')
     D ROLLDN                         1A   INZ(X'F4')
     D ROLLUP                         1A   INZ(X'F5')
     D PRINTKEY                       1A   INZ(X'F6')
     D PRINT                          1A   INZ(X'F6')
     D RCBKSP                         1A   INZ(X'F8')
     D AUTENT                         1A   INZ(X'3F')
      /ENDIF

      /ENDIF