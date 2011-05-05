use Test::More qw/no_plan/;
use Test::Mojo;
use File::Spec::Functions;
use Mojo::UserAgent;
use FindBin;
use lib "$FindBin::Bin/lib/product/lib";
use MyRemote;

BEGIN {
    $ENV{MOJO_LOG_LEVEL} ||= 'fatal';
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
my $base = $stest->build_url;
my $url = $base->path('/tucker/javascripts/biolib.js');
$app->element_exists(
    "html head script[src=$url]",
    'It matches javascript source via javascript_link_tag helper'
);
$url = $base->path('/tucker/javascripts/custom/jumper.js');
$app->element_exists(
    "html head script[src^=$url]",
    'It starts with javascript source via javascript_path helper'
);

$url = $base->path('/tucker/stylesheets/biostyle.css');
$app->element_exists(
    "html head link[href=$url]",
    'It matches stylesheet link via stylesheet_link helper'
);
$url = $base->path('/tucker/stylesheets/custom/jumbo.css');
$app->element_exists(
    "html head link[href^=$url]",
    'It starts with stylesheet link via stylesheet_path helper'
);
$url = $base->path('/tucker/images/bioimage.png');
$app->element_exists(
    "body img[src=$url]",
    'It matches bioimage.png source via image_tag helper'
);
$app->element_exists(
    'body img[alt="Mojolicious-black"]',
    'It matches alt attribute via image_tag helper'
);
$app->element_exists(
    'body a[id="size"] img[width="10"][height="10"]',
    'It matches height and width attributes via image_tag helper'
);
$app->element_exists(
    'body a[id="options"] img[width="10"][class="mojo"][id="foo"][border="1"]',
    'It matches all image attributes via image_tag helper'
);
$url = $base->path('/tucker/images/custom');
$app->element_exists(
    "body [href^=$url]",
    'It matches custom href url via image_path helper'
);
$app->element_exists(
    'body a[id="withttp"][href^="http://images"]',
    'It matches http url via image_path helper'
);

