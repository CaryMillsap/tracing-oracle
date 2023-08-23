#!/usr/local/bin/perl

use strict;
use warnings;
use File::Basename;
use experimental qw(switch);
use Getopt::Long;

our $Program = fileparse $0, qr(\..*);

our %Opt = (
   verbose    => 0,
);
our %Options = (
   "help|?"   => sub { print "Usage: $Program [--verbose] file ...\n"; exit; },
   "verbose!" => \$Opt{verbose},
);
GetOptions(%Options) or die;

my $filename; 
my %pic = ();     # $pic{$c} is the line number where cursor ID $c is defined.

FILE: while ($filename = shift @ARGV) {
   my $F;
   open($F, $filename) or do {
      warn "$main::Program: can't open '$filename' ($!)\n";
      next;
   };
   while (my $line = <$F>) {
      given ($line) {
         when (/^(PARSING IN CURSOR) \#([0-9]+)/) {
            my $cursor_id = $2;
            printf "%8d PIC #%s\n", $., $cursor_id if $Opt{verbose};
            $pic{$cursor_id} = $.;
         }
         when (/^(PARSE|EXEC|FETCH|UNMAP|SORT UNMAP) \#([0-9]+)/) {  # Leave out WAIT, CLOSE.
            my ($call, $cursor_id) = ($1, $2);
            printf "%8d \t%s #%s ", $., $call, $cursor_id if $Opt{verbose};
            if ($pic{$cursor_id}) {
               printf "found PIC on line $pic{$cursor_id}\n" if $Opt{verbose};
            } else {
               print "FAIL $filename:$. no definition for $cursor_id\n";
               next FILE;
            }
         }
      }
   }
   print "OK $filename\n";
}


__DATA__

Hello


