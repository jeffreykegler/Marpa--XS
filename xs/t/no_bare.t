#!perl

use 5.010;
use warnings;
use strict;

use Test::More tests => 1;
use English qw( -no_match_vars );

my $loaded_marpa_bare = eval { require Marpa; 1 };
my $loaded_marpa;
SKIP: {
    skip 'No Marpa, which is OK', 1 unless $loaded_marpa_bare;
    my $loaded_marpa = eval { require Marpa::XS; 1 };
    Test::More::ok(!$loaded_marpa, 'Marpa incompatible with Marpa::XS');
}

