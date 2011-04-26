package Mojolicious::Plugin::Bundle;

BEGIN {
    $Mojolicious::Plugin::Bundle::VERSION = '0.001';
}
use strict;

1;

=pod

=head1 NAME

Mojolicious::Plugin::Bundle - Collection of mojolicious plugins

=head1 VERSION

version 0.001

=head1 SYNOPSIS

#In mojolicious application

$self->plugin('yml_config');

$self->plugin('asset_tag_helper');

$self->plugin('modware');

$self->plugin('bcs');

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__

# ABSTRACT: Collection of mojolicious plugins
