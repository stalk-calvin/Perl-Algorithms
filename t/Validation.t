#!/usr/bin/perl -w
use strict;

use utf8;
use FindBin qw($Bin);

use Test::More;

use lib "$Bin/../lib";

require_ok('Algorithm::Validation');

start_testing();

sub start_testing {
   testAlphaNum();
   testId();
   testNumeric();
   testFloat();
   testIpInvalid();
   testIpValid();
   testUrlValid();
   testEmailInvalid();
   testEmailValid();
}

sub testAlphaNum {
   my $input = "123!abc";
   my $output = Algorithm::Validation::v_alpha_nume($input);
   ok(!defined $output, "testAlphaNum");
}

sub testId {
   my $input = "12345678910";
   my $output = Algorithm::Validation::v_id($input);
   ok(!defined $output, "testId");
}

sub testNumeric {
   my $input = "12345678910.3";
   my $output = Algorithm::Validation::v_numeric($input);
   ok(!defined $output, "testNumeric");
}

sub testFloat {
   my $input = "12345678910.3";
   my $output = Algorithm::Validation::v_float($input);
   is($output, $input, "testFloat");
}

sub testIpInvalid {
   my $input = "12345678910.3";
   my $output = Algorithm::Validation::v_ip($input);
   ok(!defined $output, "testIpInvalid");
}

sub testIpValid {
   my $input = "111.222.111.222";
   my $output = Algorithm::Validation::v_ip($input);
   is($output, $input, "testIpValid");
}

sub testUrlValid {
   my $input = "http://www.google.com";
   my $output = Algorithm::Validation::v_url($input);
   is($output, $input, "testUrlValid");
}

sub testEmailInvalid {
   my $input = "abc.def\@google\@com";
   my $output = Algorithm::Validation::v_email($input);
   ok(!defined $output, "testEmailInvalid");
}

sub testEmailValid {
   my $input = "abc.def\@google.com";
   my $output = Algorithm::Validation::v_email($input);
   is($output, $input, "testEmailValid");
}

done_testing;

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2016 by Calvin Lee

