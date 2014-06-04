#!/usr/bin/env perl
use warnings;
use strict;

my $debug = 0;

my $wget = "/usr/bin/wget";
my $ical2org = "$ENV{HOME}/bin/ical2org.pl";

my $base_dir = "$ENV{HOME}/.calendars";
my $org_dir  = "$ENV{HOME}/org/calendars";

my %calendars = (
    'home' => 'http://www.google.com/calendar/ical/...',
    'work' => 'https://www.google.com/calendar/ical/...',
    );

chdir $base_dir;
# acad and ooo don't work
my @cals = qw(home work);

foreach my $cal (@cals) {
    next unless $calendars{$cal};

    my $cmd = "$wget -q -O $cal.ics.new $calendars{$cal} && mv $cal.ics.new $cal.ics";
    print STDERR "$cmd\n" if $debug;
    system $cmd;

    next unless -r "$cal.ics";

    $cmd = "$ical2org -c $cal < $base_dir/$cal.ics > $org_dir/$cal.org.new";
    print STDERR "$cmd\n" if $debug;
    system $cmd;

    if ( -s "$org_dir/$cal.org.new" ) {
	$cmd = "cp $org_dir/$cal.org.new $org_dir/$cal.org";
	print STDERR "$cmd\n" if $debug;
	system $cmd;
    }
}
