000100190211
000101190131     FTICKETDSP CF   E             WORKSTN
000103190211      /FREE
000104190208
000105190208              IMPAIRED = 'N';
000106190208              *IN01 = *ON;
000107190208              *IN02 = *ON;
000108190208              *IN77 = *ON;
000109190208              *IN45 = *ON;
000110190208              *IN78 = *OFF;
000111190208              *IN49 = *OFF;
000112190208
000113190211
000114190131              EXFMT GETINFO;
000115190208
000116190208              DOW NOT(*IN03);
000117190208
000119190208                  IF (IMPAIRED = 'Y');
000120190208                        *IN01 = *OFF;
000121190208                        *IN02 = *OFF;
000122190208                        *IN77 = *OFF;
000123190208                        *IN03 = *OFF;
000124190208                        *IN99 = *ON;
000125190208                        *IN46 = *ON;
000126190208                        *IN45 = *OFF;
000127190208                        *IN78 = *ON;
000128190208
000129190208              DOW NOT(IMPAIREDNU <> 0);
000130190208
000131190208                   EXFMT GETINFO;
000132190208              ENDDO;
000133190208                        *IN99 = *OFF;
000134190208                        *IN77 = *ON;
000135190208                  ENDIF;
000136190208
000137190208
000138190131                      EXSR GETRESULTS;
000139190208
000140190131                      *IN99 = *ON;
000141190131                      WRITE GETINFO;
000142190208                      EXFMT SHOWRESULT;
000148190131                      *IN99 = *OFF;
000149190131
000150190208                      IF (*IN06 = *ON AND IMPAIRED = 'Y');
000151190208                      EXFMT IMPDETAIL;
000152190208                      *IN06 = *OFF;
000153190208                      ENDIF;
000154190208
000155190208
000156190208
000157190131                      IF *IN03 = *OFF;
000158190131                        EXSR CLEAR;
000159190131                        EXFMT GETINFO;
000160190131                      ENDIF;
000161190131
000162190131                    ENDDO;
000163190131
000164190131                    *INLR = *ON;
000165190131                    RETURN;
000166190131
000167190131                BEGSR GetResults;
000168190208                  EXSR DTDEMERITS;
000169190208                  EXSR DTNMTICKET;
000170190208                  EXSR DTIMPAIRED;
000171190131                ENDSR;
000172190208
000173190208                BEGSR DTDEMERITS;
000174190208                         SELECT;
000175190208                           WHEN DEMERITS <= 1;
000176190208                              RESULT1 = '==> No action taken';
000177190208                           WHEN DEMERITS <= 8;
000178190208                              RESULT1 = '==> A Warning Letter is sent';
000179190208                           WHEN DEMERITS <= 14;
000180190208                              RESULT1 = '==> Your Licence is reviewed for -
000181190208       suspension and possible -
000182190208       interview request';
000183190208                           WHEN DEMERITS <= 99;
000184190208                              RESULT1 = '==> Suspended license for thirty days';
000185190208                           Other;
000186190208                              RESULT1 = '==> Error';
000187190208
000188190208                         ENDSL;
000189190208                ENDSR;
000190190208
000191190208                BEGSR DTNMTICKET;
000192190208                      SELECT;
000193190208                        WHEN  IMPAIRED = 'Y';
000194190208                              RESULT2 = '==> Rate Increased by 50%';
000195190208                              NEWRATE = INSURANCE * 1.5;
000196190208                        WHEN  NMTICKET <= 1;
000197190208                              RESULT2 = '==> No adjustment done';
000198190208                        WHEN  NMTICKET <= 3;
000199190208                              RESULT2 = '==> Rate Increased by 10%';
000200190208                              NEWRATE = INSURANCE * 1.1;
000201190208                        WHEN  NMTICKET <= 5;
000202190208                              RESULT2 = '==> Rate Increased by 20%';
000203190208                              NEWRATE = INSURANCE * 1.2;
000204190208                        WHEN  NMTICKET >= 6;
000205190208                              RESULT2 = '==> INSURANCE IS CANCELLED';
000206190208                              NEWRATE = 99999,99;
000207190208                              *IN49 = *ON;
000208190208                        OTHER;
000209190208                            RESULT2 = '==> Error';
000210190208                        ENDSL;
000211190208                ENDSR;
000212190208
000213190208                BEGSR DTIMPAIRED;
000214190208                      SELECT;
000215190208                        WHEN IMPAIREDNU = 1;
000216190208                            RESULT3 = '==> 3-day licence suspension. -
000217190208       This cannot be appealed.' ;
000218190208                        WHEN IMPAIREDNU = 2;
000219190208                            RESULT3 = '==> 7-day licence suspension. -
000220190208       This cannot be appealed.' ;
000221190208                        WHEN IMPAIREDNU >= 3;
000222190208                            RESULT3 = '==> 30-day licence suspension. -
000223190208       This cannot be appealed.' ;
000224190208                        OTHER;
000225190208                            RESULT3 = '==> Error';
000226190208                        ENDSL;
000227190208                ENDSR;
000228190131
000229190131                BEGSR CLEAR;
000230190201                  CLEAR DEMERITS;
000231190201                  CLEAR NMTICKET;
000232190201                  CLEAR IMPAIRED ;
000233190208                  CLEAR IMPAIREDNU;
000234190201                  CLEAR INSURANCE;
000235190208                  CLEAR NEWRATE;
000236190208
000237190208                  *IN01 = *ON;
000238190208                  *IN02 = *ON;
000239190208                  *IN77 = *ON;
000240190208                  *IN45 = *ON;
000241190208                  *IN78 = *OFF;
000242190208                   *IN49 = *OFF;
000243190208                  IMPAIRED = 'N';
000244190131                ENDSR;
