package Algorithm::DB;

use utf8;
use strict;
use warnings;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);

sub connect_db {
   my $dbname = shift;
   my $dbhost = shift;
   my $dbuser = shift;
   my $dbpass = shift;
   my $options = shift;

   # Connect to DB
   my $printError = $options->{printError};
   $printError = 1 unless defined($printError) && $printError == 0;
   my $dbh = DBI->connect("DBI:Pg:dbname=" . $dbname . ($dbhost?';host=' . $dbhost:''), $dbuser, $dbpass,
                       {
                        PrintError => $printError,
                        RaiseError => $options->{raiseError} || 0,
                        AutoCommit => 1
                       }
                      );
   if (!$dbh) {
      FATAL "Could not connect to DB: " . $DBI::errstr;
   }
   $dbh->{pg_enable_utf8} = 1 if $DBD::Pg::VERSION =~ /^2\./;
   # Connected to DB!
   return $dbh;
}

sub loadDBHostConfig {
    my $sysconfig = shift;

    my $dbhostno = int($sysconfig->{dbhostno});
    if($dbhostno < 1) {
        die "Missing configuration: dbhostno\n";
    }

    my $refDbHostConfig = {};
    for(my $i=1; $i<=$dbhostno; $i++) {
        my $dbhost = $sysconfig->{"dbhost_$i"} || die "Missing configuration: dbhost_$i";
        $refDbHostConfig->{$dbhost} = 1;
    }

    return $refDbHostConfig;
}

sub dbHostOptions {
   my $onlyDbhost = shift;
   my $onlyDbs = shift;
   my $ignoreDbs = shift;
   my $ignoreDbhost = shift;

   my %hashOnlyDbhost = ();
   if($onlyDbhost) {
       $onlyDbhost = lc($onlyDbhost);
       my @dbs = split(/,/, $onlyDbhost);
       %hashOnlyDbhost = map { $_ => 1 } @dbs;
   }
   my %hashOnlyDbs = ();
   if($onlyDbs) {
       $onlyDbs = lc($onlyDbs);
       my @dbs = split(/,/, $onlyDbs);
       %hashOnlyDbs = map { $_ => 1 } @dbs;
   }
   my %hashIgnoreDbs = ();
   if($ignoreDbs) {
       $ignoreDbs = lc($ignoreDbs);
       INFO "Ignore dbs:$ignoreDbs";
       my @dbs = split(/,/, $ignoreDbs);
       %hashIgnoreDbs = map { $_ => 1 } @dbs;
   }
   my %hashIgnoreDbhost = ();
   if($ignoreDbhost) {
       $ignoreDbhost = lc($ignoreDbhost);
       my @dbs = split(/,/, $ignoreDbhost);
       %hashIgnoreDbhost = map { $_ => 1 } @dbs;
   }

   return (\%hashOnlyDbhost, \%hashOnlyDbs, \%hashIgnoreDbs, \%hashIgnoreDbhost);
}

sub list_dbs {
   my $dbh = shift || FATAL "dbh argument required";
   my $sth = $dbh->prepare(q|SELECT datname FROM pg_database WHERE datistemplate IS FALSE AND datname != 'phppgadmin'|) ||
      FATAL "prepare failed: " . $DBI::errstr;
   $sth->execute ||
      FATAL "execute failed: " . $DBI::errstr;

   my @dbs;
   my $db;
   $sth->bind_col(1,\$db);
   while ($sth->fetch) {
      push(@dbs,$db);
   }
   return @dbs;
}

1;
__END__

=head1 AUTHOR

Calvin Lee, E<lt>stalk.calvin@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright/Licensed (C) 2017 by Calvin Lee


