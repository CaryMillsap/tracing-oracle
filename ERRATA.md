TRACING ORACLE ERRATA
===

8621: I found out by looking at an strace of a 19c sqltrace that Oracle no longer uses two write calls for each trace line. This invalidates statements on pages 32, 33, 48.

8622: Oracle writes STAT lines in segments. It takes between 3 and 5 write calls to write a STAT line. This invalidates statements made on pages 33, 48. 

