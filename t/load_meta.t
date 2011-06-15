use strict;
use warnings;
use Test::More 0.96;
use Test::MockObject 1.09;
use lib 't/lib';
use DM_Tester;

my $loaded;
Test::MockObject->new->fake_module('CPAN::Meta',
  map {
    ( "load_${_}_string" => sub { $loaded = $_[1] } )
  } qw(json yaml)
);

my $mod = 'Dist::Metadata';
eval "require $mod" or die $@;

foreach my $test (
  [ json => j => { 'tar/META.json' => 'j' } ],
  [ yaml => y => { 'tar/META.yml'  => 'y' } ],

  # usually it's spelled .yml but yaml spec suggests .yaml
  [ yaml => y => { 'tar/META.yaml' => 'y' } ],

  # json preferred
  [ json => j => { 'tar/META.json' => 'j', 'tar/META.yaml' => 'y' } ],
  )
{
  my ( $type, $content, $files ) = @$test;
  my $archive = fake_archive( files => $files );

  new_ok( $mod, [ archive => $archive ] )->load_meta;
  is( $loaded, $content, "loaded $type" );
}

# TODO: test no meta file

done_testing;
