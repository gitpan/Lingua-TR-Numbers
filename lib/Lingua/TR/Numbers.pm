package Lingua::TR::Numbers;
require 5.006;
#BEGIN { if($] < 5.006) { package utf8; $INC{'utf8.pm'} = 1; } }
use utf8;
use strict;
use vars qw(@ISA $VERSION @EXPORT @EXPORT_OK %D %Mult %Card2ord %Card2ordTR);
use constant RE_UNLU => qr{([aeıiuüoö])}o; # must be defined after use utf8;
use constant IS_LEGACY => $] < 5.006;

require Exporter;

BEGIN { *DEBUG = sub () {0} unless defined &DEBUG } # setup a DEBUG constant

@ISA       = qw(Exporter);
$VERSION   = '0.1';
@EXPORT_OK = qw( num2tr num2tr_ordinal );

@D{0 .. 10, 20, 30,40,50,60,70,80,90} = qw|
 sıfır
 bir   iki   üç   dört beş  altı   yedi   sekiz  dokuz  on
       yirmi otuz kırk elli altmış yetmiş seksen doksan 
|;

@Card2ord{  qw| bir     iki    üç     dört     beş     altı    yedi    sekiz     dokuz     |}
 =          qw| birinci ikinci üçüncü dördüncü beşinci altıncı yedinci sekizinci dokuzuncu |;


%Card2ordTR = qw(
                   a   ncı
                   e   nci
                   ı   ncı
                   i   nci
                   u   ncu
                   ü   ncü
                   o   ncu
                   ö   ncü
);

POPULATE: {
  my @large = qw<
                   bin       milyon    milyar 
                   trilyon   katrilyon kentilyon
                   seksilyon septilyon oktilyon
                   nobilyon  desilyon
              >;
  my $c = 0;
  $Mult{$c++} = $_ for '', @large;
}

#==========================================================================

sub num2tr_ordinal {
   #  Cardinals are [bir iki üç...]
   #  Ordinals  are [birinci ikinci üçüncü...]
  
  return undef unless defined $_[0] and length $_[0];
  my($x) = $_[0];
  
  $x = num2tr($x);
  return $x unless $x;
  $x =~ s/(\w+)$//s   or return $x . ".";
  my $last = $1;
  my @l = split //, $last;
  my $ok;
  my $step = 1;;
  for my $l (reverse @l) {
     next if not $l;
     if($l =~ RE_UNLU) {
        $ok = $1;
        last;
     }
     $step++;
  }
  if(!$ok) {
     #return $last if IS_LEGACY;
     #die "Can not happen: '$last'";
     return undef;
  }

  $last = $Card2ord{$last} || sub {
     my $val = $Card2ordTR{$ok};
     return $last . $val if $step == 1;
     my $letter = (split //, $val)[-1];
     return $last.$letter.$val;
  }->();

  return "$x$last";
}

#==========================================================================

sub num2tr {
  my $x = $_[0];
  return undef unless defined $x and length $x;

  return 'sayı-değil'     if $x eq 'NaN';
  return 'pozitif sonsuz' if $x =~ m/^\+inf(?:inity)?$/si;
  return 'negatif sonsuz' if $x =~ m/^\-inf(?:inity)?$/si;
  return         'sonsuz' if $x =~  m/^inf(?:inity)?$/si;

  return $D{$x} if exists $D{$x};  # the most common cases

  # Make sure it's not in scientific notation:
  {  my $e = _e2tr($x);  return $e if defined $e; }
  
  my $orig = $x;

  $x =~ s/,//g; # nix any commas

  my $sign;
  $sign = $1 if $x =~ s/^([-+])//s;
  
  my($int, $fract);
  if(    $x =~ m<^\d+$>          ) { $int = $x }
  elsif( $x =~ m<^(\d+)\.(\d+)$> ) { $int = $1; $fract = $2 }
  elsif( $x =~ m<^\.(\d+)$>      ) { $fract = $1 }
  else {
    DEBUG and print "Not a number: \"orig\"\n";
    return undef;
  }
  
  DEBUG and printf " Working on Sign[%s]  Int2tr[%s]  Fract[%s]  < \"%s\"\n",
   map defined($_) ? $_ : "nil", $sign, $int, $fract, $orig;
  
  return join ' ', grep defined($_) && length($_),
    _sign2tr($sign),
    _int2tr($int),
    _fract2tr($fract),
  ;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub _sign2tr {
  return undef unless defined $_[0] and length $_[0];  
  return 'negatif' if $_[0] eq '-';
  return 'pozitif' if $_[0] eq '+';
  return "WHAT_IS_$_[0]";
}

sub _fract2tr {    # "1234" => "point one two three four"
  return undef unless defined $_[0] and length $_[0];  
  my $x = $_[0];
  return join ' ', 'nokta', map $D{$_}, split '', $x;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# The real work:

sub _int2tr {
  return undef unless defined $_[0] and length $_[0]
   and $_[0] =~ m/^\d+$/s;

  my($x) = $_[0];

  return $D{$x} if defined $D{$x};  # most common/irreg cases
  
  if( $x =~ m/^(.)(.)$/ ) {
    return  $D{$1 . '0'} . ' ' . $D{$2};
     # like    forty        -     two
      # note that neither bit can be zero at this point
     
  } elsif( $x =~ m/^(.)(..)$/ ) {
    my $tmp = $1 == 1 ? '' : $D{$1}.' ';
    my($h, $rest) = ($tmp.'yüz', $2);
    return $h if $rest eq '00';
    return "$h " . _int2tr(0 + $rest);
  } else {
    return _bigint2tr($x);
  }
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub _bigint2tr {
  return undef unless defined $_[0] and length $_[0]
   and $_[0] =~ m/^\d+$/s;

  my($x) = $_[0];

  my @chunks;  # each:  [ string, exponent ]
  
  {
    my $groupnum = 0;
    my $num;
    while( $x =~ s<(\d{1,3})$><>s ) { # pull at most three digits from the end
      $num = $1 + 0;
      unshift @chunks, [ $num, $groupnum ] if $num;
      ++$groupnum;
    }
    return $D{'0'} unless @chunks;  # rare but possible
  }
  
  my $and;
  # junk
  $and = '' if  $chunks[-1][1] == 0  and  $chunks[-1][0] < 100;
   # The special 'and' that shows up in like "one thousand and eight"
   # and "two billion and fifteen", but not "one thousand [*and] five hundred"
   # or "one million, [*and] nine"

  _chunks2tr( \@chunks );

  $chunks[-2] .= " " if $and and @chunks > 1;
  return "$chunks[0] $chunks[1]" if @chunks == 2;
   # Avoid having a comma if just two units
  return join ", ", @chunks;
}


sub _chunks2tr {
  my $chunks = $_[0];
  return unless @$chunks;
  my @out;
  foreach my $c (@$chunks) {
    push @out,   $c = _groupify( _int2tr( $c->[0] ),  $c->[1] ,$c->[0])  if $c->[0];
  }
  @$chunks = @out;
  return;
}

sub _groupify {
  # turn ("seventeen", 3) => "seventeen billion"
  my($basic, $multnum, $raw) = @_;
  return  $basic unless $multnum;  # the first group is unitless
  DEBUG > 2 and print "  Groupifying $basic x $multnum mults\n";
  return "$basic $Mult{$multnum}"  if  $Mult{$multnum};
   # Otherwise it must be huuuuuge, so fake it with scientific notation
  return "$basic " . "çarpı on üzeri " . num2tr($raw * 3);
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Because I can never remember this:
#
#  3.1E8
#  ^^^   is called the "mantissa"
#      ^ is called the "exponent"
#         (the implicit "10" is the "base" a/k/a "radix")

sub _e2tr {
  my $x = $_[0];

  my($m, $e);
  if( $x =~
    m<
      ^(
        [-+]?  # leading sign
        (?:
          [\d,]+  |  [\d,]*\.\d+  # number
        )
       )
      [eE]
      (-?\d+)   # mantissa, has to be an integer
      $
    >x
  ) {
    ($m, $e) = ($1, $2);
    DEBUG and print "  Scientific notation: [$x] => $m E $e\n";
    $e += 0;
    return num2tr($m) . ' çarpı on üzeri ' . num2tr($e);
  } else {
    DEBUG and print "  Okay, $x isn't in exponential notation\n";
    return undef;
  }
}

#==========================================================================
1;

__END__

#1 milyon    1.000.000
#1 milyar    1.000.000.000
#1 trilyon   1.000.000.000.000
#1 katrilyon 1.000.000.000.000.000
#1 kentilyon 1.000.000.000.000.000.000
#1 seksilyon 1.000.000.000.000.000.000.000
#1 septilyon 1.000.000.000.000.000.000.000.000
#1 oktilyon  1.000.000.000.000.000.000.000.000.000
#1 nobilyon  1.000.000.000.000.000.000.000.000.000.000
#1 desilyon  1.000.000.000.000.000.000.000.000.000.000.000

=head1 NAME

Lingua::TR::Numbers - Converts numbers into Turkish text.

=head1 SYNOPSIS

   use Lingua::TR::Numbers qw(num2tr num2tr_ordinal);
   
   my $x = 234;
   my $y = 54;
   print "Bugün yapman gereken ", num2tr($x), " tane işin var!\n";
   print ucfirst(num2tr_ordinal($y)), " den sonra endişelenmeyi bırakırsın.\n";

prints:

   Bugün yapman gereken iki yüz otuz dört tane işin var!
   Elli dördüncü den sonra endişelenmeyi bırakırsın.

=head1 DESCRIPTION

Lingua::TR::Numbers turns numbers into Turkish text. It exports
(upon request) two functions, C<num2tr> and C<num2tr_ordinal>. 
Each takes a scalar value and returns a scalar value. The return 
value is the Turkish text expressing that number; or if what you 
provided wasn't a number, then they return undef.

This module can handle integers like "12" or "-3" and real numbers like "53.19".

This module also understands exponential notation -- it turns "4E9" into
"dört çarpı 10 üzeri dokuz"). And it even turns "INF", "-INF", "NaN"
into "sonsuz", "negatif sonsuz" and "sayı-değil" respectively.

Any commas in the input numbers are ignored.

=head1 FUNCTIONS

=head2 num2tr

Converts the supplied number into Turkish text.

=head2 num2tr_ordinal

Similar to C<num2tr>, but returns ordinal versions .

=head1 LIMIT

This module supports any numbers upto 999 decillion (999*10**33). Any further 
range is currently not in commnon use and is not implemented.

=head1 SEE ALSO

L<Lingua::EN::Numbers>. L<http://www.radikal.com.tr/haber.php?haberno=66427>
L<http://en.wikipedia.org/wiki/Names_of_large_numbers>.

See C<NumbersTR.pod> (bundled with this distribution) for the Turkish translation of
this documentation.

=head1 CAVEATS

This module' s source file is UTF-8 encoded (without a BOM) and it returns UTF-8
values whenever possible.

Currently, the module won't work with any Perl older than 5.6.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006 Burak Gürsoy. All rights reserved.

This module is based on and includes modified code 
portions of Sean M. Burke's Lingua::EN::Numbers.

Lingua::EN::Numbers is Copyright (c) 2005, Sean M. Burke.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.8.8 or, 
at your option, any later version of Perl 5 you may have available.

=cut
