#!perl

use 5.010;
use warnings;
use strict;

use Test::More tests => 1;
use English qw( -no_match_vars );

my $loaded_marpa_pp = eval { require Marpa::PP; 1 };
my $loaded_marpa;
SKIP: {
    skip 'No Marpa::PP, which is OK', 1 unless $loaded_marpa_pp;
    my $loaded_marpa = eval { require Marpa::XS; 1 };
    Test::More::ok(!$loaded_marpa, 'Marpa::PP incompatible with Marpa::XS');
}

