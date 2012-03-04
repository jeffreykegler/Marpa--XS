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

package Marpa::XS;

use 5.010;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION @ISA $DEBUG);
$VERSION        = '1.005_000';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic
$DEBUG = 0;

use Carp;
use English qw( -no_match_vars );

# Die if more than one of the Marpa modules is loaded
BEGIN {
    if ( defined $Marpa::VERSION ) {
        Carp::croak( "You can only load one of the Marpa modules at a time\n",
            'Version ', $Marpa::VERSION, " of Marpa is already loaded\n" );
    }
    if ( defined $Marpa::PP::VERSION ) {
        Carp::croak( "You can only load one of the Marpa modules at a time\n",
            'Version ', $Marpa::PP::VERSION,
            " of Marpa::PP is already loaded\n" );
    }
} ## end BEGIN

use Marpa::XS::Version;

eval {
    require XSLoader;
    XSLoader::load( 'Marpa::XS', $Marpa::XS::STRING_VERSION );
    1;
} or eval {
    my @libs = split q{ }, ExtUtils::PkgConfig->libs('glib-2.0');
    @DynaLoader::dl_resolve_using = DynaLoader::dl_findfile(@libs);
    require DynaLoader;
## no critic(ClassHierarchies::ProhibitExplicitISA)
    push @ISA, 'DynaLoader';
    Dynaloader::bootstrap Marpa::XS $Marpa::XS::STRING_VERSION;
    1;
} or Carp::croak("Could not load XS version of Marpa: $EVAL_ERROR");

my $version_found = join q{.}, Marpa::XS::version();
my $version_wanted = '0.1.0';
Carp::croak( 'Marpa::XS ',
    "fails version check, wanted $version_wanted, found $version_found" )
    if $version_wanted ne $version_found;

@Marpa::XS::CARP_NOT = ();
for my $middle ( q{}, '::Internal' ) {
    for my $end ( q{}, qw(::Recognizer ::Callback ::Grammar ::Value) ) {
        push @Marpa::XS::CARP_NOT, 'Marpa::XS' . $middle . $end;
    }
}
PACKAGE: for my $package (@Marpa::XS::CARP_NOT) {
    no strict 'refs';
    next PACKAGE if $package eq 'Marpa';
    *{ $package . q{::CARP_NOT} } = \@Marpa::XS::CARP_NOT;
}

if ( not $ENV{'MARPA_AUTHOR_TEST'} ) {
    Glib::Log->set_handler( 'Marpa', 'debug', ( sub {;} ), undef );
    $Marpa::XS::DEBUG = 0;
}
else {
    $Marpa::XS::DEBUG = 1;
}

sub version_ok {
    my ($sub_module_version) = @_;
    return 'not defined' if not defined $sub_module_version;
    return "$sub_module_version does not match Marpa::XS::VERSION " . $VERSION
        if $sub_module_version != $VERSION;
    return;
} ## end sub version_ok

my $version_result;
require Marpa::XS::Internal;
( $version_result = version_ok($Marpa::XS::Internal::VERSION) )
    and die 'Marpa::XS::Internal::VERSION ', $version_result;

require Marpa::XS::Grammar;
( $version_result = version_ok($Marpa::XS::Grammar::VERSION) )
    and die 'Marpa::XS::Grammar::VERSION ', $version_result;

require Marpa::XS::Recognizer;
( $version_result = version_ok($Marpa::XS::Recognizer::VERSION) )
    and die 'Marpa::XS::Recognizer::VERSION ', $version_result;

require Marpa::XS::Value;
( $version_result = version_ok($Marpa::XS::Value::VERSION) )
    and die 'Marpa::XS::Value::VERSION ', $version_result;

$Marpa::USING_XS = 1;
$Marpa::USING_PP = undef;
$Marpa::MODULE   = 'Marpa::XS';

*Marpa::Grammar::check_terminal  = \&Marpa::XS::Grammar::check_terminal;
*Marpa::Grammar::new             = \&Marpa::XS::Grammar::new;
*Marpa::Grammar::precompute      = \&Marpa::XS::Grammar::precompute;
*Marpa::Grammar::set             = \&Marpa::XS::Grammar::set;
*Marpa::Grammar::show_AHFA       = \&Marpa::XS::Grammar::show_AHFA;
*Marpa::Grammar::show_AHFA_items = \&Marpa::XS::Grammar::show_AHFA_items;
*Marpa::Grammar::show_NFA        = \&Marpa::XS::Grammar::show_NFA;
*Marpa::Grammar::show_accessible_symbols =
    \&Marpa::XS::Grammar::show_accessible_symbols;
*Marpa::Grammar::show_dotted_rule = \&Marpa::XS::Grammar::show_dotted_rule;
*Marpa::Grammar::show_nullable_symbols =
    \&Marpa::XS::Grammar::show_nullable_symbols;
*Marpa::Grammar::show_nulling_symbols =
    \&Marpa::XS::Grammar::show_nulling_symbols;
*Marpa::Grammar::show_productive_symbols =
    \&Marpa::XS::Grammar::show_productive_symbols;
*Marpa::Grammar::show_problems     = \&Marpa::XS::Grammar::show_problems;
*Marpa::Grammar::brief_rule        = \&Marpa::XS::Grammar::brief_rule;
*Marpa::Grammar::show_rule         = \&Marpa::XS::Grammar::show_rule;
*Marpa::Grammar::show_rules        = \&Marpa::XS::Grammar::show_rules;
*Marpa::Grammar::show_symbol       = \&Marpa::XS::Grammar::show_symbol;
*Marpa::Grammar::show_symbols      = \&Marpa::XS::Grammar::show_symbols;
*Marpa::Recognizer::alternative    = \&Marpa::XS::Recognizer::alternative;
*Marpa::Recognizer::check_terminal = \&Marpa::XS::Recognizer::check_terminal;
*Marpa::Recognizer::current_earleme =
    \&Marpa::XS::Recognizer::current_earleme;
*Marpa::Recognizer::earleme_complete =
    \&Marpa::XS::Recognizer::earleme_complete;
*Marpa::Recognizer::earley_set_size =
    \&Marpa::XS::Recognizer::earley_set_size;
*Marpa::Recognizer::end_input = \&Marpa::XS::Recognizer::end_input;
*Marpa::Recognizer::exhausted = \&Marpa::XS::Recognizer::exhausted;
*Marpa::Recognizer::latest_earley_set =
    \&Marpa::XS::Recognizer::latest_earley_set;
*Marpa::Recognizer::new  = \&Marpa::XS::Recognizer::new;
*Marpa::Recognizer::read = \&Marpa::XS::Recognizer::read;
*Marpa::Recognizer::reset_evaluation =
    \&Marpa::XS::Recognizer::reset_evaluation;
*Marpa::Recognizer::set = \&Marpa::XS::Recognizer::set;
*Marpa::Recognizer::show_earley_sets =
    \&Marpa::XS::Recognizer::show_earley_sets;
*Marpa::Recognizer::show_and_nodes = \&Marpa::XS::Recognizer::show_and_nodes;
*Marpa::Recognizer::show_bocage    = \&Marpa::XS::Recognizer::show_bocage;
*Marpa::Recognizer::old_show_tree  = \&Marpa::XS::Recognizer::old_show_tree;
*Marpa::Recognizer::old_show_fork  = \&Marpa::XS::Recognizer::old_show_fork;
*Marpa::Recognizer::parse_count    = \&Marpa::XS::Recognizer::parse_count;
*Marpa::Recognizer::show_fork      = \&Marpa::XS::Recognizer::show_fork;
*Marpa::Recognizer::show_tree      = \&Marpa::XS::Recognizer::show_tree;
*Marpa::Recognizer::show_or_nodes  = \&Marpa::XS::Recognizer::show_or_nodes;
*Marpa::Recognizer::show_progress  = \&Marpa::XS::Recognizer::show_progress;
*Marpa::Recognizer::status         = \&Marpa::XS::Recognizer::status;
*Marpa::Recognizer::terminals_expected =
    \&Marpa::XS::Recognizer::terminals_expected;
*Marpa::Recognizer::tokens = \&Marpa::XS::Recognizer::tokens;
*Marpa::Recognizer::value  = \&Marpa::XS::Recognizer::value;

1;
