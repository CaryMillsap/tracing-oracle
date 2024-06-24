#!/usr/bin/perl

# Print number of days until filesystem fills.

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
   head     => 1,
   ofile    => '',
);
our %Options = (
   "debug"  => \$Opt{debug},
   "help|?" => sub { pod2usage(-input=>\*main::DATA, -verbose => 1, -exit => 0); },
   "man"    => sub { pod2usage(-input=>\*main::DATA, -verbose => 2, -exit => 0); -formatter => "Pod::Text::Termcap"; },
   "usage"  => sub { pod2usage(-input=>\*main::DATA, -verbose => 0, -exit => 0); },
   #  
   "head!"  => \$Opt{head},   # Print header.
   "o"      => \$Opt{ofile},  # Not implemented (easy enough to do on the command line with `tee`).
);
GetOptions(%Options) or die;

my $DEBUG = $Opt{debug};

my ($dir, $interval, $count) = (
   $ARGV[0] //  ".",          # Directory name.
   $ARGV[1] //    1,          # Interval duration in seconds.
   $ARGV[2] // 1000,          # Number of intervals.
);
printf "%s '%s' %d %d\n\n", basename($0), File::Spec->rel2abs($dir), $interval, $count;

my $format = "%Y-%m-%dT%H:%M:%S";      # ISO 8601.

sub _date {
   # Execute the date command.
   chomp(my $d = qx(date "+$format")); # `date` prints a newline, so chomp it.
   return $d;
}
sub df($) { 
   # Execute the df command, return kilobytes.
   # ASSERT: `df` returns "Available" in the fourth field of the final line of its output.
   # ASSERT: `df -k` returns 1024-byte blocks.
   my ($dir) = @_;
   my $df = qx(df -k "$dir" | tail -1);
   return (split /\s+/, $df)[3];
}
sub head() {
   return unless $Opt{head};
   printf "%19s   %10s   %10s   %15s\n", "Time", "GB free", "GB/s used", "Days until full";
}
sub p($$$$) {
   # Print the rates from (date1,df1) to (date2,df2).
   my ($date1, $df1, $date2, $df2) = @_;

   # Print date columns.
   my $delta_s = Time::Piece->strptime($date2, $format) - Time::Piece->strptime($date1, $format);
   return if $delta_s == 0;
   printf "%19s", $date2;              # "Time"
   printf "   ";

   # Print GB free columns.
   printf "%10d", $df2 / (1e9/1e3);    # "GB free"
   printf "   ";
   
   # Print consumption rate in KB/s.
   my $delta_df = $df1 - $df2;         # KB consumed this interval.
   my $kbps = $delta_df/$delta_s;      # KB/s at which freespace is being consumed.
   printf "%10.6f", $kbps / (1e9/1e3); # "GB/s used"
   printf "   ";

   # Print days remaining at this rate.
   if ($kbps > 0) {
      my $days = $df2/$kbps/(60*60*24);   # k/(k/s)/(s/m*m/h*h/d) = d.
      printf "%15.1f", $days;
   } else {
      printf "%15s", "+INF";
   }
   print "\n";
}
$SIG{INT} = sub { exit; }; # Execute the END block upon Ctrl-C.

my ($date0, $du0);         # First (date, du) tuple.
my ($date1, $du1);         # Prior (date, du) tuple.
my ($date2, $du2);         # Current (date, du) tuple.

($date0, $du0) = ($date1, $du1) = ($date2, $du2) = (_date, df($dir));
head();
for (1..$count) {
   sleep($interval);
   ($date2, $du2) = (_date, df($dir));
   p($date1, $du1, $date2, $du2);
   ($date1, $du1) = ($date2, $du2);
}

END {
   print "\n";
   head();
   p($date0, $du0, $date2, $du2);
}


__DATA__


=head1 NAME

df-rate - file system full estimator


=head1 SYNOPSIS

df-rate [ I<options> ] [ I<directory> [ I<interval> [ I<count> ] ] ]


=head1 DESCRIPTION

The B<df-rate> program executes the B<df -k> command upon the fileysstem
containing I<directory>, once every I<interval> seconds, for I<count>
iterations. It will write a line to standard output for each iteration.

If no parameter values are specified, the program will run as if you had typed
the following:

   df-rate . 1 1000

That is, the I<directory> value defaults to the current working directory,
I<interval> defaults to 1 seconds, and I<count> defaults to 1,000 intervals. 

After reporting its final interval, B<df-rate> prints a line that summarizes
over all the intervals combined, its estimate of when your filesystem will
fill.

To terminate the program before it reaches the specified interval count,
interrupt it with Ctrl-C. The program will then print its summary line and
terminate.


=head1 OPTIONS

=over

=item --head

Print column headings (default). Use B<--nohead> to suppress.

=item --man

Print the manual page and exit.

=back


=head1 EXAMPLES

How long will it take for a database-wide trace to consume our entire
DIAGNOSTIC_DEST filesystem? B<df-rate> makes it easy to know, after running
a short 10-minute test.

To test B<df-rate>, use F<fill-disk.sh>.


=head1 AUTHOR

Cary Millsap


=head1 COPYRIGHT AND LICENSE

Copyright (c) 2022, 2024 Cary Millsap

