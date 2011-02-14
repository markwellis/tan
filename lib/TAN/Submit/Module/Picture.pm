package TAN::Submit::Module::Picture;
use Moose;
use namespace::autoclean;
use Try::Tiny;

with 'TAN::Submit::Module';

use Fetch::Image;
use Data::Validate::Image;
use Digest::SHA;
use File::Path qw/mkpath/;
use File::Temp;

has '_fetcher' => (
    'is' => 'ro',
    'isa' => 'Fetch::Image',
    'lazy_build' => 1,
);

sub _build__fetcher {
    return new Fetch::Image({
        "max_filesize" => 3145728,
        "user_agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.16) Gecko/2009120208 Firefox/3.0.16 (.NET CLR 3.5.30729)",
    });
}

has '_validator' => (
    'is' => 'ro',
    'isa' => 'Data::Validate::Image',
    'lazy_build' => 1,
); 

sub _build__validator {
    return new Data::Validate::Image;
}

sub _build_config{
    my ( $self ) = @_;

    tie my %schema, 'Tie::Hash::Indexed';
    %schema = (
        'title' => {
            'length' => {
                'min' => 3,
                'max' => 255,
            },
            'type' => 'text',
            'required' => 1,
        },
        'upload' => {
            'type' => 'file',
            'validate' => [
                sub {
                    my ( $c, $filename ) = @_;
                    
                    return if ( $c->stash->{'edit'} );

                    my $image_info = $self->_validator->validate( $c->req->upload('upload')->tempname )
                        || Exception::Simple->throw("upload invalid filetype");

                    my $temp_file = File::Temp->new();
                    $temp_file->print( $c->req->upload('upload')->slurp );
                    $temp_file->close;

                    $image_info->{'temp_file'} = $temp_file;
                    return $image_info;
                },
            ],
            'required_or' => 'remote',
            'no_edit' => 1,
        },
        'remote' => {
            'type' => 'text',
            'validate' => [
                sub { 
                    my ( $c, $url ) = @_;

                    return if ( $c->stash->{'edit'} );

                    return try{
                        return $self->_fetcher->fetch( $url )
                    } catch {
                        chomp;
                        Exception::Simple->throw( $_ );
                    };
                },

            ],
            'required_or' => 'upload',
            'no_edit' => 1,
        },
        'description' => {
            'length' => {
                'max' => 1000
            },
            'type' => 'textarea',
        },
        'tags' => {
            'type' => 'tags',
            'required' => 1,
        },
    );

    return {
        'schema' => \%schema,
        'menu' => {
            'position' => 30,
        },
    };
}

sub prepare{
    my ( $self, $c, $params, $validator_return_values ) = @_;


    my $return = {
        'title' => $params->{'title'},
        'description' => $params->{'description'},
        'tags' => $params->{'tags'},
    };

    if ( !$c->stash->{'edit'} ){
        my $image_info = $validator_return_values->[0];

        open(INFILE, $image_info->{'temp_file'}->filename);
        my $sha = new Digest::SHA(512);
        $sha->addfile(*INFILE);

        my $sha512sum = $sha->hexdigest();

        close(INFILE);

#we do this here coz we need the result from the validator
        my $pic_rs = $c->model('MySQL::Picture')->find({
            'sha512sum' => $sha512sum,
        });

        if ( $pic_rs ){
            Exception::Simple->throw(
                'error' => 'repost',
                'url' => $pic_rs->object->url
            );
        }

        if ( !$image_info->{'animated'} ){
            `convert -auto-orient -strip '@{[ $image_info->{'temp_file'}->filename ]}' '@{[ $image_info->{'temp_file'}->filename ]}'`;
        }

        my $url_title = $params->{'title'};
        my $not_alpha_numeric_reg = $c->model('CommonRegex')->not_alpha_numeric;

        $url_title =~ s/$not_alpha_numeric_reg/-/g;

        my $time = time;

        #put images in a folder per week
        my $mod = ( $time - ($time % 604800) );

        my $path = $c->path_to('root') . $c->config->{'pic_path'} . "/${mod}";
        mkpath($path);
        my $filename = "${path}/${time}_${url_title}.@{[ $image_info->{'file_ext'} ]}";

        my $filecopy = File::Copy::copy( $image_info->{'temp_file'}->filename, $filename );
        $image_info->{'temp_file'}->DESTROY;
        delete( $image_info->{'temp_file'} );

        if ( !( -e $filename ) ){
        #shits all fucked up
            Exception::Simple->throw('upload failed');
        }

        my @path = split('/', $filename);
       
        $return = {
            %{$return},
            'x' => $image_info->{'width'},
            'y' => $image_info->{'height'},
            'size' => $image_info->{'size'},
            'sha512sum' => $sha512sum,
            'filename' => $path[-2] . '/' . $path[-1],
        };
    }

    return $return;
}

__PACKAGE__->meta->make_immutable;
