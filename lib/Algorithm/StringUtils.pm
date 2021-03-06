package Algorithm::StringUtils;

use utf8;
use strict;
use warnings;

use XML::Dumper;
use MIME::Base64;
use JSON;

my @SIZES = ('', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y');

sub getReadableSize {
   my $size = shift;
   my $suffixMax = shift;
   
   return "0B" unless defined $size;
   
   $suffixMax = 'G' unless($suffixMax);
   
   my $need2decimal = 0;
   
   my $suffix = '';
   foreach my $sizeLetter (@SIZES) {
       $suffix = $sizeLetter;
       $need2decimal = 1 if (defined $suffix && $suffix eq 'G');
       last if $size < 1024;
       last if $suffix eq $suffixMax;
       last if $suffix eq 'Y';
       $size /= 1024;
   }
   
   my $num;
   if($need2decimal) {
       $num = sprintf("%.2f", $size);
       $num = $1 if ($num =~ /(\d+)\.00$/);
   } else {
       $num = sprintf("%d", $size + 0.5);
   }

   return "$num $suffix" . "B";
}

sub getSizeFromReadableString {
    my $splitsize = shift;

    my $realsize = 0;
    if ($splitsize =~ /^(\d+)(\.\d*)?\s*(|K|M|G|T|P|E|Z|Y)B?$/i) {
        $realsize = $1;
        $realsize .= $2 if($2);
        if($3) {
            my $suffix = uc($3);
            my $base = 1;
            foreach my $size (@SIZES) {
                $base *= 1024;
                last if ($suffix eq $size);
            }
            $realsize *= $base;
        }
    }
    
    return $realsize;
}

sub getPrettySizeText {
   my $len = shift;

   if ($len >= 1048576){
      $len = int($len/1048576*10+0.5)/10 . "MB";
   } elsif ($len >= 2048) {
      $len =  int(($len/1024)+0.5) . "KB";
   } else {
      $len = $len . "B";
   }
   return $len;
}

sub getSizeWithCommas {
    my $integer = shift;
    
    my @parts = split(//, $integer);
    
    my $newsize = "";
    my $pos = 0;
    for(my $i=$#parts; $i>=0; $i--) {
       if($pos > 0 && $pos % 3 == 0) {
          $newsize = "," . $newsize;
       }
       $newsize = $parts[$i] . $newsize;
       $pos++;
    }
    
    return $newsize;
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


sub objToXml {
    my $refData = shift;

    my $xmlstr = "";
    return $xmlstr unless ref($refData);
    
    eval {
        my $xmldumper = new XML::Dumper;    
        $xmlstr = $xmldumper->pl2xml($refData);
    };

    return $xmlstr;
}

sub xmlToObj {
    my $xml = shift;

    my $refData = undef;
    return $refData unless(defined $xml);
    eval {    
        my $xmldumper = new XML::Dumper;
        $refData = $xmldumper->xml2pl($xml);
    };

    return $refData;
}

sub toBase64String {
    my $decoded = shift;
    
    return $decoded unless (defined $decoded);
    
    my $encoded;
    eval {
        $encoded = MIME::Base64::encode($decoded);
    };
    if($@) {
        $encoded = $decoded;
    }
    $encoded = $decoded if ($encoded eq "");
    
    return $encoded;
}

sub fromBase64String {
    my $encoded = shift;
    
    return $encoded unless (defined $encoded);
    
    my $result;
    
    eval {
        $result = MIME::Base64::decode($encoded);
    };
    if($@) {
        $result = $encoded;
    }
    $result = $encoded if ($result eq "");
    
    return $result;
}


sub toJsonString {
    my $refData = shift;

    my $jsonStr = "";
    my $json = new JSON;
    $json->canonical(1);
    eval {
        $jsonStr = $json->utf8->encode($refData);
    };
    if($@) {
        return "";
    }
    
    return $jsonStr;
}

sub fromJsonString {
    my $jsonStr = shift;

    my $refData = undef;
    my $json = new JSON;
    eval {
        $refData = $json->utf8->decode($jsonStr);
    };    
    if($@) {
        return undef;
    }
        
    return $refData;
}

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2016 by Calvin Lee

