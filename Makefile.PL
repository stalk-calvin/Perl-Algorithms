use 5.008000;
use ExtUtils::MakeMaker qw(prompt WriteMakefile);

my $response;

my $tests = join ' ', glob ('t/*.t');

WriteMakefile(
    NAME              => 'lib/Algorithm',
    VERSION_FROM      => 'lib/Algorithm.pm',
    test              => {TESTS => $tests},
);
