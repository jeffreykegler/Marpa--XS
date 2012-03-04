#!/usr/bin/perl
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
use strict;
use warnings;

use Test::More tests => 3;

use English qw( -no_match_vars );
use Fatal qw( open close );
use lib 'tool/lib';
use Marpa::XS::Test;

BEGIN {
    Test::More::use_ok('Marpa::XS');
}

my $progress_report = q{};

my $grammar = Marpa::XS::Grammar->new(
    {   start         => 'S',
        strip         => 0,
        lhs_terminals => 0,
        rules         => [
            { lhs => 'S',            rhs => [qw/Top_sequence/] },
            { lhs => 'Top_sequence', rhs => [qw/Top Top_sequence/] },
            { lhs => 'Top_sequence', rhs => [qw/Top/] },
            { lhs => 'Top',          rhs => [qw/Upper_Middle/] },
            { lhs => 'Upper_Middle', rhs => [qw/Lower_Middle/] },
            { lhs => 'Lower_Middle', rhs => [qw/Bottom/] },
            { lhs => 'Bottom',       rhs => [qw/T/] },
        ],
    }
);

# Marpa::XS::Display::End

$grammar->precompute();

my $recce = Marpa::XS::Recognizer->new( { grammar => $grammar } );

my $current_earleme;
for ( 1 .. 20 ) { $recce->read('T'); }

# The call to current earleme is useless,
# but provides an example for the docs

# Marpa::XS::Display
# name: current_earleme Example

$current_earleme = $recce->current_earleme();

# Marpa::XS::Display::End

$progress_report = $recce->show_progress();

my $value_ref = $recce->value;
Test::More::ok( $value_ref, 'Parse ok?' );

# Marpa::XS::Display
# name: Debug Leo Example Progress Report
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

Marpa::XS::Test::is( $progress_report,
    <<'END_PROGRESS_REPORT', 'sorted progress report' );
F0 @0-20 S -> Top_sequence .
P1 @20-20 Top_sequence -> . Top Top_sequence
R1:1 @19-20 Top_sequence -> Top . Top_sequence
F1 x20 @0...19-20 Top_sequence -> Top Top_sequence .
P2 @20-20 Top_sequence -> . Top
F2 @19-20 Top_sequence -> Top .
P3 @20-20 Top -> . Upper_Middle
F3 @19-20 Top -> Upper_Middle .
P4 @20-20 Upper_Middle -> . Lower_Middle
F4 @19-20 Upper_Middle -> Lower_Middle .
P5 @20-20 Lower_Middle -> . Bottom
F5 @19-20 Lower_Middle -> Bottom .
P6 @20-20 Bottom -> . T
F6 @19-20 Bottom -> T .
F7 @0-20 S['] -> S .
END_PROGRESS_REPORT

# Marpa::XS::Display::End

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
