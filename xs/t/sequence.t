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

# Basic tests of sequences.
# The matrix is separation (none/perl5/proper);
# and minimium count (0, 1, 3);
# keep vs. no-keep.

use 5.010;
use strict;
use warnings;

use Test::More tests => 71;
use lib 'tool/lib';
use Marpa::XS::Test;

BEGIN {
    Test::More::use_ok('Marpa::XS');
}

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}   if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return '(' . join( q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

sub run_sequence_test {
    my ( $minimum, $separation, $keep ) = @_;

    my @terminals       = ('A');
    my @separation_args = ();
    if ( $separation ne 'none' ) {
        push @separation_args, separator => 'sep';
        push @terminals, 'sep';
    }
    if ( $separation eq 'proper' ) {
        push @separation_args, proper => 1;
    }

    my $grammar = Marpa::XS::Grammar->new(
        {   start => 'TOP',
            strip => 0,
            rules => [
                {   lhs  => 'TOP',
                    rhs  => [qw/A/],
                    min  => $minimum,
                    keep => $keep,
                    @separation_args
                },
            ],
            default_action     => 'main::default_action',
            default_null_value => q{},
        }
    );

    $grammar->set( { terminals => \@terminals } );

    $grammar->precompute();

    # Number of symbols to test at the higher numbers is
    # more or less arbitrary.  You really need to test 0 .. 3.
    # And you ought to test a couple of higher values,
    # say 5 and 10.
    SYMBOL_COUNT: for my $symbol_count ( 0, 1, 2, 3, 5, 10 ) {

        next SYMBOL_COUNT if $symbol_count < $minimum;
        my $test_name =
              "min=$minimum;"
            . ( $keep ? 'keep;' : q{} )
            . ( $separation ne 'none' ? "$separation;" : q{} )
            . ";count=$symbol_count";
        my $recce = Marpa::XS::Recognizer->new( { grammar => $grammar } );

        my @expected       = ();
        my $last_symbol_ix = $symbol_count - 1;
        SYMBOL_IX: for my $symbol_ix ( 0 .. $last_symbol_ix ) {
            push @expected, 'a';
            defined $recce->read( 'A', 'a' )
                or die 'Parsing exhausted';
            next SYMBOL_IX if $separation eq 'none';
            next SYMBOL_IX
                if $symbol_ix >= $last_symbol_ix
                    and $separation ne 'perl5';
            if ($keep) {
                push @expected, q{!};
            }
            defined $recce->read( 'sep', q{!} )
                or die 'Parsing exhausted';
        } ## end for my $symbol_ix ( 0 .. $last_symbol_ix )

        $recce->end_input();

        my $value_ref = $recce->value();
        my $value = $value_ref ? ${$value_ref} : 'No parse';

        my $expected = join q{;}, @expected;
        if ( @expected > 1 ) {
            $expected = "($expected)";
        }
        Test::More::is( $value, $expected, $test_name );

    } ## end for my $symbol_count ( 0, 1, 2, 3, 5, 10 )

    return;
} ## end sub run_sequence_test

for my $minimum ( 0, 1, 3 ) {
    run_sequence_test( $minimum, 'none', 0 );
    for my $separation (qw(proper perl5)) {
        for my $keep ( 0, 1 ) {
            run_sequence_test( $minimum, $separation, $keep );
        }
    }
} ## end for my $minimum ( 0, 1, 3 )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
