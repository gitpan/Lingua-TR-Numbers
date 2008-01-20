use 5.006;
use Module::Build;

Module::Build->new(
   module_name => 'Lingua::TR::Numbers',
   license     => 'perl',
   requires    => {
      'Test::More' => '0.40',
   },
   recommends  => {},
   sign        => 0,
   dist_author => 'Burak Gursoy <burak@cpan.org>',
)->create_build_script;
