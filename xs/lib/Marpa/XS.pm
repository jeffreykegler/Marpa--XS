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

package Marpa::XS;

use 5.010;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION @ISA $DEBUG);
$VERSION        = '0.019_004';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic
$DEBUG = 0;

use Carp;
use English qw( -no_match_vars );

use Marpa::XS::Version;

# Die if more than one of the Marpa modules is loaded
if ( defined $Marpa::XS::MODULE ) {
    Carp::croak( "You can only load one of the Marpa modules at a time\n",
        'The module ', $Marpa::XS::MODULE, " is already loaded\n" );
}
$Marpa::XS::MODULE = 'Marpa::XS';
if ( defined $Marpa::PP::VERSION ) {
    Carp::croak( 'Attempt to load Marpa::XS when Marpa::PP ',
        $Marpa::PP::VERSION, ' already loaded' );
}
if ($Marpa::XS::USING_PP) {
    Carp::croak('Attempt to load Marpa::XS when already using Marpa::PP');
}
if ($Marpa::XS::USING_XS) {
    die 'Internal error: Attempt to load Marpa::XS twice';
}
if ($Marpa::XS::USE_PP) {
    Carp::croak('Attempt to load Marpa::XS when USE_PP specified');
}

$Marpa::XS::USING_XS = 1;
$Marpa::XS::USING_PP = 0;

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

1;
