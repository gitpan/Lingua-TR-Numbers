#!/usr/bin/env perl -w
use strict;
BEGIN { do 't/skip.test' or die "Can't include skip.test!" }

eval {require Test::Pod::Coverage;};
if($@) {
   plan skip_all => "Test::Pod::Coverage required for testing pod coverage";
} else {
   plan tests => 1;
   Test::Pod::Coverage::pod_coverage_ok('Lingua::TR::Numbers', {trustme => [qw/DEBUG/]});
}
