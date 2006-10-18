use 5.006;
use strict;
use utf8;
use Test;
BEGIN { plan tests => 58 }

use Lingua::TR::Numbers qw(num2tr num2tr_ordinal);
print "# Using Lingua::TR::Numbers v$Lingua::TR::Numbers::VERSION\n";
ok 1;

sub N ($) { num2tr(        $_[0]) }
sub O ($) { num2tr_ordinal($_[0]) }

ok N   0, 'sıfır';
ok N   1, 'bir';
ok N   2, 'iki';
ok N   3, 'üç';
ok N   4, 'dört';
ok N   5, 'beş';
ok N   6, 'altı';
ok N   7, 'yedi';
ok N   8, 'sekiz';
ok N   9, 'dokuz';
ok N  10, 'on';
ok N  11, 'on bir';
ok N  12, 'on iki';
ok N  13, 'on üç';
ok N  14, 'on dört';
ok N  15, 'on beş';
ok N  16, 'on altı';
ok N  17, 'on yedi';
ok N  18, 'on sekiz';
ok N  19, 'on dokuz';
ok N  20, 'yirmi';
ok N  21, 'yirmi bir';
ok N  22, 'yirmi iki';
ok N  23, 'yirmi üç';
ok N  24, 'yirmi dört';
ok N  25, 'yirmi beş';
ok N  26, 'yirmi altı';
ok N  27, 'yirmi yedi';
ok N  28, 'yirmi sekiz';
ok N  29, 'yirmi dokuz';
ok N  30, 'otuz';
ok N  99, 'doksan dokuz';

ok N  103, 'yüz üç';
ok N  139, 'yüz otuz dokuz';

ok num2tr_ordinal(133), 'yüz otuz üçüncü';

ok N '3.14159'  , 'üç nokta bir dört bir beş dokuz';
ok N '-123'     , 'eksi yüz yirmi üç';
ok N '+123'     , 'artı yüz yirmi üç';
ok N '+123'     , 'artı yüz yirmi üç';

ok N '0.0001'   , 'sıfır nokta sıfır sıfır sıfır bir';
ok N '-14.000'  , 'eksi on dört nokta sıfır sıfır sıfır';

# and maybe even:
ok N '-1.53e34' , 'eksi bir nokta beş üç çarpı on üzeri otuz dört';
ok N '-1.53e-34', 'eksi bir nokta beş üç çarpı on üzeri eksi otuz dört';
ok N '+19e009'  , 'artı on dokuz çarpı on üzeri dokuz';

ok N "263415"   , "iki yüz altmış üç bin dört yüz on beş";

ok N  "5001"    , "beş bin bir";
ok N "-5001"    , "eksi beş bin bir";
ok N "+5001"    , "artı beş bin bir";

ok !defined N "abc";
ok !defined N "00.0.00.00.0.00.0.0";
ok          N "1,000,000" , "bir milyon";
ok          N "1,0,00,000", "bir milyon";
ok !defined N "5 bananas";
ok !defined N "x5x";
ok !defined N "";
ok !defined N undef;

print "# TAMAM, bitti.\n";
ok 1;
