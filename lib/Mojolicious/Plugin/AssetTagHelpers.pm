package Mojolicious::Plugin::AssetTagHelpers;

# Other modules:
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream;
use Regexp::Common qw/URI/;
use Mojo::UserAgent;
use HTTP::Date;
use File::stat;
use File::Spec::Functions;
use File::Basename;
use Scalar::Util qw/reftype/;

# Module implementation
#

has 'app';
has 'asset_dir';
has 'asset_host';
has 'relative_url_root';
has 'host_with_sub';
has 'true'           => 1;
has 'javascript_dir' => '/javascripts';
has 'stylesheet_dir' => '/stylesheets';
has 'image_dir'      => '/images';
has 'javascript_ext' => '.js';
has 'stylesheet_ext' => '.css';
has 'image_options'  => sub { [qw/width height class id border/] };
has 'ua'             => sub { Mojo::UserAgent->new };

sub register {
    my ( $self, $app, $conf ) = @_;
    $self->asset_dir( $app->static->root );
    $self->app($app);
    if ( my $url = $self->compute_relative_url( @_[ 1, -1 ] ) ) {
        $self->relative_url_root($url);
        $app->log->debug("relative url root: $url");

        # -- in case mojo app itself have to serve it from public
        $app->static->root($url);
    }
    if ( my $host = $self->compute_asset_host( @_[ 1, -1 ] ) ) {
        $self->asset_host($host);
    }

    # -- image tag
    $app->helper(
        image_tag => sub {
            my ( $c, $name, %options ) = @_;
            my $tags;
            if (%options) {
                if ( defined $options{size} ) {
                    $tags
                        = qq/height="$options{size}" width="$options{size}"/;
                }
                if ( defined $options{alt} ) {
                    $tags .= qq/alt="$options{alt}"/;
                }
                for my $opt_name ( @{ $self->image_options } ) {
                    $tags .= qq/ $opt_name="$options{$opt_name}"/
                        if defined $options{$opt_name};
                }
            }
            else {
                my $alt_name = $self->compute_alt_name($name);
                $tags .= qq/alt="$alt_name"/;
            }

            my $source = $self->compute_asset_path( $name, $self->image_dir );
            return Mojo::ByteStream->new(qq{<img src="$source" $tags/>});
        }
    );

    # -- javascript tag
    $app->helper(
        javascript_include_tag => sub {
            my ( $c, $name ) = @_;
            my $source = $self->compute_javascript_path($name);
            return Mojo::ByteStream->new(
                qq{<script src="$source" type="text/javascript"></script>});
        }
    );

    # -- stylesheet tag
    $app->helper(
        stylesheet_link_tag => sub {
            my ( $c, $name, %option ) = @_;
            my $source = $self->compute_stylesheet_path($name);
            my $media
                = $option{media}
                ? qq{media="$option{media}}
                : qq{media="screen"};

            return Mojo::ByteStream->new(
                qq{<link href="$source" $media rel="stylesheet" type="text/css" />}
            );
        }
    );

    $app->helper(
        'stylesheet_path' => sub {
            my ( $c, $path ) = @_;
            return Mojo::ByteStream->new(
                $self->compute_stylesheet_path( $path, $self->true ) );
        }
    );

    $app->helper(
        'javascript_path' => sub {
            my ( $c, $path ) = @_;
            return Mojo::ByteStream->new(
                $self->compute_javascript_path( $path, $self->true ) );
        }
    );

    $app->helper(
        'image_path' => sub {
            my ( $c, $path ) = @_;
            return Mojo::ByteStream->new( $self->compute_asset_path($path) );
        }
    );
}

sub compute_javascript_path {
    my ( $self, $name, $true ) = @_;
    $name = $name . $self->javascript_ext if $name !~ /\.js$/;
    return $true
        ? $self->compute_asset_path($name)
        : $self->compute_asset_path( $name, $self->javascript_dir );
}

sub compute_stylesheet_path {
    my ( $self, $name, $true ) = @_;
    $name = $name . $self->stylesheet_ext if $name !~ /\.css$/;
    return $true
        ? $self->compute_asset_path($name)
        : $self->compute_asset_path( $name, $self->stylesheet_dir );
}

sub compute_relative_url {
    my ( $self, $app, $conf ) = @_;
    my $url;
    if ( $app->can('config')
        and defined $app->config->{relative_url_root} )
    {
        $url = $app->config->{relative_url_root};
    }

    if ( defined $conf and defined $conf->{relative_url_root} ) {
        $url = $conf->{relative_url_root};
    }
    $url;
}

sub compute_asset_host {
    my ( $self, $app, $conf ) = @_;
    my $host;
    if ( $app->can('config')
        and defined $app->config->{asset_host} )
    {
        $host = $app->config->{asset_host};
    }

    if ( defined $conf and defined $conf->{asset_host} ) {
        $host = $conf->{asset_host};
        $self->host_with_sub(1) if reftype $host eq 'CODE';
    }
    $host;
}

sub compute_alt_name {
    my ( $self, $name ) = @_;
    my $img_regexp = qr/^([^.]+)\.(jpg|png|gif)$/;
    if ( $name =~ $RE{URI}{HTTP} ) {
        my $img_name = basename $name;
        return ucfirst $1 if $img_name =~ $img_regexp;
        return ucfirst $img_name;
    }

    return ucfirst $1 if $name =~ $img_regexp;
    return ucfirst $name;
}

sub compute_asset_id {
    my ( $self, $file ) = @_;
    if ( $file =~ $RE{URI}{HTTP} ) {
        my $tx = Mojo::UserAgent->new->head($file);
        if ( my $res = $tx->success ) {
            my $asset_id = str2time( $res->headers->last_modified );
            return $asset_id;
        }
        else {
            return;
        }
    }

    my $full_path = catfile( $self->asset_dir, $file );
    if ( -e $full_path ) {
        my $st = stat($full_path);
        return $st->mtime;
    }
}

sub remote_asset_id {
    my ( $self, $file ) = @_;
    my $tx = $self->ua->head($file);
    if ( my $res = $tx->success ) {
        my $asset_id = str2time( $res->headers->last_modified );
        return $asset_id;
    }
}

sub local_asset_id {
    my ( $self, $file ) = @_;
    my $full_path = catfile( $self->asset_dir, $file );
    if ( -e $full_path ) {
        my $st = stat($full_path);
        return $st->mtime;
    }

}

sub compute_asset_path {
    my ( $self, $file, $source_dir ) = @_;
    my ( $asset_id, $path );
    if ( $file =~ $RE{URI}{HTTP} ) {    ## -- full http url
        $asset_id = $self->remote_asset_id($file);
        return $asset_id ? $file . '?' . $asset_id : $file;
    }
    my $actual_path = $source_dir ? catfile( $source_dir, $file ) : $file;
    $path
        = $self->relative_url_root
        ? $self->relative_url_root . $actual_path
        : $actual_path;
    if ( $self->asset_host ) {
        $path     = $self->asset_host . '/' . $path;
        $asset_id = $self->remote_asset_id($path);
        return $asset_id ? $path . '?' . $asset_id : $path;
    }
    $asset_id = $self->local_asset_id($actual_path);
    return $asset_id ? $path . '?' . $asset_id : $path;
}

1;    # Magic true value required at end of module

__END__

=head1 NAME

B<Mojolicious::Plugin::AssetTagHelpers> - [Tag helpers for javascripts,images and
stylesheets]




