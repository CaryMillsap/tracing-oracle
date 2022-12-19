© 2021 Method R Corporation

use strict;
use warnings;
use DBI;

my ($dbauth, $dirname, $filename) = @ARGV;
my $dbh = DBI->connect('dbi:Oracle:', $dbauth) or die;
my $bufsz = 512;

my $stm = "select bfilename(?, ?) from dual";
my $stmh = $dbh->prepare($stm, {ora_auto_lob=>0}) or die;
$stmh->execute($dirname, $filename);
my ($loc) = $stmh->fetchrow_array();
for (my $off=1; 1; $off += $bufsz) {
	my $piece = $dbh->ora_lob_read($loc, $off, $bufsz);
	last if length($piece) == 0;
	print $piece;
}
$stmh->finish;
$dbh->disconnect;

__END__

$ perl gettrc.pl jeff/jeff METHODR_UDUMP_1 ora193_dia0_8489_base_1.trc > x
$ head -1 x
Trace file /u01/app/oracle/diag/rdbms/ora193/ora193/trace/ora193_dia0_8489_base_1.trc
$ diff x /u01/app/oracle/diag/rdbms/ora193/ora193/trace/ora193_dia0_8489_base_1.trc
$
