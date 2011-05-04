package remoteproduct;

use strict;
use warnings;
use MyRemote;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    # Routes
    my $r = $self->routes;
    (my $remote_url = MyRemote->app->build_url) =~ s{/$}{};

    $self->plugin(
        'asset_tag_helpers',
        {   relative_url_root => '/tucker',
            asset_host        => $remote_url, 
            mojo_ua => MyRemote->app->ua
        }
    );
    $self->log->debug( "got running host $remote_url");

    my $product = $r->route('/product')->via('get')->to(
        namespace => 'product::Default',
        action    => 'morelist'
    );
}

1;
