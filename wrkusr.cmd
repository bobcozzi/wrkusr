 WRKUSR:     CMD        PROMPT('Work with User Profiles')
             PARM       KWD(USRPRF) TYPE(*GENERIC) LEN(10) +
                          DFT(*NONIBM) SPCVAL((*ALL) (*ALLUSR *NONIBM) +
                          (*ALLSYS *IBM) (*NONIBM) (*IBM)) +
                          EXPR(*YES) PROMPT('User profile')