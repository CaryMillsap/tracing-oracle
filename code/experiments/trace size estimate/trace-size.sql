-- trace file size estimator

-- Martin Berger has suggested estimating trace sizes and IOPS by using the
-- trace rates and sizes published in the Tracing Oracle book, combined with
-- data from v$sysstat:
--
-- - user calls            dbcall count
-- - non-idle wait count   underestimate of syscall count

-- - parse count (total)   overestimate of PARSING IN CURSOR count
-- - user commits          XCTEND rlbk=0 count
-- - user rollbacks        XCTEND rlbk=1 count

-- - execute count         might help with BINDS size estimation

-- It's a good idea, especially for calculating lines emitted by the
-- WAITS=>TRUE parameter.

-- The trickiest problem is probably going to be estimating the cost of
-- BINDS=>TRUE. That information will probably need to come from
-- V$SQL_BIND_DATA or similar. By the time we hack through this, it's probably
-- easier to just test and measure. (See scripts/disk-consumption-rate.pl).

