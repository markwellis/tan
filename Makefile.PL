#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'TAN';
all_from 'lib/TAN.pm';

requires 'Catalyst::Runtime' => '5.80013';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Email';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Cache';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Action::RenderView';
requires 'Data::Dumper';
requires 'parent';
requires 'Config::JSON'; # This should reflect the config file format you've chosen, See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Module::Find';
requires 'Exception::Simple';
requires 'Try::Tiny';
requires 'Tie::Hash::Indexed';
requires 'Number::Format';
requires 'XML::Feed';
requires 'XML::Feed::Entry';
requires 'Time::HiRes';
requires 'Text::Wrap';
requires 'Scalar::Util';
requires 'Data::Validate::Email';
requires 'POSIX';
requires 'Gearman::Client';
requires 'JSON';
requires 'File::Path';
requires 'Data::Validate::URI';
requires 'Data::Validate::Image';
requires 'Digest::SHA';
requires 'File::Temp';
requires 'Storable';
requires 'File::Copy';
requires 'JavaScript::Minifier::XS';
requires 'CSS::Minifier::XS';
requires 'Data::Page';
requires 'utf8';
requires 'DateTime';
requires 'DateTime::Format::Human::Duration';

#catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
