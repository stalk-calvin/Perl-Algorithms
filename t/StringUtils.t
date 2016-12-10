#!/usr/bin/perl -w
use strict;

use utf8;
use FindBin qw($Bin);

use Test::More;

use lib "$Bin/../lib";

require_ok('Algorithm::StringUtils');

subtest getReadableSize => sub {
   my $input = "1824572832";
   my $output = Algorithm::MIME::getReadableSize($input);
   my $expected = "1.70 GB";
   cmp_ok($output, 'eq', $expected, 'getReadableSize');
};

subtest getSizeFromReadableString => sub {
   my $input = "1.70 GB";
   my $output = Algorithm::MIME::getSizeFromReadableString($input);
   my $expected = "1869169767219.2";
   cmp_ok($output, 'eq', $expected, 'getSizeFromReadableString');
};

subtest getPrettySizeText => sub {
   my $input = "1048576";
   my $output = Algorithm::MIME::getPrettySizeText($input);
   my $expected = "1MB";
   cmp_ok($output, 'eq', $expected, 'getPrettySizeText');
};

subtest getSizeWithCommas => sub {
   my $input = "1824572832";
   my $output = Algorithm::MIME::getSizeWithCommas($input);
   my $expected = "1,824,572,832";
   cmp_ok($output, 'eq', $expected, 'getSizeFromReadableString');
};

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

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2016 by Calvin Lee

