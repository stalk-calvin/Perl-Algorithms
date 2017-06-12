#!/usr/bin/perl -w

use strict;

use FindBin qw($Bin);
use POSIX ":sys_wait_h";
use Test::More tests => 4;

use lib "$Bin/../lib";

BEGIN {
    use_ok('Algorithm::PID');
}

$SIG{CHLD} = sub { while(waitpid(-1,WNOHANG) > 0) {} };

my $filename = '/tmp/pid-test-file.pid';
my $fixture = Algorithm::PID->new(
    filename => $filename
);

start_testing();

sub start_testing {
   # These actions are expected to occur in sequence
   testCreatePID();
   testCreatePIDSecondTime();
   testShouldRemovePIDFile();
}

sub testCreatePID {
   eval {
       $fixture->pidfile();
   };
   if ($@) {
       fail('Unable to create pidfile: ' . $@);
   } else {
       pass('Created pidfile');
   }
}

sub testCreatePIDSecondTime {
   eval {
       $fixture->pidfile();
   };
   if ($@) {
       pass("Same process - $@");
   } else {
       fail("Didn't notice PID file " . $filename);
   }
}

sub testShouldRemovePIDFile {
   $fixture->cleanup();
   ok(!-e $filename, 'PID file removed');
}

