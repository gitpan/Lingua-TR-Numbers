use 5.006;
use strict;
use utf8;
use Test;

BEGIN { plan tests => 18 }

use Lingua::TR::Numbers qw(num2tr);
ok 1;

print "# Using Lingua::TR::Numbers v$Lingua::TR::Numbers::VERSION\n";

ok num2tr(  0    ), "sıfır";
ok num2tr( '0'   ), "sıfır";
ok num2tr('-0'   ), "negatif sıfır";
ok num2tr( '0.0' ), "sıfır nokta sıfır";
ok num2tr(  '.0' ), "nokta sıfır";
ok num2tr(  1    ), "bir";
ok num2tr(  2    ), "iki";
ok num2tr(  3    ), "üç";
ok num2tr(  4    ), "dört";
ok num2tr( 40    ), "kırk";
ok num2tr( 42    ), "kırk iki";

ok num2tr(400    ), "dört yüz";
ok num2tr( '0.1' ), "sıfır nokta bir";
ok num2tr(  '.1' ), "nokta bir";
ok num2tr(  '.01'), "nokta sıfır bir";


ok num2tr('4003' ), "dört bin üç";

print "# TAMAM, bitti.\n";
ok 1;
