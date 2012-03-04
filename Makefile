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

.PHONY: dummy xs_test html_test full_test install

dummy: 

xs_test:
	cd xs;perl Build.PL
	cd xs;./Build realclean
	cd xs;perl Build.PL
	cd xs;./Build
	cd xs;./Build distmeta
	cd xs;./Build test
	cd xs;./Build distcheck
	cd xs;./Build dist

full_test: xs_test html_test

html_test:
	-test -d stage && rm -rf stage
	mkdir stage
	cpanm -v --reinstall -l stage ./xs/
	PERL5LIB=$(CURDIR)/nopp/lib:$(CURDIR)/stage:$$PERL5LIB \
	    cpanm -v --reinstall -l stage Marpa::HTML

install:
	(cd xs/libmarpa/dev && make)
	(cd xs/libmarpa/dev && make install)
	-mkdir xs/libmarpa/dist/m4
	(cd xs/libmarpa/dist && autoreconf -ivf)
	-mkdir xs/libmarpa/test/dev/m4
	(cd xs/libmarpa/test/dev && autoreconf -ivf)
	(cd xs && perl Build.PL)
	(cd xs && ./Build code)
	-mkdir xs/libmarpa/test/work
	(cd xs/libmarpa/test/work && sh ../dev/configure)
	(cd xs/libmarpa/test/work && make)
