#!/usr/bin/perl
use warnings;
use strict;

my $file = shift @ARGV;

my $emacs = "emacsclient --server-file=work";

my $command = "$emacs --eval '(emms-add-file \"$file\")'";

#print "$command\n";

system "$command";

