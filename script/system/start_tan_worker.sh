#!/bin/bash
source ~/perl5/perlbrew/etc/bashrc

exec carton exec -- perl script/workers/$1/$1.pl
