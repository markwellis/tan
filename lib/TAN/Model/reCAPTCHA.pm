package TAN::Model::reCAPTCHA;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Captcha::reCAPTCHA' );

__PACKAGE__->meta->make_immutable;
