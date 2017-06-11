use 5.008000;
use ExtUtils::MakeMaker qw(prompt WriteMakefile);

my $tests = join ' ', glob ('t/*.t');

WriteMakefile(
    NAME              => 'lib/Algorithm',
    LICENSE           => 'apache',
    AUTHOR            => 'Calvin Lee <stalk.calvin@gmail.com>',
    test              => {TESTS => $tests},
    TEST_REQUIRES => {
       'Test::More' => 1.302067,
    },
    BUILD_REQUIRES => {
       'XML::Dumper' => 0.81,
       'MIME::Base64' => 3.15,
       'Log::Log4perl' => 1.49,
       'JSON' => 2.90
    },
);
