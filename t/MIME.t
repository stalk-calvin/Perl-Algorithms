#!/usr/bin/perl -w
use strict;

use utf8;
use FindBin qw($Bin);

use Test::More;

use lib "$Bin/../lib";

require_ok('Algorithm::MIME');

subtest testDecodeCharsetMimewords => sub {
   my $input = "This's a \x{201c}test\x{201d}";
   my $output = Algorithm::MIME::decode_charset_mimewords($input);
   my $expected = "This's a “test”";
   cmp_ok($output, 'eq', $expected, 'testDecodeCharsetMimewords');
};

subtest testRepairUnicodes => sub {
   my $input = "“test” — ʼ";
   my $output = Algorithm::MIME::repair_unicodes(\$input);
   my $expected = "\"test\" - '";
   cmp_ok($output, 'eq', $expected, 'testRepairUnicodes');
};

done_testing;

