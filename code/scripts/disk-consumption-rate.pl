#!/usr/bin/perl
#
# 3:23PM

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
	"o"			=> \$Opt{ofile},
);
GetOptions(%Options) or die;

my ($dir, $interval, $count) = (
	$ARGV[0] //  ".",					# Directory name.
	$ARGV[1] //    1,					# Interval duration in seconds.
	$ARGV[2] // 1000,					# Number of intervals.
);
printf "%s '%s' %d %d\n", $0, File::Spec->rel2abs($dir), $interval, $count;

my $format = "%Y-%m-%dT%H:%M:%S";

sub d {
	chomp(my $d = qx(date "+$format"));	# `date` prints a newline.
	return $d;
}
sub k {
	chomp(my $k = qx(du -ks "$dir"));	# `du` prints a newline.
	$k =~ s/^(\d+).*/$1/;				# `du` returns /\d+  $dir/
	return $k;
}
sub p($$$$) {
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
