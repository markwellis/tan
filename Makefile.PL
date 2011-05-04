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
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::Cache';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Engine::Apache';
requires 'Data::Dumper';
requires 'parent';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Config::JSON'; # This should reflect the config file format you've chosen, See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Module::Find';
requires 'Exception::Simple';
requires 'Try::Tiny';
requires 'Tie::Hash::Indexed';
requires 'Number::Format';
requires 'XML::Feed';
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

#workers
requires 'Storable';
requires 'Config::Any';
requires 'File::Basename';
requires 'Log::Log4perl';

#search
requires 'KinoSearchX::Simple';

#sitemap pinger
requires 'LWP::Simple';
requires 'CGI';

#twitter
requires 'WebService::Bitly';
requires 'Net::Twitter';
requires 'LWPx::ParanoidAgent';

##doesnt belong in here!

#GearmanX::Simple::Worker
requires 'App::Daemon';
requires 'Gearman::Worker';

#Catalyst::Plugin::Event
requires 'Text::SimpleTable';

#Catalyst::View::Perl
requires 'Catalyst::Component::InstancePerContext';
#Catalyst::View::Perl::Core
requires 'HTML::TreeBuilder';
requires 'HTML::FormatText';
requires 'HTML::Entities';
requires 'XML::Entities';

#Catalyst::View::Perl::URL
requires 'URI';

#Fetch::Image
requires 'Data::Validate::Image';
requires 'Data::Validate::URI';

#HTML::Video::Embed
requires 'URI::QueryParam';
requires 'URI::Escape::XS';

#Parse::TAN
requires 'HTML::StripScripts::Parser';

#Parse::BBCode::TAN
requires 'Parse::BBCode';

install_script glob('script/*.pl');
auto_install;
WriteAll;
