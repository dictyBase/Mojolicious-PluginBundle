package product;

use strict;
use warnings;

use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;
    $self->plugin('asset_tag_helpers');

    # Routes
    my $r = $self->routes;
    $r->route('/product')->to('default#list');
    $r->route('/product/:type')->to('default#type');
    $r->route('/product/:type/:id')->to('default#show');

}

1;
