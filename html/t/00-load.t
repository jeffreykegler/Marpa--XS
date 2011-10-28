#!perl
# This software is copyright (c) 2011 by Jeffrey Kegler
# This is free software; you can redistribute it and/or modify it
# under the same terms as the Perl 5 programming language system
# itself.

use 5.010;
use warnings;
use strict;

use Test::More tests => 4;

use Carp;
use Data::Dumper;

Test::More::use_ok('Marpa::HTML');

Test::More::ok( defined $Marpa::HTML::TIMESTAMP, 'Marpa::HTML Timestamp defined' );
Test::More::diag('Using Marpa::HTML ', $Marpa::HTML::VERSION, q{ }, $Marpa::HTML::TIMESTAMP);

SKIP: {
   skip "Not Using PP", 1 if not $Marpa::HTML::MARPA_MODULE eq 'Marpa::PP';
   Test::More::ok( defined $Marpa::PP::TIMESTAMP, 'Marpa::PP Timestamp defined' );
   Test::More::diag('Using Marpa::PP ', $Marpa::PP::VERSION, q{ }, $Marpa::PP::TIMESTAMP);
}

SKIP: {
   skip "Not Using XS", 1 if not $Marpa::HTML::MARPA_MODULE eq 'Marpa::XS';
   Test::More::ok( defined $Marpa::XS::TIMESTAMP, 'Marpa::XS Timestamp defined' );
   Test::More::diag('Using Marpa::XS ', $Marpa::XS::VERSION, q{ }, $Marpa::XS::TIMESTAMP);
}

1;    # In case used as "do" file

