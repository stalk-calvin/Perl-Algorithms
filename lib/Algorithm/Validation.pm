package Algorithm::Validation;

use strict;

# Validation Measures
use constant PARAM_NUMERIC_REGEX          => qr/^(\d+)$/;
use constant PARAM_PRIMARY_ID_REGEX       => qr/^(\d{1,10})$/;
use constant PARAM_AMOUNT_REGEX           => qr/^(\d+(\.\d*)?)$/;
use constant PARAM_FLOAT_REGEX            => qr/^(\d+(?:\.\d*)?)$/;
use constant PARAM_IP_REGEX               => qr/^((\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}))$/;
use constant PARAM_EMAIL_REGEX            => qr/^(?:[\w\-]+\.?)+\w@([\w\-]+\.+\w{2,})$/;

# only word chars (letters, numbers, and underscore) are allowed.
use constant PARAM_ALPHA_NUME_UNDER_REGEX => qr/^(\w+)$/;

sub v_alpha_nume {
   my $value = shift;
   return undef if not length $value;
   return ($value =~ PARAM_ALPHA_NUME_UNDER_REGEX)[0];
}
sub v_id {
   my $value = shift;
   return undef if not length $value;
   return ($value =~ PARAM_PRIMARY_ID_REGEX)[0];
}
sub v_numeric {
   my $value = shift;
   return undef if not length $value;
   return ($value =~ PARAM_NUMERIC_REGEX)[0];
}
sub v_float {
   my $value = shift;
   return undef if not length $value;
   return ($value =~ PARAM_FLOAT_REGEX)[0];
}
sub v_ip {my $ip = shift; return ($ip =~ PARAM_IP_REGEX)[0]; }
sub v_url {
   my $url = shift;
   $url = 'http://'.$url if ($url !~ m/^(http:\/\/)|(https:\/\/)/);
   return $url;
   # my $mech = WWW::Mechanize->new();
   # $mech->get($url);
   # return $url if ($mech->success);
   # return undef;
}
sub v_email {
   my $email = shift;
   my $options = shift;

   $email =~ s/^\s+|\s+$//g;
   if (not length $email) {
      return undef;
   }
   elsif ($email !~ PARAM_EMAIL_REGEX) {
      return undef;
   }

   if ($options->{skip_mx}) { return $email }

   my ($domain) = $email =~ PARAM_EMAIL_REGEX;
   return $email if (`host -t mx $domain` =~ /handled by \d+ ([\w\-\d\.]+)\./);
   while (($domain) = $domain =~ /[\w\-]*\.([\w\-\.]+\.\w{2,})/) {
      return $email if (`host -t mx $domain` =~ /handled by \d+ ([\w\-\d\.]+)\./);
   }
   return undef;
}

=head1 NAME

Algorithm::Validation - Generic validation module

=head1 SYNOPSIS

use Algorithm::Validation;

Algorithm::Validation::v_id(<table_id>);

=head1 DESCRIPTION

Basic input validation module that validates the field.
Returning the value when valid, or return undef when validation fails.

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=cut

1;


