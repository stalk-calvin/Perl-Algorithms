package Algorithm::MIME;

use utf8;
use strict;
use warnings;

use Encode;
use Encode::Detect;

sub decode_charset_mimewords {
   my $string = shift;
   return decode_mimewords(decode_charset($string));
}

sub decode_charset {
   my $string = shift;
   return $string if !defined $string;

   if (!Encode::is_utf8($string)) {
      $string = Encode::Detect::decode("Detect",$string);
   }
   return $string;
}

sub decode_mimewords {
   my $string = shift;
   return $string if !defined $string;

   if ($string) {
      #my $charset = Encode::Detect::Detector::detect($string);
      $string = Encode::decode('MIME-Header',$string);
   }
   return $string;
}

sub repair_unicodes {
   my $text_ref = shift;
   my $options = shift;
   
   $options->{'skip_strip'} ||= 0;
   
   my $doubleQuote = '"';
   if($options->{useTwoDoubleQuotes}) {
    $doubleQuote = '""';
   }

   # LEFT DOUBLE QUOTATION MARK (U+201C)
   # RIGHT DOUBLE QUOTATION MARK (U+201D)
   # DOUBLE HIGH-REVERSED-9 QUOTATION MARK (U+201F)
   # HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT (U+275D)
   # HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT (U+275E)
   # REVERSED DOUBLE PRIME QUOTATION MARK (U+301D)
   # DOUBLE PRIME QUOTATION MARK (U+301E)
   # FULLWIDTH QUOTATION MARK (U+FF02)
   $$text_ref =~ s/[\x{201C}\x{201D}\x{201F}\x{201F}\x{275E}\x{301D}\x{301E}\x{FF02}]/$doubleQuote/g;

   # APOSTROPHE (U+0027)
   # LEFT SINGLE QUOTATION MARK (U+2018)
   # RIGHT SINGLE QUOTATION MARK (U+2019)
   # MODIFIER LETTER APOSTROPHE (U+02BC)
   # NKO HIGH TONE APOSTROPHE (U+07F4)
   # FULLWIDTH APOSTROPHE (U+FF07)
   $$text_ref =~ s/[\x{07F4}\x{FF07}\x{02BC}\x{0027}\x{2018}\x{2019}]/'/g;

   # U+002D is hyphen-minus | U+2010 is hyphen | U+2013 is an endash | U+2014 is an emdash
   $$text_ref =~ s/[\x{002D}\x{2010}\x{2013}\x{2014}]/-/g;

   # U+2044 is fraction slash U+002F is solidus
   $$text_ref =~ s/[\x{2044}\x{002F}]/\//g;

   # U+2026 is an ellipsis
   $$text_ref =~ s/\x{2026}/.../g;

   if($options->{translateAdditionalChars}) {
      # single low-9 quotation mark (U+201A)
      # single high-reversed-9 quotation mark (U+201B)
      $$text_ref =~ s/[\x{201A}\x{201B}]/'/g;
      
      # double low-9 quotation mark (U+201E)
      # low double prime quotation mark (U+301F)
      $$text_ref =~ s/[\x{201E}]/$doubleQuote/g;
      $$text_ref =~ s/[\x{301F}]/$doubleQuote/g;
   }
   
   return $$text_ref;
}

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2016 by Calvin Lee

