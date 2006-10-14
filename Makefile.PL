use ExtUtils::MakeMaker;
use 5.006;

WriteMakefile(
   'NAME'         => 'Lingua::TR::Numbers',
   'VERSION_FROM' => 'lib/Lingua/TR/Numbers.pm',
   'PREREQ_PM'    => {},
   ($] >= 5.005 ? (
   AUTHOR   => 'Burak Gursoy <burak@cpan.org>',
   ABSTRACT => 'Converts numbers into Turkish text',
   ) : ()),
   PL_FILES => {},
);
