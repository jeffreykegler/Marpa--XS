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

# This test case was originally developed as an example
# for the debugging of grammars with Leo items.  Fortunately,
# I found how to create
# much more user-friendly tools for debugging these grammars,
# so now these are simply Leo-oriented regression tests.

use Fatal qw(open close);
use Test::More tests => 8;

use lib 'tool/lib';
use Marpa::XS::Test;

BEGIN {
    Test::More::use_ok('Marpa::XS');
}

## no critic (Subroutines::RequireArgUnpacking)

my $grammar = Marpa::XS::Grammar->new(
    {   start          => 'Statement',
        actions        => 'My_Actions',
        default_action => 'first_arg',
        strip          => 0,
        rules          => [
            {   lhs    => 'Statement',
                rhs    => [qw/Expression/],
                action => 'do_Statement'
            },
            {   lhs    => 'Expression',
                rhs    => [qw/Lvalue AssignOp Expression/],
                action => 'do_Expression'
            },
            {   lhs    => 'Expression',
                rhs    => [qw/Lvalue AddAssignOp Expression/],
                action => 'do_Expression'
            },
            {   lhs    => 'Expression',
                rhs    => [qw/Lvalue MinusAssignOp Expression/],
                action => 'do_Expression'
            },
            {   lhs    => 'Expression',
                rhs    => [qw/Lvalue MultiplyAssignOp Expression/],
                action => 'do_Expression'
            },
            {   lhs    => 'Expression',
                rhs    => [qw/Variable/],
                action => 'do_Expression'
            },
            { lhs => 'Lvalue', rhs => [qw/Variable/] },
        ],
    }
);

$grammar->precompute();

my $recce = Marpa::XS::Recognizer->new( { grammar => $grammar } );

$recce->read( 'Variable',         'a' );
$recce->read( 'AssignOp',         q{=} );
$recce->read( 'Variable',         'b' );
$recce->read( 'AddAssignOp',      q{+=} );
$recce->read( 'Variable',         'c' );
$recce->read( 'MinusAssignOp',    q{-=} );
$recce->read( 'Variable',         'd' );
$recce->read( 'MultiplyAssignOp', q{*=} );
$recce->read( 'Variable',         'e' );

%My_Actions::VALUES = ( a => 711, b => 47, c => 1, d => 2, e => 3 );

sub My_Actions::do_Statement {
    return join q{ }, map { $_ . q{=} . $My_Actions::VALUES{$_} }
        sort keys %My_Actions::VALUES;
}

sub My_Actions::do_Expression {
    my ( undef, $lvariable, $op, $rvalue ) = @_;
    my $original_value = $My_Actions::VALUES{$lvariable};
    return $original_value if not defined $rvalue;
    return
        $My_Actions::VALUES{$lvariable} =
          $op eq q{*=} ? ( $original_value * $rvalue )
        : $op eq q{+=} ? ( $original_value + $rvalue )
        : $op eq q{-=} ? ( $original_value - $rvalue )
        : $rvalue

} ## end sub My_Actions::do_Expression

sub My_Actions::first_arg { return $_[1] }

## use critic

my $show_symbols_output = $grammar->show_symbols();

Marpa::XS::Test::is( $show_symbols_output,
    <<'END_SYMBOLS', 'Leo Example Symbols' );
0: Statement, lhs=[0] rhs=[7] terminal
1: Expression, lhs=[1 2 3 4 5] rhs=[0 1 2 3 4] terminal
2: Lvalue, lhs=[6] rhs=[1 2 3 4] terminal
3: AssignOp, lhs=[] rhs=[1] terminal
4: AddAssignOp, lhs=[] rhs=[2] terminal
5: MinusAssignOp, lhs=[] rhs=[3] terminal
6: MultiplyAssignOp, lhs=[] rhs=[4] terminal
7: Variable, lhs=[] rhs=[5 6] terminal
8: Statement['], lhs=[7] rhs=[]
END_SYMBOLS

my $show_rules_output = $grammar->show_rules();

Marpa::XS::Test::is( $show_rules_output, <<'END_RULES', 'Leo Example Rules' );
0: Statement -> Expression
1: Expression -> Lvalue AssignOp Expression
2: Expression -> Lvalue AddAssignOp Expression
3: Expression -> Lvalue MinusAssignOp Expression
4: Expression -> Lvalue MultiplyAssignOp Expression
5: Expression -> Variable
6: Lvalue -> Variable
7: Statement['] -> Statement /* vlhs real=1 */
END_RULES

my $show_AHFA_output = $grammar->show_AHFA();

Marpa::XS::Test::is( $show_AHFA_output, <<'END_AHFA', 'Leo Example AHFA' );
* S0:
Statement['] -> . Statement
 <Statement> => S2; leo(Statement['])
* S1: predict
Statement -> . Expression
Expression -> . Lvalue AssignOp Expression
Expression -> . Lvalue AddAssignOp Expression
Expression -> . Lvalue MinusAssignOp Expression
Expression -> . Lvalue MultiplyAssignOp Expression
Expression -> . Variable
Lvalue -> . Variable
 <Expression> => S3; leo(Statement)
 <Lvalue> => S4
 <Variable> => S5
* S2: leo-c
Statement['] -> Statement .
* S3: leo-c
Statement -> Expression .
* S4:
Expression -> Lvalue . AssignOp Expression
Expression -> Lvalue . AddAssignOp Expression
Expression -> Lvalue . MinusAssignOp Expression
Expression -> Lvalue . MultiplyAssignOp Expression
 <AddAssignOp> => S7; S8
 <AssignOp> => S6; S7
 <MinusAssignOp> => S7; S9
 <MultiplyAssignOp> => S10; S7
* S5:
Expression -> Variable .
Lvalue -> Variable .
* S6:
Expression -> Lvalue AssignOp . Expression
 <Expression> => S11; leo(Expression)
* S7: predict
Expression -> . Lvalue AssignOp Expression
Expression -> . Lvalue AddAssignOp Expression
Expression -> . Lvalue MinusAssignOp Expression
Expression -> . Lvalue MultiplyAssignOp Expression
Expression -> . Variable
Lvalue -> . Variable
 <Lvalue> => S4
 <Variable> => S5
* S8:
Expression -> Lvalue AddAssignOp . Expression
 <Expression> => S12; leo(Expression)
* S9:
Expression -> Lvalue MinusAssignOp . Expression
 <Expression> => S13; leo(Expression)
* S10:
Expression -> Lvalue MultiplyAssignOp . Expression
 <Expression> => S14; leo(Expression)
* S11: leo-c
Expression -> Lvalue AssignOp Expression .
* S12: leo-c
Expression -> Lvalue AddAssignOp Expression .
* S13: leo-c
Expression -> Lvalue MinusAssignOp Expression .
* S14: leo-c
Expression -> Lvalue MultiplyAssignOp Expression .
END_AHFA

my $show_earley_sets_output_before = $recce->show_earley_sets();

Marpa::XS::Test::is( $show_earley_sets_output_before,
    <<'END_EARLEY_SETS', 'Leo Example Earley Sets "Before"' );
Last Completed: 9; Furthest: 9
Earley Set 0
S0@0-0
S1@0-0
Earley Set 1
S2@0-1 [p=S0@0-0; c=S3@0-1]
S3@0-1 [p=S1@0-0; c=S5@0-1]
S4@0-1 [p=S1@0-0; c=S5@0-1]
S5@0-1 [p=S1@0-0; s=Variable; t=\'a']
Earley Set 2
S6@0-2 [p=S4@0-1; s=AssignOp; t=\'=']
S7@2-2
L1@2 ["Expression"; S6@0-2]
Earley Set 3
S2@0-3 [p=S0@0-0; c=S3@0-3]
S3@0-3 [p=S1@0-0; c=S11@0-3]
S11@0-3 [l=L1@2; c=S5@2-3]
S4@2-3 [p=S7@2-2; c=S5@2-3]
S5@2-3 [p=S7@2-2; s=Variable; t=\'b']
Earley Set 4
S8@2-4 [p=S4@2-3; s=AddAssignOp; t=\'+=']
S7@4-4
L1@4 ["Expression"; L1@2; S8@2-4]
Earley Set 5
S2@0-5 [p=S0@0-0; c=S3@0-5]
S3@0-5 [p=S1@0-0; c=S11@0-5]
S11@0-5 [l=L1@4; c=S5@4-5]
S4@4-5 [p=S7@4-4; c=S5@4-5]
S5@4-5 [p=S7@4-4; s=Variable; t=\'c']
Earley Set 6
S9@4-6 [p=S4@4-5; s=MinusAssignOp; t=\'-=']
S7@6-6
L1@6 ["Expression"; L1@4; S9@4-6]
Earley Set 7
S2@0-7 [p=S0@0-0; c=S3@0-7]
S3@0-7 [p=S1@0-0; c=S11@0-7]
S11@0-7 [l=L1@6; c=S5@6-7]
S4@6-7 [p=S7@6-6; c=S5@6-7]
S5@6-7 [p=S7@6-6; s=Variable; t=\'d']
Earley Set 8
S10@6-8 [p=S4@6-7; s=MultiplyAssignOp; t=\'*=']
S7@8-8
L1@8 ["Expression"; L1@6; S10@6-8]
Earley Set 9
S2@0-9 [p=S0@0-0; c=S3@0-9]
S3@0-9 [p=S1@0-0; c=S11@0-9]
S11@0-9 [l=L1@8; c=S5@8-9]
S4@8-9 [p=S7@8-8; c=S5@8-9]
S5@8-9 [p=S7@8-8; s=Variable; t=\'e']
END_EARLEY_SETS

my $trace_output;
open my $trace_fh, q{>}, \$trace_output;
my $value_ref = $recce->value( { trace_fh => $trace_fh, trace_values => 1 } );
close $trace_fh;

my $value = ref $value_ref ? ${$value_ref} : 'No Parse';
Marpa::XS::Test::is( $value, 'a=42 b=42 c=-5 d=6 e=3', 'Leo Example Value' );

my $show_earley_sets_output_after = $recce->show_earley_sets();

SKIP: {
    Test::More::skip 'Not relevant to XS', 1 if defined $Marpa::XS::VERSION;
    Marpa::XS::Test::is( $show_earley_sets_output_after,
        <<'END_EARLEY_SETS', 'Leo Example Earley Sets "After"' );
Last Completed: 9; Furthest: 9
Earley Set 0
S0@0-0
S1@0-0
Earley Set 1
S2@0-1 [p=S0@0-0; c=S3@0-1]
S3@0-1 [p=S1@0-0; c=S5@0-1]
S4@0-1 [p=S1@0-0; c=S5@0-1]
S5@0-1 [p=S1@0-0; s=Variable; t=\'a']
Earley Set 2
S6@0-2 [p=S4@0-1; s=AssignOp; t=\'=']
S7@2-2
L1@2 ["Expression"; S6@0-2]
Earley Set 3
S2@0-3 [p=S0@0-0; c=S3@0-3]
S3@0-3 [p=S1@0-0; c=S11@0-3]
S11@0-3 [l=L1@2; c=S5@2-3]
S4@2-3 [p=S7@2-2; c=S5@2-3]
S5@2-3 [p=S7@2-2; s=Variable; t=\'b']
Earley Set 4
S8@2-4 [p=S4@2-3; s=AddAssignOp; t=\'+=']
S7@4-4
L1@4 ["Expression"; L1@2; S8@2-4]
Earley Set 5
S2@0-5 [p=S0@0-0; c=S3@0-5]
S3@0-5 [p=S1@0-0; c=S11@0-5]
S11@0-5 [l=L1@4; c=S5@4-5]
S4@4-5 [p=S7@4-4; c=S5@4-5]
S5@4-5 [p=S7@4-4; s=Variable; t=\'c']
Earley Set 6
S9@4-6 [p=S4@4-5; s=MinusAssignOp; t=\'-=']
S7@6-6
L1@6 ["Expression"; L1@4; S9@4-6]
Earley Set 7
S2@0-7 [p=S0@0-0; c=S3@0-7]
S3@0-7 [p=S1@0-0; c=S11@0-7]
S11@0-7 [l=L1@6; c=S5@6-7]
S4@6-7 [p=S7@6-6; c=S5@6-7]
S5@6-7 [p=S7@6-6; s=Variable; t=\'d']
Earley Set 8
S10@6-8 [p=S4@6-7; s=MultiplyAssignOp; t=\'*=']
S7@8-8
L1@8 ["Expression"; L1@6; S10@6-8]
Earley Set 9
S2@0-9 [p=S0@0-0; c=S3@0-9]
S3@0-9 [p=S1@0-0; c=S11@0-9]
S11@0-9 [p=S6@0-2; c=S12@2-9] [l=L1@8; c=S5@8-9]
S12@2-9 [p=S8@2-4; c=S13@4-9]
S13@4-9 [p=S9@4-6; c=S14@6-9]
S14@6-9 [p=S10@6-8; c=S5@8-9]
S4@8-9 [p=S7@8-8; c=S5@8-9]
S5@8-9 [p=S7@8-8; s=Variable; t=\'e']
END_EARLEY_SETS
} ## end SKIP:

my $expected_trace_output = <<'END_TRACE_OUTPUT';
Setting trace_values option
Pushed value from R6:1@0-1S7@0: Variable = \'a'
Popping 1 values to evaluate R6:1@0-1S7@0, rule: 6: Lvalue -> Variable
Calculated and pushed value: 'a'
Pushed value from R1:2@0-2S3@1: AssignOp = \'='
Pushed value from R6:1@2-3S7@2: Variable = \'b'
Popping 1 values to evaluate R6:1@2-3S7@2, rule: 6: Lvalue -> Variable
Calculated and pushed value: 'b'
Pushed value from R2:2@2-4S4@3: AddAssignOp = \'+='
Pushed value from R6:1@4-5S7@4: Variable = \'c'
Popping 1 values to evaluate R6:1@4-5S7@4, rule: 6: Lvalue -> Variable
Calculated and pushed value: 'c'
Pushed value from R3:2@4-6S5@5: MinusAssignOp = \'-='
Pushed value from R6:1@6-7S7@6: Variable = \'d'
Popping 1 values to evaluate R6:1@6-7S7@6, rule: 6: Lvalue -> Variable
Calculated and pushed value: 'd'
Pushed value from R4:2@6-8S6@7: MultiplyAssignOp = \'*='
Pushed value from R5:1@8-9S7@8: Variable = \'e'
Popping 1 values to evaluate R5:1@8-9S7@8, rule: 5: Expression -> Variable
Calculated and pushed value: 3
Popping 3 values to evaluate R4:3@6-9C5@8, rule: 4: Expression -> Lvalue MultiplyAssignOp Expression
Calculated and pushed value: 6
Popping 3 values to evaluate R3:3@4-9C4@6, rule: 3: Expression -> Lvalue MinusAssignOp Expression
Calculated and pushed value: -5
Popping 3 values to evaluate R2:3@2-9C3@4, rule: 2: Expression -> Lvalue AddAssignOp Expression
Calculated and pushed value: 42
Popping 3 values to evaluate R1:3@0-9C2@2, rule: 1: Expression -> Lvalue AssignOp Expression
Calculated and pushed value: 42
Popping 1 values to evaluate R0:1@0-9C1@0, rule: 0: Statement -> Expression
Calculated and pushed value: 'a=42 b=42 c=-5 d=6 e=3'
New Virtual Rule: R7:1@0-9C0@0, rule: 7: Statement['] -> Statement
Real symbol count is 1
END_TRACE_OUTPUT

Marpa::XS::Test::is( $trace_output, $expected_trace_output,
    'Leo Example Trace Output' );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
