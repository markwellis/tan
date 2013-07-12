package TAN::Controller::Mobile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

my @mobile_uas = (
    "midp", "j2me", "avantg", "docomo", "novarra", "palmos", "palmsource",
    "240x320", "opwv", "chtml", "pda", "windows\ ce", "mmp\/", "blackberry",
    "mib\/", "symbian", "wireless", "nokia", "hand", "mobi", "phone", "cdm",
    "up\.b", "audio", "SIE\-", "SEC\-", "samsung", "HTC", "mot\-", "mitsu",
    "sagem","sony", "alcatel", "lg", "erics", "vx", "NEC", "philips", "mmm",
    "xx", "panasonic", "sharp", "wap", "sch", "rover", "pocket", "benq", "java",
    "pt", "pg", "vox", "amoi", "bird", "compal", "kg", "voda", "sany", "kdd",
    "dbt", "sendo", "sgh", "gradi", "jb", "\\d\\d\\di", "moto"
);
my @patterns = map {qr/$_/i} @mobile_uas;
my $r2 = qr/(iPad|MSIE(?!.*(IEMobile|Windows\ CE|symbian|smartphone)\b))/i;

sub detect_mobile: Private{
    my( $self, $c ) = @_;
    my $ua = $c->req->user_agent;
    
    #return if this has already ran
    return if ( defined( $c->stash->{'mobile_switch'} ) );

    #set this so set_mobile doesn't redirect us anywhere
    $c->stash->{'mobile_return'} = 1;

    if ( defined($ua) ) {
        foreach my $pattern (@patterns) {
            if ($ua =~ /$pattern/) {
                $c->forward('set_mobile', [1]);
                return;
            }
        }
    }

    $c->forward('set_mobile', [0]);
    return;
}

sub set_mobile: Local{
    my( $self, $c, $value) = @_;

    #if we have a value, set the cookie to this value
    #else force mobile cookie
    $value //= 1;
    $c->res->cookies->{'mobile'} = {
        'value' => $value,
        'expires' => '+10y',
    };
    $c->stash->{'mobile_switch'} = $value;

    # if we're called from detect_mobile return here
    if ( defined($c->stash->{'mobile_return'}) ){
        # if you come direct to this sub with no cookies
        # then mobile_return is still in the stash from the detection (ran in auto)
        # and you end up on this page with a no template found error
        # lets unset this here
        $c->stash->{'mobile_return'} = undef;
        return;
    }

    my $redirect_to = $c->req->referer || '/';
    $c->res->redirect($redirect_to);
    $c->detach();
}

__PACKAGE__->meta->make_immutable;
