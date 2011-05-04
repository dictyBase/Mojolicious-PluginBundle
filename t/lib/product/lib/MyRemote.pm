package MyRemote;

use strict;

# Module implementation
#

my $APP;

sub app {
	my ($class,  $app) = @_;
	if (not defined $app) {
		return $APP if $APP;
	}
	else {
		$APP = $app;
	}
}


1;    # Magic true value required at end of module

