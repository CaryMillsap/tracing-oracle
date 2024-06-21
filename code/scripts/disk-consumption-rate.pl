#!/usr/bin/perl

# Calculate disk consumption rate.

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Time::Piece;
use File::Spec;
use Pod::Usage;

our $Program = fileparse $0, qr(\..*);

our %Opt = (
   debug    => 0,
   ofile    => '',
   unit     => 'MB/h',
);
our %Options = (
<<<<<<< HEAD
   "debug"  => \$Opt{debug},
   "help|?" => sub { pod2usage(-input=>\*main::DATA, -verbose => 1, -exit => 0); },
   "man"    => sub { pod2usage(-input=>\*main::DATA, -verbose => 2, -exit => 0); -formatter => "Pod::Text::Termcap"; },
   "usage"  => sub { pod2usage(-input=>\*main::DATA, -verbose => 0, -exit => 0); },
   #  
   "o"      => \$Opt{ofile},  # Not implemented (easy enough to do on the command line with `tee`).
   "unit=s" => \$Opt{unit},
=======
   "debug"     => \$Opt{debug},
   "help|?"    => sub { pod2usage(-input=>\*main::DATA, -verbose => 1, -exit => 0); },
   "man"       => sub { pod2usage(-input=>\*main::DATA, -verbose => 2, -exit => 0); -formatter => "Pod::Text::Termcap"; },
   "usage"     => sub { pod2usage(-input=>\*main::DATA, -verbose => 0, -exit => 0); },
   #  
   "o"         => \$Opt{ofile},  # Not implemented (easy enough to do on the command line with `tee`).
   "unit=s"    => \$Opt{unit},
>>>>>>> ecf77aec9c072b3c42a7b48ffe2d520dc7065437
);
GetOptions(%Options) or die;

my $DEBUG = $Opt{debug};
my $WORKING = 0;

my %bytes = (
   "B"   => 1,
   "KB"  => 1e3,
   "MB"  => 1e6,
   "GB"  => 1e9,
   "TB"  => 1e12,
   "PB"  => 1e15,
);
my %seconds = (
   "s"   => 1,
   "m"   => 60,
   "h"   => 60*60,
   "d"   => 60*60*24,
   "w"   => 60*60*24*7,
);

<<<<<<< HEAD
=======

>>>>>>> ecf77aec9c072b3c42a7b48ffe2d520dc7065437
my ($qunit, $tunit);
my ($bytes, $seconds);
{
   ($qunit, $tunit) = split('/', $Opt{unit});
   $bytes   = $bytes{$qunit};
   $seconds = $seconds{$tunit};
   printf "Opt{unit}='%s'  qunit='%s' tunit='%s'  bytes='%d' seconds='%d'\n", $Opt{unit}, $qunit, $tunit, $bytes, $seconds if $DEBUG;
   die "unrecognized quantity unit '$qunit'; should be one of (B KB MB GB TB PB)" if !defined $bytes;
   die "unrecognized time unit '$tunit'; should be one of (s m h d w)"            if !defined $seconds;
}

my ($dir, $interval, $count) = (
   $ARGV[0] //  ".",          # Directory name.
   $ARGV[1] //   1,           # Interval duration in seconds.
   $ARGV[2] // 1000,          # Number of intervals.
);
printf "%s '%s' %d %d\n\n", $0, File::Spec->rel2abs($dir), $interval, $count;

my $format = "%Y-%m-%dT%H:%M:%S";      # ISO 8601.

sub d {
   # Execute the date command.
   chomp(my $d = qx(date "+$format")); # `date` prints a newline, so chomp it.
   return $d;
}
sub du {
   # Execute the du command, return bytes.
   # ASSERT: `du -s` returns bytes used in the first field of its output.
   # ASSERT: `du -k` returns 1024-byte blocks.
   return 0 if not -d "$dir";
   my $du = qx(du -ks "$dir");
   return (split /\s+/, $du)[0] * 1024;
}
sub df { 
   # Execute the df command, return bytes.
   # ASSERT: `df` returns "Available" in the fourth field of the final line of its output.
   # ASSERT: `df -k` returns 1024-byte blocks.
   my $df = qx(df -k "$dir" | tail -1);
   return (split /\s+/, $df)[3] * 1024;
}
sub p($$$$) {
   # Print the rates from (date1,du1) to (date2,du2).
   my ($date1, $du1, $date2, $du2) = @_;
   my $s = Time::Piece->strptime($date2, $format) - Time::Piece->strptime($date1, $format);
   return if $s == 0;
   my $du = $du2 - $du1;
   my $bps = $du/$s;
   my $df = df;
   # Next stats are in s, irrespective of the chosen time unit.
   printf "%s … %s = %4d s   ", $date1, $date2, $s;
   # Next stats are in KB, irrespective of the chosen quantity unit.
   printf "(%9d KB … %9d KB) = %9d KB", $du1/$bytes{KB}, $du2/$bytes{KB}, $du/$bytes{KB};
   printf "  %10.1f %s/%s", $bps/($bytes/$seconds), $qunit, $tunit;
   printf "  %10d %s free", $df/$bytes, $qunit;
   printf "   ";
   if ($bps <= 0) {
      printf "not filling";
   } else {
      printf "%.1f days until full", $df/$bps/$seconds{d};
   }
   print "\n";
}
$SIG{INT} = sub { exit; }; # Execute the END block upon Ctrl-C.

my ($date0, $du0);         # First ever (date, du) tuple.
my ($date1, $du1);         # Prior (date, du) tuple.
my ($date2, $du2);         # Current (date, du) tuple.

($date0, $du0) = ($date1, $du1) = ($date2, $du2) = (d, du);
for (1..$count) {
   sleep($interval);
   ($date2, $du2) = (d, du);
   p($date1, $du1, $date2, $du2);
   ($date1, $du1) = ($date2, $du2);
}

END {
   print "\n";
   p($date0, $du0, $date2, $du2);
}


__DATA__


=head1 NAME

disk-consumption-rate - calculate disk consumption rate


=head1 SYNOPSIS

disk-consumption-rate [ I<options> ] [ I<directory> [ I<interval> [ I<count> ] ] ]


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


=head1 OPTIONS

=over

=item --man

Print the manual page and exit.

=item --unit=I<string>

Report in the given unit, expressed in "Q/T" format (quantity per unit of
time). Quantity can be any of B, KB, MB, GB, TB, or PB. Time can be any of s,
m, h, d, w (seconds, minutes, hours, days, weeks). Default is "GB/h".

=back



=head1 EXAMPLES

We created this tool because we had a customer who needed to know how many days
they could leave an Oracle database-wide trace enabled without running out of
disk space. They knew how many terabytes of available storage they had, but
they didn't know how quickly their trace would consume that space. We executed
a few 10-minute tests during which we would enable database-wide tracing and
then measure the consumption rate in the Oracle Database DIAGNOSTIC_DEST
directory with B<disk-consumption-rate>. With this information, we could
estimate how many days we'd be able to trace before worrying about running out
of space.

To test B<disk-consumption-rate>, use F<fill-disk.sh>.


=head1 AUTHOR

Cary Millsap


=head1 COPYRIGHT AND LICENSE

Copyright (c) 2022, 2024 Cary Millsap

