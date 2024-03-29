*! artest 3.2.0 7 May 2021
*! Copyright (C) 2015-21 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

cap program drop artest
program define artest
	version 11

	tokenize `"`0'"', parse(",")
	if `"`1'"' != "," {
		local h0s `h0s' `1'
		macro shift
	}
	local 0 `*'
	
	syntax, [h0(passthru) BOOTCLuster(passthru) CLuster(passthru) Robust QUIetly NOCI NONULl NOGRaph SMall Ptype(passthru) gridmin(passthru) gridmax(passthru) gridpoints(passthru) graphopt(passthru) graphname(passthru) Level(passthru) PTOLerance(passthru) ar MARGins]
	boottest `h0s', `h0' reps(0) ar `bootcluster' `cluster' `robust' `quietly' `noci' `ptolerance' `nonull' `nograph' `small' `ptype' `gridmin' `gridmax' `gridpoints' `graphopt' `graphname'
end
