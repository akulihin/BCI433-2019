000100070123     F*********************************************************************************************
000200070202     F* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE THAT JOINS THE ORDERS,        *
000300070202     F* ORDERLINE, CUSTOMER, PART AND SALESREP TABLES.  ORDER NUMBER IS USED AS A CONTROL BREAK   *
000400070202     F* FIELD WHERE CUSTOMER TOTALS ARE PRINTED ON NEW ORDER NUMBERS                              *
000500070202     F*                                                                                           *
000600070123     F*********************************************************************************************
000700070123
000701190329           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000702190329           DCL-PI Main extPgm('PROVSQLH');
000703190329             LowLimit Zoned(7:2);
000704190329
000705190329           END-PI;
000900070209     D CustomerRecord  DS
001000070209     D CustId                         6
001100070209     D FullName                      31
001200130218     D City                          20
001300070209     D Purchase                       7  2
001400070209     D PDate                           D
001500070209     D Province                      10
001600070209     D ProvinceH       S             10
001700070205     D TotalCost       S              8  2
001800070202     D TotalRecords    S              5  0
001900070202     D TotalExtended   S              9  2
002000070209     D OntarioTot      S              3  0
002100070209     D QuebecTot       S              3  0
002200070209     D ManitobaTot     S              3  0
002300070202     D EndOfFile       S               N
002400070123     C/EJECT
002500070123     C********************************************************************************************
002600070123     C*                        ***   M A I N   R O U T I N E   ***                               *
002700070123     C********************************************************************************************
002800070118      /FREE
002801190329                     EXSR PrepareFiles;
002802190329
002803190329                Write Title;
002804190329                Write HEADINGS;
002805190329                EXSR GetRow;
002806190329                Write NewProv;
002807190329                ProvinceH = Province;
002808190329                DOW NOT EndOfFile;
002809190329                    IF *IN01 = *ON;
002810190329                        Write Title;
002811190329                        Write HEADINGS;
002812190329                       *IN01 = *OFF;
002813190329                    ENDIF;
002814190329
002815190329
002816190329
002817190329
003900070209                    If ProvinceH = Province;
004000190329                       WRITE Detail;
004100070209                    Else;
004200070209                       ProvinceH = Province;
004201190329                       WRITE Totals;
004202190329                       TOTALPURCH = 0;
004300190329                       WRITE NewProv;
004400190329                       WRITE Detail;
004500070209                    EndIf;
004600190329                    TOTALPURCH     = TOTALPURCH     + Purchase;
004700190329                    TotalRecords = TotalRecords + 1;
004701190329
004800100309                    EXSR GetRow;
004900070119                ENDDO;
005000070202                EXSR   WRAPUP;
005001190329                WRITE Totals;
005002190329                WRITE UNDERLIMIT;
005100190329
005200070119                *INLR = *ON;
005300070119                RETURN;
005400100309        //************************************************************************************
005500100309        // O P E N F I L E S   S U B R O U T I N E
005600100309        //*****************************************************************************************
005700100309         BEGSR  PrepareFiles;
005800100309        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
005801180405              EXEC SQL
005802180405                 DECLARE ALLPROVCURSOR CURSOR
005803180405                   FOR
005804180405                   SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME), CITY,
005805180405                          PURCHASE,
005806180405                          PDATE, 'Ontario' AS PROVINCE
005807180405                   FROM BCI433LIB/ONTARIO
005808190329                   WHERE PURCHASE > :LowLimit
005809180405                   UNION ALL
005810180405                   SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME), CITY,
005811180405                           PURCHASE,
005812180405                          PDATE, 'Quebec' AS PROVINCE
005813180405                   FROM BCI433LIB/QUEBEC
005814190329                   WHERE PURCHASE > :LowLimit
005815180405                   UNION ALL
005816180405                   SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME), CITY,
005817180405                           PURCHASE,
005818180405                          PDATE, 'Manitoba' AS PROVINCE
005819180405                   FROM BCI433LIB/MANITOBA
005820190329                   WHERE PURCHASE > :LowLimit
005821180405                     FOR READ ONLY;
005822180405
005823180405              EXEC SQL
005824180405                OPEN ALLPROVCURSOR;
005825180405              IF SQLCODE <> 0 OR SQLWN0 = 'W';
005826180405                EndOfFile = *ON;
005827180405              ENDIF;
008100100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
009000100309            ENDSR;
009100100309        //****************************************************************************************
009200100309        //   G E T     R O W    S U B R O U T I N E
009300100309        //*****************************************************************************************
009400100309            BEGSR     GETROW;
009500180405                   EXEC SQL
009501180405                     FETCH NEXT
009502180405                       FROM ALLPROVCURSOR
009503180405                       INTO :CustomerRecord;
009504180405                   IF SQLCODE <> 0 OR SQLWN0 = 'W';
009505180405                     EndOfFile = *ON;
009506180405                   ENDIF;
010500100309             ENDSR;
010600100309        //*****************************************************************************************
010700100309        // W R A P U P     S U B R O U T I N E
010800100309        //*****************************************************************************************
010900100309           BEGSR WRAPUP;
011000180405                 EXEC SQL
011001180405                   CLOSE ALLPROVCURSOR;
011002180405
011003180405                 IF SQLCODE <> 0 OR SQLWN0 = 'W';
011004180405                   EndOfFile = *ON;
011005180405                 ENDIF;
011006180405
011007180405              EXEC SQL
011008190329                SELECT COUNT(*) INTO :ONTTOTAL
011009180405                  FROM BCI433LIB/ONTARIO
011010190329                  WHERE PURCHASE <= :LowLimit;
011011180405
011012180405              IF SQLCODE <> 0 OR SQLWN0 = 'W';
011013180405                OntarioTot = -999;
011014180405              ENDIF;
011015180405
011016180405              EXEC SQL
011017190329                SELECT COUNT(*) INTO :QUETOTAL
011018180405                  FROM BCI433LIB/QUEBEC
011019190329                  WHERE PURCHASE <= :LowLimit;
011020180405
011021180405              IF SQLCODE <> 0 OR SQLWN0 = 'W';
011022180405                QuebecTot = -999;
011023180405              ENDIF;
011100171217
011101180405
011102180405              EXEC SQL
011103190329                 SELECT COUNT(*) INTO :MANTOTAL
011104180405                  FROM BCI433LIB/MANITOBA
011105190329                  WHERE PURCHASE <= :LowLimit;
011106180405
011107180405              IF SQLCODE <> 0 OR SQLWN0 = 'W';
011108180405                ManitobaTot = -999;
011109180405              ENDIF;
014200100309          ENDSR;
014300100309      /END-FREE
