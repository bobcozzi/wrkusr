
      *******************************************************
      * Program name: Work with User Profiles
      * Date        : 11/11/2020
      * Author      : R. Cozzi, Jr.
      *               (c) Copyright 2020 by R. Cozzi, Jr.
      *               All rights reserved.
      *               Public Use Granted provided this notice remains here.
      *
      *               Maintenance log
      *               ================
      *
      *******************************************************
       CTL-OPT
           copyright('(c) 2020 by R. Cozzi, Jr. All Right Reserved.')
      /if DEFINED(*CRTBNDRPG)
           DFTACTGRP(*NO)
      /endif
           OPTION(*NODEBUGIO:*SRCSTMT)
           EXTBININT(*YES) FIXNBR(*ZONED:*INPUTPACKED);

       dcl-f wrkusr workstn sfile(detail:RRN) indds(INDDS) infds(WSDS);

      /INCLUDE cozTools/qcpysrc,fKeys

         dcl-ds psds Qualified psds;
            pgmName *PROC;
         end-Ds;
         dcl-ds wsds Qualified;
           fKey   char(1) pos(369);
           sflRRN int(5)  pos(378);
         end-Ds;

         dcl-ds indds qualified;
           dspSFLctl ind pos(21);
           dspSFL    ind pos(22);
           posTo     ind pos(33);
           OPTMDT    ind pos(41);
           disabled  ind pos(43);
         end-Ds;

           dcl-s usrprf varchar(10) inz(*USER);

           dcl-ds filters Qualified Inz;
             usrprf   varchar(10);   // User Profile (generic, full, or *ALL)
             status   varchar(10);   // Enable/Disable Status
             attempts uns(5);        // Invalid SignOn Attempts
             inlMenu  varchar(10);   // Initial Menu Name
             inlPgm   varchar(10);   // Initial Program Name
             curlib   varchar(10);   // Current Library Name
             usrclass varchar(10);   // User Class (e.g., *PGMR *SECOFR, etc,
             grpprf   varchar(10);   // Group Profile
             supGroups  char(1);     // Also scan SUP Group Profiles
                                     // using the Group Profile filter.
             lastSignOn   uns(5);    // Days Since Last Sign On
             SupGrpPrfCnt uns(5);    // Number of SUP Group Profiles
           end-ds;

           dcl-c ALTMAX     const(4);  // Max Alternate Views implemented
           dcl-s altView    int(10) inz(1);
           dcl-s posToLen   int(10);
           dcl-s lastCSRPOS int(10);
           dcl-s usersCount int(10);

           dcl-s selUser varchar(11) inz('  ');  // 2-blanks is different
                                                 // than empty in varchar
           dcl-s bGrantAut  ind inz(*OFF);
           dcl-s bRevokeAut ind inz(*OFF);
           dcl-s userList   varchar(1024);

            dcl-c S_IRUSR const(x'0400');
            dcl-c S_IWUSR const(x'0200');
            dcl-c S_IXUSR const(x'0100');
            dcl-s S_IRWXU uns(5);

            dcl-c S_IRGRP const(x'0040');
            dcl-c S_IWGRP const(x'0020');
            dcl-c S_IXGRP const(x'0010');
            dcl-s S_IRWXG uns(5);

            dcl-c S_IROTH const(x'0004');
            dcl-c S_IWOTH const(x'0002');
            dcl-c S_IXOTH const(x'0001');
            dcl-s S_IRWXO uns(5);

            dcl-s S_IALL uns(5);
            dcl-s mode_t uns(10);
            dcl-s rc int(10);

            dcl-pr makedir int(10) extproc(*CWIDEN:'mkdir') ;
              newPath pointer Value OPTIONS(*STRING:*TRIM);
              mode    uns(10) Value;
            end-pr;
            dcl-pr errNo pointer  extProc(*CWIDEN:'__errno') end-pr;

          dcl-s cmd varchar(2048) inz;
          dcl-pr system extproc(*CWIDEN:'system');
              CL_command pointer value OPTIONS(*STRING:*TRIM);
          end-pr;

             ///////////////////////////////////////////////////////
             // USER_INFO_T is a data structure template that was created
             // by SQL iQuery. it contains all the column definitions
             // for the USER_INFO resultSet. Not all columns are
             // returned by this subprocedure, however all column
             // definitions are represented in this template.
             ///////////////////////////////////////////////////////
           dcl-ds USER_INFO_T Qualified Template Inz;
             USER_PROFILE varchar(10);
             PREVIOUS_SIGNON timestamp;
             SIGN_ON_ATTEMPTS_NOT_VALID int(10);
             STATUS varchar(10);
             PASSWORD_CHANGE_DATE timestamp;
             NO_PASSWORD_INDICATOR varchar(3);
             PASSWORD_LEVEL_0_1 varchar(3);
             PASSWORD_LEVEL_2_3 varchar(3);
             PASSWORD_EXPIRATION_INTERVAL int(5);
             DATE_PASSWORD_EXPIRES timestamp;
             DAYS_UNTIL_PASSWORD_EXPIRES int(10);
             SET_PASSWORD_TO_EXPIRE varchar(3);
             USER_CLASS_NAME varchar(10);
             SPECIAL_AUTHORITIES varchar(88);
             GROUP_PROFILE_NAME varchar(10);
             SUP_GROUP_COUNT int(5);
             SUP_GROUPS_LIST varchar(150);
             OWNER varchar(10);
             GROUP_AUTH      varchar(10);
             ASSISTANCE_LEVEL varchar(10);
             CURRENT_LIBRARY_NAME varchar(10);
             INITIAL_MENU_NAME varchar(10);
             INITIAL_MENU_LIBRARY_NAME varchar(10);
             INITIAL_PROGRAM_NAME varchar(10);
             INITIAL_PROGRAM_LIBRARY_NAME varchar(10);
             LIMIT_CAPABILITIES varchar(10);
             TEXT_DESCRIPTION varchar(50);
             DISPLAY_SIGNON_INFORMATION varchar(10);
             LIMIT_DEVICE_SESSIONS varchar(10);
             KEYBOARD_BUFFERING varchar(10);
             MAXIMUM_ALLOWED_STORAGE int(20);
             STORAGE_USED int(20);
             HIGHEST_SCHEDULING_PRIORITY char(1);
             JOB_DESCRIPTION_NAME varchar(10);
             JOB_DESCRIPTION_LIBRARY_NAME varchar(10);
             ACCOUNTING_CODE varchar(15);
             MESSAGE_QUEUE_NAME varchar(10);
             MESSAGE_QUEUE_LIBRARY_NAME varchar(10);
             MESSAGE_QUEUE_DELIVERY_METHOD varchar(10);
             MESSAGE_QUEUE_SEVERITY int(5);
             OUTPUT_QUEUE_NAME varchar(10);
             OUTPUT_QUEUE_LIBRARY_NAME varchar(10);
             PRINT_DEVICE varchar(10);
             SPECIAL_ENVIRONMENT varchar(10);
             ATTENTION_KEY_HANDLING_PROGRAM_NAME varchar(10);
             ATTENTION_KEY_HANDLING_PROGRAM_LIBRARY_NAME varchar(10);
             LANGUAGE_ID varchar(10);
             COUNTRY_OR_REGION_ID varchar(10);
             CHARACTER_CODE_SET_ID varchar(6);
             USER_OPTIONS varchar(77);
             SORT_SEQUENCE_TABLE_NAME varchar(10);
             SORT_SEQUENCE_TABLE_LIBRARY_NAME varchar(10);
             OBJECT_AUDITING_VALUE varchar(10);
             USER_ACTION_AUDIT_LEVEL varchar(341);
             GROUP_AUTH_TYPE varchar(10);
             USER_ID_NUMBER int(20);
             GROUP_ID_NUMBER int(20);
             LOCALE_JOB_ATTRIBUTES varchar(88);
             GROUP_MEMBER_INDICATOR varchar(3);
             DIGITAL_CERTIFICATE_INDICATOR varchar(3);
             CHARACTER_IDENTIFIER_CONTROL varchar(10);
             LOCAL_PASSWORD_MANAGEMENT varchar(3);
             BLOCK_PASSWORD_CHANGE varchar(10);
             USER_ENTITLEMENT_REQUIRED varchar(3);
             USER_EXPIRATION_INTERVAL int(5);
             USER_EXPIRATION_DATE timestamp;
             USER_EXPIRATION_ACTION varchar(8);
             USER_DEFAULT_PASSWORD varchar(3);
             USER_OWNER varchar(10);
             USER_CREATOR varchar(10);
             crtSysName  varchar(8);
             SIZE packed(15:0);
             CREATION_TIMESTAMP timestamp;
             LAST_USED_TIMESTAMP timestamp;
             DAYS_USED_COUNT int(10);
             LAST_RESET_TIMESTAMP timestamp;
             AUTHORITY_COLLECTION_ACTIVE varchar(3);
             AUTHORITY_COLLECTION_REPOSITORY_EXISTS varchar(3);
             PASE_SHELL_PATH varchar(1024) ccsid(1208);
           end-ds;

           dcl-ds ui likeDS(USER_INFO_T) Inz;

           dcl-s homeDir varchar(1024);


          dcl-ds ec_t Qualified Template Inz;
            length         int(10);
            bytesReturned  int(10);
            exceptionID    char(7);
            reserved       char(1);
            exceptionData  char(512);
          end-Ds;

          dcl-s repeat varchar(2);
          dcl-s i      int(10);

          dcl-s rrn    zoned(4:0);
          dcl-s csrpos zoned(4:0);
          dcl-s bRefresh ind inz(*OFF);

          dcl-pi entryPList EXTPGM('WRKUSR');
            inUsrPrf char(10) const options(*NOPASS);
          end-Pi;

          *INLR = *ON;

           EXEC SQL SET OPTION COMMIT = *NONE,
                               NAMING = *SYS,
                               CLOSQLCSR = *ENDMOD;

               // Set permission flags for creating the User's Home Folder
           S_IRWXU = %BITOR(S_IRUSR:S_IWUSR:S_IXUSR);
           S_IRWXG = %BITOR(S_IRGRP:S_IWGRP:S_IXGRP);
           S_IRWXO = %BITOR(S_IROTH:S_IWOTH:S_IXOTH);
           S_IALL  = %BITOR(S_IRWXU:S_IRWXG:S_IRWXO);

           if (%Parms() >= %ParmNum(inUsrPrf));
             filters.usrprf = %trim(inUsrPrf);
           endIf;

           crtTables();

           bRefresh = *ON;
           csrPos = 0;
           rrn    = 0;

           DOW (wsds.fKey <> F3);
            if (bRefresh or wsds.fKey = F5);
               loadUsers();
               if (lastCSRPOS > 0);
                  csrPos = lastCSRPOS;
               endif;
            else;
               if (lastCSRPOS > 0);
                 csrPos = lastCSRPOS;
               else;
                 csrpos = csrRRN;
               endif;
            endif;


           pgmname = psds.pgmname;
           if (csrpos <= 0 or csrpos > usersCount);
             csrpos = 1;   // Put Cursor on line 1 of subfile
           endif;

           indds.dspsfl = (usersCount > 0);
           indds.dspsflCtl = *on;
           write footer;
           if (errMsg = '');
             if (posTo <> '');
               rrn = 1;
               posToLen = %len(%trimR(posTo));
               chain(e) rrn DETAIL;
               dow %FOUND();
                 if (%subst(userid:1:posToLen)= POSTO);
                    csrPOS = rrn; // Put Cursor on first Usrprf that matches POSTO
                    leave;
                 endIf;
                 rrn += 1;
                 chain(e) rrn DETAIL;
               endDo;
             endIf;
             errMsg = %char(rrn) + ' user profiles listed.';
           endIf;

           aTitle3 = 'Text description';
           if (altView <= 1);
             aTitle1 = 'Initial';
             aTitle2 = 'Menu';
           elseif (altView = 2);
             aTitle1 = 'Current';   // Need something other than this...
             aTitle2 = 'Library';
             aTitle3 = 'Home Directory';
           elseif (altView = 3);
             aTitle1 = 'Group';
             aTitle2 = 'Profile(s)';
             aTitle3 = 'Supplemental Group Profiles (or *TEXT)';
           elseif (altView = 4);
             aTitle1 = 'Created By';
             aTitle2 = 'User';
             aTitle3 = 'Creation Information';
           else;
             aTitle1 = 'Initial';
             aTitle2 = 'Menu';
             clear altView;
           endIf;

           if (usersCount <= 0);
             write clearSFL;
           endif;
             ///////////////////////////////////////////////////////
             // Display the List of user profiles
             ///////////////////////////////////////////////////////
           dou (wsds.fKey <> F9 and wsds.fKey <> F13);
             exfmt Display;
             indds.posTo = (wsds.fKey = F9);
             if (wsds.fKey = F13);  // Replicate option to end of list?
               i = csrrrn;   // check current line for option
               chain(e) i detail;
               if (%found() and userOpt = '' and csrrrn > 1);
                  i = csrrrn - 1;   // check prior line for option
                  chain(e) i Detail;
               endIf;
               if (%Found() and userOpt <> ' ');
                 csrPOS = i;   // Keep cursor on "this" line
                 csrrrn = i;   // first line to update is "this" line.
                 repeat = userOpt;
                 for I = csrrrn to 9999;
                   chain(e) i Detail;
                   if (%found() and userOpt='' or (i = csrrrn));
                      userOpt = repeat;
                      indds.disabled = hDisabled;
                      indds.OPTMDT = *ON;
                      update Detail;
                      indds.disabled = *OFF;
                      indds.OPTMDT = *OFF;
                   else;
                     leave;
                   endIf;
                 endFor;
               endIf;
             endIf;
           enddo;

           clear errMsg;

           if (wsds.fKey = F3);
             leave;
           endIf;

           if (wsds.fKey = F18);  // User Profile Filters?
             filterOptions();
             wsds.fKey = Enter;
             bRefresh = *ON;
             iter;
           endIf;

           if (posTo <> '');
             iter;
           endIf;


             // Alternate Views (information displayed)
           if (wsds.fKey = F10 or wsds.fKey = F11);

             if (wsds.fKey = F11);
               altView += 1;
             elseif (wsds.fKey = F10);
               altView -= 1;
             endif;

             if (altView > ALTMAX);
               altView = 1;
             elseif (altView < 1);
               altView = ALTMAX;
             endIf;

             bRefresh = *ON;
             iter;
           endIf;

                // Save the line number on which the Cursor is located
           bRefresh = *OFF;
           if (indds.dspsfl);
              csrpos = wsds.SFLRRN;
           else;
              csrpos = 1;
           endif;

                // Create New User Profile
           if (wsds.fKey = F6);  // Create new user profile?
             crtusrprf();
             bRefresh = *ON;
           endIf;

                // Process any line item Options entered by the User.
           IF  (wsds.fKey <> F3 and wsds.fKey <> F12);
                  // Read/process subfile options
                readc(e)  detail;
                dow NOT (%EOF() or wsds.fKey = F12 or wsds.fKey = F3);
                   if (userOpt <> '' );
                     lastCSRPOS = RRN;
                     userOpt = %trim(userOpt);
                   else;
                     lastCSRPOS = CSRRRN;
                   endif;
                   if (USEROPT = '2');  // Edit/Change
                      chgUsrPrf( userid );
                      bRefresh = *ON;
                   elseif (USEROPT = '3'); // Disable user profile
                      disableUsrprf( userID );
                      bRefresh = *ON;
                   elseif (USEROPT = '4'); // Delete User Profile
                      dltusrprf( userID );
                      errmsg = 'User Profiles are deleted +
                                after job QHXHDLTU completes.';
                      bRefresh = *ON;
                   elseif (USEROPT = '5'); // Display User Profile
                      dspusrprf( userID );
                   elseif (USEROPT = '6'); // Enable user profile
                      enableUsrprf( userID );
                      bRefresh = *ON;
                   elseif (USEROPT = '7'); // create home folder
                      crthomedir( userID );
                   elseif (USEROPT = '8'); // Work with User's SPOOLED Files
                      wrkusrSPLF( userID );
                   elseif (USEROPT = '18'); // Work with User's SPOOLED Files from today
                      wrkusrSPLF( userID : '1');
                   elseif (USEROPT = '12'); // Work with Owned Object
                      wrkownobj( userID );
                   elseif (USEROPT = '10'); // Work with User's Jobs
                      wrkusrjobs( userID );
                   elseif (USEROPT = '13'); // Change User Profile Text
                      chgUsrText( userID : hTextDesc );
                   elseif (USEROPT = '15'); // Grant User Authority to an Object
                      bGrantAut = *ON;
                      EXEC SQL INSERT INTO IQ_GRANT_AUT(userID)
                             values( :userID );
                   elseif (USEROPT = '14'); // Revoke User Authority to an Object
                      bRevokeAut = *ON;
                      EXEC SQL INSERT INTO IQ_REVOKE_AUT(userID)
                             values( :userID );
                   elseif (USEROPT <> ' ');
                     errMsg = 'Option ' + %trim(userOpt) + ' invalid.';
                     leave;
                   endif;

                   clear USEROPT;
                   if (wsds.fKey <> F3 and wsds.fKey <> F12);
                     indds.disabled = (hDisabled = '1');
                     update(e) detail;
                     readC(e)  detail;
                   endif;
                enddo;
                if (bRevokeAut);
                  rvkUsrAut();
                  bRevokeAut = *OFF;
                endIf;
                if (bGrantAut);
                  grtUsrAut();
                  bGrantAut = *OFF;
                endIf;
               endif;
             enddo;

             return;

             ///////////////////////////////////////////////////////
             // CRTTABLES creates a work file in QTEMP that contains
             // the names of the IBM User Profiles. We use this list
             // when comparing to Creator=IBM in the program.
             // It is used when *NONSYS or *ALLUSR is selected.
             ///////////////////////////////////////////////////////
           dcl-proc crtTables;
              dcl-s bExists ind inz(*OFF);
                EXEC SQL  DECLARE GLOBAL TEMPORARY TABLE IQ_IBM_PROFILES
                  (
                     USERID varchar(10)
                  ) with REPLACE;
                // Add the 3 IBM-related user profiles (there are others)
                 EXEC SQL INSERT INTO SESSION.IQ_IBM_PROFILES
                     VALUES ('*IBM'),('QLPINSTALL'),('QSYS');

                EXEC SQL  DECLARE GLOBAL TEMPORARY TABLE IQ_GRANT_AUT
                  (
                     USERID varchar(10)
                  ) with REPLACE;
                EXEC SQL  DECLARE GLOBAL TEMPORARY TABLE IQ_REVOKE_AUT
                  (
                     USERID varchar(10)
                  ) with REPLACE;
           end-Proc;

             ///////////////////////////////////////////////////////
             // CRTHOMEDIR creates a IFS folder in /home/<user profile>
             // The routine uses the CRTDIR CL command because
             // the 'mkdir' C-runtime procedure would not work.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc crthomedir;
             dcl-pi crthomedir;
               dcl-parm userprf varchar(10) const;
             end-Pi;
             dcl-s homePath varchar(2048);
             dcl-s pErrNo pointer;
             dcl-s errorNo int(10) based(pErrNo);

             homePath = '/home/' + %trim(userprf);
               cmd = 'crtdir dir(''' + %trimR(homePath) + ''')';
               if (wsds.fKey = F4);
                 cmd = '?' + %trimr(cmd);
               endIf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // WRKOBJOWN runs the CL WRKOBJOWN command for the user.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc wrkownobj;
             dcl-pi wrkownobj;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = 'WRKOBJOWN ' + userPrf;
               if (wsds.fKey = F4);
                 cmd = '?' + %trimr(cmd);
               endIf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // CHGUSRPRF runs the CL CHGUSRPRF command for the user.
             // The command is always prompted by this routine.
             ///////////////////////////////////////////////////////
           dcl-proc chgusrprf;
             dcl-pi chgusrprf;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = '?CHGUSRPRF ' + userPrf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // DSPUSRPRF runs the CL DSPUSRPRF command for the user.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc dspusrprf;
             dcl-pi dspusrprf;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = 'DSPUSRPRF ' + userPrf + ' TYPE(*BASIC)';
               if (wsds.fKey = F4);
                 cmd = '?' + %trimr(cmd);
               endIf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // DLTUSRPRF runs the CL DLTTUSRPRF command for the user.
             // The command is always prompted by this routine.
             ///////////////////////////////////////////////////////
           dcl-proc dltusrprf;
             dcl-pi dltusrprf;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = '?DLTUSRPRF ' + userPrf + ' OWNOBJOPT(*CHGOWN)';
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // CHGUSRTEXT runs the CL CHGUSRPRF command for the user.
             // It prompts only the TEXT and
             // The command is always prompted by this routine.
             ///////////////////////////////////////////////////////
           dcl-proc chgusrtext;
             dcl-pi chgusrtext;
               dcl-parm userprf varchar(10) const;
               dcl-parm userText varchar(150) const;
             end-Pi;
             dcl-s textDesc varchar(50);

               if (userText <> '');
                 textDesc = %ScanRPL('''' : '''''' : textDesc);
               endIf;
               cmd = 'CHGUSRPRF ?*usrprf(' + %trimR(userPrf) + ') ' +
                              ' ??TEXT(' + %trim(textDesc) + ')';
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // DISABLEUSRPRF runs the CL CHGUSRPRF command for the
             // user with the STATUS(*DISABLED) parameter.
             // The command is not prompted.
             ///////////////////////////////////////////////////////
           dcl-proc disableUsrprf;
             dcl-pi disableUsrprf;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = 'CHGUSRPRF ' + userPrf + ' STATUS(*DISABLED)';
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // ENABLEUSRPRF runs the CL CHGUSRPRF command for the
             // user with the STATUS(*ENABLED) parameter.
             // The command is not prompted.
             ///////////////////////////////////////////////////////
           dcl-proc enableUsrprf;
             dcl-pi enableUsrprf;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = 'CHGUSRPRF ' + userPrf + ' STATUS(*ENABLED)';
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // CRTUSRPRF runs the CL CRTTUSRPRF command to allow
             // the end-user to create a new user profile.
             // The command is always prompted by this routine.
             ///////////////////////////////////////////////////////
           dcl-proc crtUsrprf;
               cmd = '?CRTUSRPRF ';
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // WRKUSRJOBS runs the CL WRKUSRJOB command for the user.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc wrkusrjobs;
             dcl-pi wrkusrjobs;
               dcl-parm userprf varchar(10) const;
             end-Pi;
               cmd = 'WRKUSRJOB ' + userPrf + ' STATUS(*ACTIVE)';
               if (wsds.fKey = F4);
                 cmd = '?' + %trimr(cmd);
               endIf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // WRKUSRSPLF runs the CL WRKSPLF command for the user.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc wrkusrSPLF;
             dcl-pi wrkusrSPLF;
               dcl-parm userprf varchar(10) const;
               dcl-parm curSPLF char(1) const options(*NOPASS);
             end-pi;
             dcl-s fromToday ind inz(*OFF);
             if (%Parms() >= %ParmNUM(curSPLF));
               fromToday = (curSPLF = '1');
             endIf;
               cmd = 'WRKSPLF ' + userPrf;
               if (fromToday);
                 cmd = %trimR(cmd) + ' PERIOD((*AVAIL *CURRENT))';
               endIf;
               if (wsds.fKey = F4);
                 cmd = '?' + %trimr(cmd);
               endIf;
               system(cmd);
           end-proc;

             ///////////////////////////////////////////////////////
             // GRTUSRAUT runs the CL WRKUSRJOB command for the user.
             // If the end-user presses F4 the command is prompted.
             ///////////////////////////////////////////////////////
           dcl-proc grtusraut;
               EXEC SQL SELECT LISTAGG( cast( userID as varchar(5000)),' ')
                          INTO :userList
                         FROM session.IQ_GRANT_AUT
                         WHERE USERID <> ''
                         LIMIT 50;  -- RVKOBJAUT limits USER parm to 50
               cmd = '?GRTOBJAUT USER(' + userList + ') REPLACE(*YES)';
               system(cmd);
               EXEC SQL DELETE FROM IQ_REVOKE_AUT WHERE USERID <> '';
           end-proc;

             ///////////////////////////////////////////////////////
             // RVKUSRAUT runs the CL RVKOBJAUT command for the users.
             ///////////////////////////////////////////////////////
           dcl-proc rvkusraut;
               EXEC SQL SELECT LISTAGG( cast( userID as varchar(5000)),' ')
                          INTO :userList
                         FROM  session.IQ_REVOKE_AUT
                         WHERE USERID <> ''
                         LIMIT 50;  -- RVKOBJAUT limits USER parm to 50
               cmd = '?RVKOBJAUT USER(' + userList + ')';
               system(cmd);
               EXEC SQL DELETE FROM IQ_REVOKE_AUT WHERE USERID <> '';
           end-proc;

             ///////////////////////////////////////////////////////
             // LOADUSERS uses the QSYS2.USER_INFO SQL View to list
             // the available user profiles. It uses the FILTERS
             // data structure to control the values returned by
             // the SQL query. End-users can use F18 (shift+F6) to
             // change the Filter Settings.
             ///////////////////////////////////////////////////////
          dcl-proc loadUsers;

             ///////////////////////////////////////////////////////
             //  SQL Indicators used to test for NULL returned
             //  for the designated column in the resultSet.
             ///////////////////////////////////////////////////////
           dcl-ds indy qualified inz;
             signOn     int(5);       // Last SignOn
             Attempts   int(5);       // Invalid SignOn Attempts
             supCount   int(5);       // Supplemental Group Profile Count
             supList    int(5);       // Supplemental Group Profiles
             curlib     int(5);       // Current Library
             inlpgm     int(5);       // Initial Program Name
             inlpgmLib  int(5);       // Initial Program Library
             inlMenu    int(5);       // Initial Menu Name
             inlMenuLib int(5);       // Initial Menu Library
             crtSysName int(5);       // Created-On System Name
             Limit      int(5);       // Limited Capabilities User
             text       int(5);       // User Profile Text description
           end-Ds;

             ///////////////////////////////////////////////////////
             // The LISTLEN variable is used to determine the
             // maximum length of the data stored in the
             // supplemental group profiles list.
             ///////////////////////////////////////////////////////
           dcl-s  listLen int(10);
           dcl-s  len int(10);
           dcl-s  pos int(10);

           dcl-s vText varchar(128);

             ///////////////////////////////////////////////////////
             // Just your standard Load a Subfile setup attributes.
             ///////////////////////////////////////////////////////
           rrn = 0;
           csrpos = 1;   // Put Cursor on line 1 of subfile
           indds.dspsfl = *off;
           indds.dspsflCtl = *off;
           write display;

           clear UsersCount;
           clear ui;
           clear homeDir;

             ///////////////////////////////////////////////////////
             // if the Input USER parameter contains a generic
             // name, then convert the asterisk to the SQL '%' symbol.
             // However if a special value, such as *NONIBM is specified,
             // that leading * is retained.
             // Otherwise, if a name like 'BOB' is passed in,
             // convert it to 'BOB%' because why would you use
             // this for just one user profile?
             ///////////////////////////////////////////////////////
           selUser = filters.usrprf;
           if (%scan('*' : selUser) > 1);
             selUser = %xLate('*':'%': selUser);
           elseif (selUser = '');
             selUser = '*NONIBM';
           elseif (%SUBST(selUser:1:1) <> '*');
             selUser = %trimR(selUser) + '%';
           elseif (%scan('*' : selUser) = 0 and
                   %scan('%' : selUser) = 0);
             selUser = %TrimR(selUser);
           endIf;

           EXEC SQL DECLARE U2 CURSOR FOR
                     SELECT
                        UI.USER_NAME,
                        PREVIOUS_SIGNON,
                        SIGN_ON_ATTEMPTS_NOT_VALID,
                        USER_CLASS_NAME,
                        GROUP_PROFILE_NAME,
                        GROUP_AUTHORITY,
                      --  GROUP_AUTHORITY_TYPE,
                        SUPPLEMENTAL_GROUP_COUNT,
                        SUPPLEMENTAL_GROUP_LIST,
                        STATUS,
                        CURRENT_LIBRARY_NAME,
                        INITIAL_MENU_NAME,
                        INITIAL_MENU_LIBRARY_NAME,
                        INITIAL_PROGRAM_NAME,
                        INITIAL_PROGRAM_LIBRARY_NAME,
                        LIMIT_CAPABILITIES,
                        TEXT_DESCRIPTION,
                        USER_CREATOR,
                        CREATION_TIMESTAMP,
                        OI.CREATED_SYSTEM,
                   cast(UI.home_directory as varchar(1024) for SBCS DATA)
                  -- NOTE: This is done using a JOIN because
                  -- the V7R2 version of Object_Stats does not support
                  -- the object name as the 3rd parameter. That doesn't
                  -- become available until a later TR in V7R3/R4.
               from table(qsys2.object_statistics('QSYS','*USRPRF')) OI
                INNER JOIN qsys2.user_info UI
                  ON OI.OBJNAME = UI.USER_NAME

                   WHERE
                         UI.STATUS = CASE WHEN :filters.status = ''
                                       THEN UI.STATUS
                                       ELSE :filters.status
                                  end
                           and
                         UI.SIGN_ON_ATTEMPTS_NOT_VALID >=
                                  CASE WHEN :filters.attempts <= 0
                                       THEN UI.SIGN_ON_ATTEMPTS_NOT_VALID
                                       ELSE :filters.attempts
                                  end
                           and
                         UI.INITIAL_MENU_NAME =
                                  CASE WHEN :filters.inlMenu = ''
                                       THEN UI.INITIAL_MENU_NAME
                                       ELSE :filters.inlMenu
                                  end
                           and
                         UI.INITIAL_PROGRAM_NAME =
                                  CASE WHEN :filters.inlPgm = ''
                                       THEN UI.INITIAL_PROGRAM_NAME
                                       ELSE :filters.inlPgm
                                  end
                           and
                         UI.CURRENT_LIBRARY_NAME =
                                  CASE WHEN :filters.curlib = ''
                                       THEN UI.CURRENT_LIBRARY_NAME
                                       ELSE :filters.curlib
                                  end
                           and
                 -- Group Profiles?
                         UI.group_profile_NAME =
                                  CASE WHEN :filters.grpprf = ''
                                       THEN UI.group_profile_NAME
                                       ELSE :filters.grpprf
                                  end
                           and
                          ( UI.PREVIOUS_SIGNON is NULL or
                                days(current_date) -
                                 days(coalesce(UI.PREVIOUS_SIGNON,current_date))
                              >=  :filters.lastSignon  )
                           and
                 -- Supplemental Group Profiles?
              CASE WHEN :filters.grpprf <> '' and :filters.supGroups = 'Y'
                   THEN POSITION(:filters.grpprf,SUPPLEMENTAL_GROUP_LIST)
                   ELSE 1
              end > 0
                           and
                         UI.SUPPLEMENTAL_GROUP_COUNT >=
                                  CASE WHEN :filters.SupGrpPrfCnt <= 0
                                       THEN UI.SUPPLEMENTAL_GROUP_COUNT
                                       ELSE :filters.SupGrpPrfCnt
                                  end
                           and
                        UI.USER_NAME LIKE
                           CASE WHEN :SELUSER = ' ' or :SELUSER = '*ALL'
                                THEN OBJNAME
                                WHEN SUBSTR(:SELUSER,1,1) = '*'
                                THEN OBJNAME
                                ELSE :SELUSER
                           end
                       AND ( (SUBSTR(:SELUSER,1,1) <> '*' OR
                              :SELUSER = '*ALL' OR
                              :SELUSER = ' '
                             ) OR
                            ( SUBSTR(:SELUSER,1,1) = '*' AND
                               (((UI.STATUS IS NULL or UI.USER_NAME <> 'QSSHD')
                                    AND :SELUSER = '*NONIBM')
                                OR
                                (:SELUSER = '*IBM' and
                                  (UI.STATUS IS NOT NULL or
                                   UI.USER_NAME='QSSHD')
                                )
                               )
                            )
                           )
                    ORDER BY UI.USER_NAME;

             EXEC SQL OPEN  U2;

             clear detail;   // Clear Subfile record format fields.

             EXEC SQL  FETCH U2 INTO
                         :UI.USER_PROFILE,
                         :UI.previous_signon:indy.Signon,
                         :UI.SIGN_ON_ATTEMPTS_NOT_VALID:indy.Attempts,
                         :UI.USER_CLASS_NAME,
                         :UI.group_profile_name,
                         :UI.group_AUTH,
                         :UI.SUP_GROUP_COUNT:indy.supCount,
                         :UI.SUP_GROUPS_LIST:indy.supList,
                         :UI.status,
                         :UI.CURRENT_LIBRARY_NAME:indy.curLib,
                         :UI.INITIAL_MENU_NAME:indy.inlMenu,
                         :UI.INITIAL_MENU_LIBRARY_NAME:indy.inlMenuLib,
                         :UI.INITIAL_PROGRAM_NAME:indy.inlPgm,
                         :UI.INITIAL_PROGRAM_LIBRARY_NAME:indy.inlPgmLib,
                         :UI.LIMIT_CAPABILITIES:indy.Limit,
                         :UI.TEXT_DESCRIPTION:indy.text,
                         :UI.USER_CREATOR,
                         :UI.CREATION_TIMESTAMP,
                         :UI.crtSysName:indy.crtSysName,
                         :homeDir;

          IF (sqlState >= '02000'); // Nothing returned?
             errmsg = 'No current User Profiles detected.';
             EXEC SQL CLOSE U2;
             return;   // return to caller/redisplay (on-exit should be called)
          endif;

            DOW (sqlState < '02000');

             ///////////////////////////////////////////////////////
             // Only load the data when the returned User Profile name
             // does not start with the letter 'Q' or *IBM or *ALL were specified.
             ///////////////////////////////////////////////////////
              if NOT (filters.usrprf = '*NONIBM' and
                      %subst(ui.USER_PROFILE:1:1)='Q');

               rrn += 1;

             ///////////////////////////////////////////////////////
             // Check the Null Indicators from the row result and
             // adjust the output accordingly.
             ///////////////////////////////////////////////////////
               hUserid = ui.USER_PROFILE;
               hTextDesc = ui.text_description;

               if (indy.Signon < 0);
                 clear lastSignDT;
                 clear lastSignTM;
               else;
                 lastSignDT = %date(ui.previous_signon);
                 lastSignTM = %time(ui.previous_signon);
               endIf;
               userid = ui.USER_PROFILE;
               userclass  = ui.USER_CLASS_NAME;
               inlpgm     = ui.INITIAL_PROGRAM_NAME;
               clear altData;
               clear altData3;
               if (indy.text >= 0);
                 altData3   = ui.text_description;
               endif;

           /////////////////////////////////////////////////////////
           // Alternate VIEWS Logic
           //   1 = Initial Menu
           //   2 = Current Lib and Home Directory
           //   3 = Group Profile and Supplemental Group Profiles
           //   4 = Creator (created by) Info
           /////////////////////////////////////////////////////////
               if (altView <= 1 or altView > ALTMAX);
                 altView = 1;  // reset it to 1 just in case it is out of range
                 if (indy.inlMenu >= 0);
                   altData = UI.INITIAL_MENU_NAME;
                 else;
                   clear altData;
                 endif;
               elseif (altView = 2);
                 if (indy.curLib >= 0);
                   altData = UI.CURRENT_LIBRARY_NAME;
                 else;
                   clear altData;
                 endif;
                 altData3 = %trimR(homeDir);
               elseif (altView = 3);
                 altData   = ui.group_profile_name;
                 if (indy.supCount >= 0 and ui.SUP_GROUP_COUNT > 0);
                   altData = %trimR(altData) + '+' +
                              %char(ui.SUP_GROUP_COUNT);
                   listLen =  %MIN( ui.SUP_GROUP_COUNT*10 :
                               %Len(ui.SUP_GROUPS_LIST));
                   if (ui.SUP_GROUP_COUNT = 0);
                      altData3 = %trimR(%subst(ui.SUP_GROUPS_LIST:1:
                                        listLen));
                   else;
                     clear altData3;
                     for i = 1 to ui.SUP_GROUP_COUNT;
                       pos = ((i-1)*10)+1;
                       len = 10;
                       if (len > ((%len(ui.SUP_groups_list) - pos)+1));
                          len =   (%len(ui.SUP_groups_list) - pos)+1;
                       endIf;
                       if (altData3 = '');
                         altData3 = %subst(ui.SUP_groups_list : pos : len);
                       else;
                         altData3 = %trimR(altData3) + ' ' +
                                    %subst(ui.SUP_groups_list : pos : len);
                       endif;
                     endFor;
                   endif;
                 elseif (altData3 <> '');
                   altData3 = '*' + altData3;
                 endIf;
               elseif (altView = 4);    // Creator (created by) Info
                 altData  = UI.USER_CREATOR;
                 vText = 'Created';
                 if (indy.crtSysName >= 0);
                   vText += ' on ' + %trimR(UI.crtSysName) ;
                 endif;
                 vText += ' at ' + %Char(%time(UI.CREATION_TIMESTAMP):*USA);
                 vText += ' on ' + %Char(%date(UI.CREATION_TIMESTAMP):*USA);
                 altData3 = vText;
               endif;

               if (indy.Attempts < 0);
                 clear invalidPwd;  // Invalid SignOn Attempt
               else;
                  invalidPWD = ui.SIGN_ON_ATTEMPTS_NOT_VALID;
               endif;

               indds.Disabled = (ui.status = '*DISABLED');
               hDisabled = indds.disabled;
               write(e) detail;
             endIf;

             EXEC SQL  FETCH U2 INTO
                         :UI.USER_PROFILE,
                         :UI.previous_signon:indy.Signon,
                         :UI.SIGN_ON_ATTEMPTS_NOT_VALID:indy.Attempts,
                         :UI.USER_CLASS_NAME,
                         :UI.group_profile_name,
                         :UI.group_AUTH,
                         :UI.SUP_GROUP_COUNT:indy.supCount,
                         :UI.SUP_GROUPS_LIST:indy.supList,
                         :UI.status,
                         :UI.CURRENT_LIBRARY_NAME:indy.curLib,
                         :UI.INITIAL_MENU_NAME:indy.inlMenu,
                         :UI.INITIAL_MENU_LIBRARY_NAME:indy.inlMenuLib,
                         :UI.INITIAL_PROGRAM_NAME:indy.inlPgm,
                         :UI.INITIAL_PROGRAM_LIBRARY_NAME:indy.inlPgmLib,
                         :UI.LIMIT_CAPABILITIES:indy.Limit,
                         :UI.TEXT_DESCRIPTION:indy.text,
                         :UI.USER_CREATOR,
                         :UI.CREATION_TIMESTAMP,
                         :UI.crtSysName:indy.crtSysName,
                         :homeDir;
            enddo;

          // ON-EXIT;
            EXEC SQL CLOSE U2;
            usersCount = RRN;

          end-proc;

             ///////////////////////////////////////////////////////
             // FILTEROPTIONS prompts the end-user for select/omit
             // criteria to use for the resultSet.
             ///////////////////////////////////////////////////////
          dcl-proc filterOptions;

            dcl-ds  saveFilters likeDS(Filters) Inz;

            saveFilters = filters;

            if (filters.status = '*ENABLED');
               fEnabled = '1';
            elseif (filters.status = '*DISABLED');
               fEnabled = '2';
            else;
              clear fEnabled;
            endIf;

            if (filters.attempts > 0);
              FINVSIGNON = %char(filters.attempts);
            else;
              clear FINVSIGNON;
            endIf;

            fusrPrf = filters.usrprf;
            fInlMenu = filters.inlMenu;
            fInlPgm = filters.inlPgm;
            fcurlib = filters.curlib;
            fGrpprf = filters.grpprf;
            fusrClass = filters.usrclass;
            fSupGrp = filters.supGroups;

            if (filters.lastSignOn > 0);
               FDaySince = %char(filters.lastSignOn);
            else;
               clear FDaySince;
            endIf;

            if (filters.SUPGRPPRFCNT > 0);
               FSupGrpCnt = %char(filters.SUPGRPPRFCNT);
            else;
               clear FSupGrpCnt;
            endIf;
            errmsg = 'Blank entries revert to their default settings.';
            dow (wsds.fkey = F5 or errmsg <> '');
              exfmt Filter;
              clear errmsg;
              if (wsds.fKey = F5);
                 clear Filter;
                 clear filters;
                iter;
              endIf;

              if (fUsrPrf <> '');
                if (%subst(fUsrprf:1:1) = '*');
                   if (fUsrprf = '*ALLIBM' or
                       fUsrprf = '*ALLSYS');
                      fUsrprf = '*IBM';
                   elseif (fUsrprf = '*ALLUSR' or
                           fUsrprf = '*NONIBM');
                      fUsrprf = '*NONIBM';
                   endIf;
                  if NOT (fUsrPrf = '*ALL' or
                      fUsrPrf = '*NONIBM' or
                      fUsrPrf = '*IBM');
                    errmsg = %trimR(fUsrprf) +
                           ' is not valid. *ALL, *IBM, *NONIBM or *ALLUSR';
                    ITER;
                  endIf;
                endIf;
              endIf;
            endDo;

            if (wsds.fKey <> Enter);
              filters = saveFilters;
              return;
            endIf;

            if (fEnabled = '1');
              filters.status = '*ENABLED';
            elseif (fEnabled = '2');
                filters.status = '*DISABLED';
            else;
              clear filters.status;
            endIf;
            if (%Check('0 ':FINVSIGNON) = 0);
              clear filters.attempts;
            elseif (%Check('0123456789 ':FINVSIGNON) = 0);
              filters.attempts = %int(FINVSIGNON);
            else;
              clear filters.attempts;
            endIf;
            filters.inlMenu  = fInlMenu;
            filters.inlPgm   = fInlPgm;

            filters.usrprf   = fUsrPrf;
            filters.grpprf   = fGrpprf;
            if (fSupGrp = 'Y' or fSupGrp = '1');
              filters.supGroups = 'Y';
            else;
              clear filters.supGroups;
            endIf;
            if (%Check('0 ':FDaySince) = 0);
              clear filters.lastSignOn;
            elseif (%Check('0123456789 ':FDaySince) = 0);
              filters.lastSignOn = %int(FDaySince);
            else;
              clear filters.lastSignOn;
            endIf;

            if (%Check('0 ' : FSupGrpCnt) = 0);
              clear filters.SupGrpPrfCnt;
            elseif (%Check('0123456789 ': FSupGrpCnt) = 0);
              filters.SupGrpPrfCnt = %int(FSupGrpCnt);
            else;
              clear filters.SupGrpPrfCnt;
            endIf;
          end-Proc;