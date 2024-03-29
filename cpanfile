requires 'Catalyst::Runtime' => '5.90082';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'DBIx::Class::InflateColumn::DateTime';
requires 'DateTime::Format::Pg';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::Factory::PerRequest';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Cache';
requires 'Cache::Memcached';
requires 'Catalyst::Action::RenderView';
requires 'Data::Dumper::Concise';
requires 'parent';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Test::More';
requires 'YAML::XS';

requires 'Module::Find';
requires 'Exception::Simple' => '1.000001';
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
requires 'JSON::MaybeXS';
requires 'Cpanel::JSON::XS';
requires 'Catalyst::View::JSON';
requires 'File::Path';
requires 'Data::Validate::URI';
requires 'Data::Validate::Image';
requires 'Digest::SHA';
requires 'File::Temp';
requires 'Storable';
requires 'File::Copy';
requires 'File::Basename';
requires 'JavaScript::Minifier::XS';
requires 'CSS::Minifier::XS';
requires 'Data::Page';
requires 'Data::Page::Navigation';
requires 'Lingua::Stem::Snowball';
requires 'utf8';
requires 'DateTime';
requires 'DateTime::Format::Human::Duration';
requires 'Captcha::reCAPTCHA' => '0.99';
requires 'HTML::Video::Embed' => '0.01600';
requires 'Fetch::Image';
requires 'HTML::FormatText';
requires 'URI';
requires 'URI::Escape::XS';
requires 'Catalyst::View::TT';
requires 'HTML::StripScripts::Parser';
requires 'Parse::BBCode';
requires 'HTML::TreeBuilder';
requires 'URI::Find';
requires 'Tie::Hash::Sorted';
requires 'Cwd';
requires 'DBD::Pg';
requires 'Gazelle';
requires 'Catalyst::Model::Factory';
requires 'Mail::Builder::Simple';
requires 'Math::Random::Secure';
requires 'Crypt::PBKDF2';
requires 'MooseX::MethodAttributes';
requires 'Config::JFDI';

#workers
requires 'Gearman::Worker';
requires 'Storable';
requires 'Config::Any';
requires 'Log::Log4perl';

#search
requires 'LucyX::Simple';

#sitemap pinger
requires 'LWP::Simple';
requires 'CGI';

#twitter
requires 'WebService::Bitly';
requires 'Net::Twitter';
requires 'LWPx::ParanoidAgent';

#Catalyst::Plugin::Event
requires 'Text::SimpleTable';

#scripts
requires 'Term::ProgressBar';

requires 'MooseX::MarkAsMethods';
requires 'MooseX::NonMoose';

requires 'DBIx::Class::Schema::Loader';
requires 'DBIx::Class::TimeStamp';

requires 'Alien::ImageMagick';

requires 'Config::ZOMG';
requires 'Net::SSLeay' => '1.88';
requires 'HTML::StripScripts' => '1.06';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Test::Fatal';
test_requires 'Catalyst::Test';
