#!perl
# Copyright 2012 Jeffrey Kegler
# This file is part of Marpa::XS.  Marpa::XS is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::XS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::XS.  If not, see
# http://www.gnu.org/licenses/.

use 5.010;
use warnings;
use strict;

use Test::More tests => 5;

use Carp;
use Data::Dumper;

BEGIN {
    Test::More::use_ok('Marpa::XS');
}

defined $INC{'Marpa/XS.pm'}
    or Test::More::BAIL_OUT('Could not load Marpa::XS');

Test::More::ok( defined &Marpa::XS::version, 'Marpa::XS::version defined' );

my @version = Marpa::XS::version();
Test::More::is( $version[0], 0, 'XS major version' );
Test::More::is( $version[1], 1, 'XS minor version' );
Test::More::is( $version[2], 0, 'XS micro version' );

Test::More::diag( 'Using Marpa::XS ',
    $Marpa::XS::VERSION, q{ }, $Marpa::XS::TIMESTAMP );

1;    # In case used as "do" file

