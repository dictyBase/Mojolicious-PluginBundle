package remoteproduct;

use strict;
use warnings;
use MyRemote;
use Mojo::Base 'Mojolicious';


has 'remote_url';

# This method will run once at server start
sub startup {
    my $self = shift;
    my $remote_url = MyRemote->remote_url;
    $remote_url =~ s{/$}{};

    # Routes
    my $r = $self->routes;
    $self->plugin(
        'asset_tag_helpers',
        {   relative_url_root => '/tucker',
            asset_host        => $remote_url, 
            mojo_ua => $self->ua
        }
    );
    $self->log->debug( "got running host $remote_url");

    my $product = $r->route('/product')->via('get')->to(
        namespace => 'product::Default',
        action    => 'morelist'
    );
}


1;

