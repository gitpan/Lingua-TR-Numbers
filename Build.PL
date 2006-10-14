use 5.006;
use strict;

eval { require Module::Build; };

if($@) {
   warn "Module::Build failed: $@\n";
   warn "Falling back to MakeMaker ...\n";
   do 'Makefile.PL';
} else {
   Module::Build->new(
      module_name => 'Lingua::TR::Numbers',
      license     => 'perl',
      requires    => {},
      recommends  => {},
      sign        => 0,
      dist_author => 'Burak Gursoy <burak@cpan.org>',
   )->create_build_script;
}
