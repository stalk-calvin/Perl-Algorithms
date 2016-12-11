#!/usr/bin/perl -w
use strict;

use utf8;
use FindBin qw($Bin);

use Test::More;

use lib "$Bin/../lib";

require_ok('Algorithm::StringUtils');

start_testing();

sub start_testing {
   testReadableSize();
   testSizeFromReadableString();
   testPrettySizeText();
   testSizeWithCommas();
   testRepairUnicodes();
   testObjToXml();
   testXmlToObj();
   testToBase64String();
   testFromBase64String();
   testToJsonString();
   testFromJsonString();
}

sub testReadableSize {
   my $input = "1824572832";
   my $output = Algorithm::StringUtils::getReadableSize($input);
   my $expected = "1.70 GB";
   cmp_ok($output, 'eq', $expected, 'getReadableSize');
}

sub testSizeFromReadableString {
   my $input = "1.70 GB";
   my $output = Algorithm::StringUtils::getSizeFromReadableString($input);
   my $expected = "1869169767219.2";
   cmp_ok($output, 'eq', $expected, 'getSizeFromReadableString');
}

sub testPrettySizeText {
   my $input = "1048576";
   my $output = Algorithm::StringUtils::getPrettySizeText($input);
   my $expected = "1MB";
   cmp_ok($output, 'eq', $expected, 'getPrettySizeText');
}

sub testSizeWithCommas {
   my $input = "1824572832";
   my $output = Algorithm::StringUtils::getSizeWithCommas($input);
   my $expected = "1,824,572,832";
   cmp_ok($output, 'eq', $expected, 'getSizeFromReadableString');
}

sub testRepairUnicodes {
   my $input = "“test” — ʼ";
   my $output = Algorithm::StringUtils::repair_unicodes(\$input);
   my $expected = "\"test\" - '";
   cmp_ok($output, 'eq', $expected, 'testRepairUnicodes');
}

sub testObjToXml {
   my $refData = [
    {
                fname       => 'Fred',
                lname       => 'Flintstone',
                residence   => 'Bedrock'
    },
    {
                fname       => 'Barney',
                lname       => 'Rubble',
                residence   => 'Bedrock'
    }
   ];
   my $output = Algorithm::StringUtils::objToXml($refData);
   my $expected_regex = qr/<perldata>
 <arrayref memory_address="0x\w+">
  <item key="0">
   <hashref memory_address="0\w+">
    <item key="fname">Fred<\/item>
    <item key="lname">Flintstone<\/item>
    <item key="residence">Bedrock<\/item>
   <\/hashref>
  <\/item>
  <item key="1">
   <hashref memory_address="0x\w+">
    <item key="fname">Barney<\/item>
    <item key="lname">Rubble<\/item>
    <item key="residence">Bedrock<\/item>
   <\/hashref>
  <\/item>
 <\/arrayref>
<\/perldata>/;
   ok($output =~ $expected_regex, 'objToXml');
}

sub testXmlToObj {
   my $xml = q|
  <perldata>
   <arrayref>
    <item key="0">
     <hashref>
        <item key="fname">Fred</item>
        <item key="lname">Flintstone</item>
        <item key="residence">Bedrock</item>
     </hashref>
    </item>
    <item key="1">
     <hashref>
        <item key="fname">Barney</item>
        <item key="lname">Rubble</item>
        <item key="residence">Bedrock</item>
     </hashref>
    </item>
   </arrayref>
  </perldata>
  |;
  
  my $output = Algorithm::StringUtils::xmlToObj($xml);
  my $expectedArrayRef = [
          {
            'lname' => 'Flintstone',
            'residence' => 'Bedrock',
            'fname' => 'Fred'
          },
          {
            'fname' => 'Barney',
            'lname' => 'Rubble',
            'residence' => 'Bedrock'
          }
        ];
  is_deeply($output, $expectedArrayRef, 'xmlToObj');
}

sub testToBase64String {
   my $input = "this is a test string";
   my $actual = Algorithm::StringUtils::toBase64String($input);
   my $expected = "dGhpcyBpcyBhIHRlc3Qgc3RyaW5n\n";
   cmp_ok($actual, 'eq', $expected, 'toBase64String');
}

sub testFromBase64String {
   my $input = "dGhpcyBpcyBhIHRlc3Qgc3RyaW5n\n";
   my $actual = Algorithm::StringUtils::fromBase64String($input);
   my $expected = "this is a test string";
   cmp_ok($actual, 'eq', $expected, 'fromBase64String');
}

sub testToJsonString {
   my %input = ('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5);
   my $actual = Algorithm::StringUtils::toJsonString(\%input);
   my $expected = '{"a":1,"b":2,"c":3,"d":4,"e":5}';
   cmp_ok($actual, 'eq', $expected, 'toJsonString');
}

sub testFromJsonString {
   my $input = '{"a":1,"b":2,"c":3,"d":4,"e":5}';
   my $actual = Algorithm::StringUtils::fromJsonString($input);
   my $expected = {'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5};
   is_deeply($actual, $expected, 'fromJsonString');
}

done_testing;

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2016 by Calvin Lee

