#!/usr/bin/perl

# Calculate disk consumption rate.

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Time::Piece;
use File::Spec;

our $Program = fileparse $0, qr(\..*);

our %Opt = (
	ofile		=> '',
);
our %Options = (
	"o"			=> \$Opt{ofile},		# Not implemented (easy enough to do on the command line with `tee`).
);
GetOptions(%Options) or die;

my ($dir, $interval, $count) = (
	$ARGV[0] //  ".",					# Directory name.
	$ARGV[1] //   10,					# Interval duration in seconds.
	$ARGV[2] // 1000,					# Number of intervals.
);
printf "%s '%s' %d %d\n", $0, File::Spec->rel2abs($dir), $interval, $count;

my $format = "%Y-%m-%dT%H:%M:%S";

sub d {			# Execute the date command.
	chomp(my $d = qx(date "+$format"));	# `date` prints a newline.
	return $d;
}
sub k {			# Execute the du command.
	chomp(my $k = qx(du -ks "$dir"));	# `du` prints a newline.
	$k =~ s/^(\d+).*/$1/;				# `du` returns /\d+  $dir/.
	return $k;
}
sub p($$$$) {	# Print the rates from (d0,k0) to (d1,k1).
	my ($d0, $k0, $d1, $k1) = @_;
	my $s = Time::Piece->strptime($d1, $format) - Time::Piece->strptime($d0, $format);
	return if $s == 0;
	my $k = $k1 - $k0;
	printf "%s … %s = %4d s   %9d KB … %9d KB = %9d KB   %10.1f KB/s  %10.1f MB/m  %10.1f GB/h  %10.1f TB/d\n",
		$d0, $d1, $s, $k0, $k1, $k, $k/$s, $k/$s/1e3*60, $k/$s/1e6*60*60, $k/$s/1e9*60*60*24;
}
$SIG{INT} = sub { exit; };				# Execute the END block upon Ctrl-C.

my ($d00, $k00);						# First ever (date, kb) tuple.
my ($d0, $k0);							# Prior (date, kb) tuple.
my ($d1, $k1);							# Current (date, kb) tuple.
($d00, $k00) = ($d0, $k0) = ($d1, $k1) = (d, k);
for (1..$count) {
	sleep($interval);
	($d1, $k1) = (d, k);
	p($d0, $k0, $d1, $k1);
	($d0, $k0) = ($d1, $k1);
}
END {
	print "\n";
	p($d00, $k00, $d1, $k1);
}


__END__


=head1 NAME

disk-consumption-rate - calculate disk consumption rate


=head1 SYNOPSIS

disk-consumption-rate [ I<directory> [ I<interval> [ I<count> ] ] ]


=head1 DESCRIPTION

The B<disk-consumption-rate> program executes the B<du -ks> command upon
I<directory>, once every I<interval> seconds, for I<count> iterations. It will
write a line to standard output for each iteration.

If no parameter values are specified, the program will run as if you typed the
following:

	disk-consumption-rate . 10 1000

That is, the I<directory> value defaults to the current working directory,
I<interval> defaults to 10 seconds, and I<count> defaults to 1,000 intervals. 

After reporting its final interval, B<disk-consumption-rate> prints a line that
summarizes all the disk consumption that has occurred since the program was
executed. To terminate the program before it reaches the specified interval
count, simply press Ctrl-C. The program will then print its summary line and
terminate.


=head1 EXAMPLES

We created this tool because we had a customer who needed to know how many days
they could leave an Oracle database-wide trace enabled without running them out
of disk space. They knew how many terabytes of available storage they had, but
they didn't know how quickly their trace would consume that space. We executed
a few 10-minute tests during which we would enable database-wide tracing and
then measure the consumption rate in the Oracle Database DIAGNOSTIC_DEST
directory with B<disk-consumption-rate>. With this information, we could
estimate how many days we'd be able to trace before worrying about running out
of space.


=head1 AUTHOR

Cary Millsap


=head1 COPYRIGHT AND LICENSE

Copyright (c) 2022 Method R Corporation

