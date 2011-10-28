#!perl
# Copyright 2011 Jeffrey Kegler
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

use Test::More tests => 1;
use English qw( -no_match_vars );

my $loaded_marpa_bare = eval { require Marpa; 1 };
my $loaded_marpa;
SKIP: {
    skip 'No Marpa, which is OK', 1 unless $loaded_marpa_bare;
    my $loaded_marpa = eval { require Marpa::XS; 1 };
    Test::More::ok(!$loaded_marpa, 'Marpa incompatible with Marpa::XS');
}

