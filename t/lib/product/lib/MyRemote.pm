package MyRemote;

use strict;

# Module implementation
#

my $URL;

sub remote_url {
	my ($class,  $arg) = @_;
	if (not defined $arg) {
		return $URL if $URL;
	}
	else {
		$URL = $arg;
	}
}


1;    # Magic true value required at end of module

