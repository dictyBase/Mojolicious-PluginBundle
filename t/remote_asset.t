use Test::More qw/no_plan/;
use Test::Mojo;
use File::Spec::Functions;
use Mojo::UserAgent;
use FindBin;
use lib "$FindBin::Bin/lib/product/lib";
use MyRemote;

BEGIN {
    $ENV{MOJO_LOG_LEVEL} ||= 'debug';
}

use_ok('superasset');
my $stest = Test::Mojo->new( app => 'superasset' );
$stest->head_ok('/tucker/images/bioimage.png')->status_is(200);
MyRemote->app($stest);

use_ok('remoteproduct');
my $test = Test::Mojo->new( app => 'remoteproduct' );
my $app = $test->get_ok('/product');
$app->status_is(200);
$app->content_like( qr/list of product/, 'It shows the list of product' );

my $url = $stest->build_url;
$app->element_exists(
    'html head script[src="$url.javascripts/biolib.js"]',
    'It matches javascript source via javascript_link_tag helper'
);
$app->element_exists(
    'html head script[src^="$url.javascripts/custom/jumper.js"]',
    'It starts with javascript source via javascript_path helper'
);

$app->element_exists(
    'html head link[href="/stylesheets/biostyle.css"]',
    'It has stylesheet link via stylesheet_link tag'
);
$app->element_exists(
    'html head link[href^="/stylesheets/monkey.css?"]',
    'It has stylesheet link via stylesheet_link_tag with asset id'
);
$app->element_exists(
    'html head link[href^="/stylesheets/custom/jumbo.css?"]',
    'It has stylesheet link via stylesheet_path helper'
);

$app->element_exists(
    'body img[src="/images/bioimage.png"]',
    'It has bioimage.png as image source'
);
$app->element_exists(
    'body img[src^="/images/mojolicious-black.png?"]',
    'It has mojolicious logo with asset tag'
);
$app->element_exists(
    'body img[alt="Mojolicious-black"]',
    'It has mojolicious logo with alt attribute'
);
$app->element_exists(
    'body a[id="size"] img[width="10"][height="10"]',
    'It has mojolicious logo with height attribute'
);
$app->element_exists(
    'body a[id="options"] img[width="10"][class="mojo"][id="foo"][border="1"]',
    'It has mojolicious image logo with various attributes'
);
$app->element_exists(
    'body a[id="custom"][href^="/images/custom"]',
    'It has mojolicious logo with custom href url'
);

$app->element_exists(
    'body a[id="withttp"][href^="http://images"]',
    'It has mojolicious logo with passthrough http url'
);

