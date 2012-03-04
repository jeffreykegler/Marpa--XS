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

# Regression test for a chaf bug

use 5.010;
use strict;
use warnings;

use Test::More tests => 3;
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
    return '(' . ( join q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

my $grammar = Marpa::XS::Grammar->new(
    {   start => 'S',
        strip => 0,
        rules => [
            [ 'S', [qw/A B B B C C /] ],
            [ 'A', [qw/a/] ],
            [ 'B', [qw/a/] ],
            [ 'B', [] ],
            [ 'C', [] ],
        ],
        default_null_value => q{},
        default_action     => 'main::default_action',
    }
);

$grammar->set( { terminals => ['a'], } );

$grammar->precompute();

Marpa::XS::Test::is( $grammar->show_rules, <<'EOS', 'Aycock/Horspool Rules' );
0: S -> A B B B C C /* !used */
1: A -> a
2: B -> a
3: B -> /* empty !used */
4: C -> /* empty !used */
5: S -> A B S[R0:2] /* vrhs real=2 */
6: S -> A B B[] B[] C C
7: S -> A B[] S[R0:2] /* vrhs real=2 */
8: S -> A B[] B[] B[] C C
9: S[R0:2] -> B B C C /* vlhs real=4 */
10: S[R0:2] -> B B[] C C /* vlhs real=4 */
11: S[R0:2] -> B[] B C C /* vlhs real=4 */
12: S['] -> S /* vlhs real=1 */
EOS

my $recce = Marpa::XS::Recognizer->new( { grammar => $grammar } );

$recce->read( 'a', 'a' );

my $value_ref = $recce->value();
my $value = defined $value_ref ? ${$value_ref} : 'undef';
Test::More::is( $value, '(a;;;;;)', 'subp test' );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
