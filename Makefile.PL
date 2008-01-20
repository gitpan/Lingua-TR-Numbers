use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
   'NAME'         => 'Lingua::TR::Numbers',
   'VERSION_FROM' => 'lib/Lingua/TR/Numbers.pm',
   'PREREQ_PM'    => {
      'Test::More' => '0.40',
   },
   ($] >= 5.005 ? (
   AUTHOR   => 'Burak Gursoy <burak@cpan.org>',
   ABSTRACT => 'Converts numbers into Turkish text',
   ) : ()),
   PL_FILES => {},
);
