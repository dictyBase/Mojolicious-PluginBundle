package superasset;

use strict;
use warnings;
use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    # Routes
    my $r = $self->routes;
    $r->route('/tucker/:asset/(*name)')->to(
        cb => sub {
            my $self = shift;
            $self->app->log->debug( "got reqeust for "
                    . $self->stash('asset') . " and "
                    . $self->stash('name') );
            $self->render_static(
                $self->stash('asset') . '/' . $self->stash('name') );
        }
    );
}

1;
