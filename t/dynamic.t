use 5.010;
use strict;
use warnings;

use Test::More tests => 13;
use Digest::MD5 qw(md5_hex);

my %MD5_FOR = (
    'background.gif' => '01d4003e8bf0191d38ff170f613e47f0',
    'script.js'      => '61d05c6e57b5cc82b8a316a19b332656',
    'style.css'      => '0d56d9a3743ab94e11a7de17101029f6',
);

BEGIN { use_ok('HTTP::CDN') };

HTTP::CDN->dynamic_manifest('dynamic', 't/data/', { base => 'cdn/' });

foreach my $file ( sort keys %MD5_FOR ) {
    my $expected = $file;
    my $hash = uc(substr($MD5_FOR{$file}, 0, 12));
    $expected =~ s/(.*)\.(.*)/"$1.$hash.$2"/e;
    is(HTTP::CDN::dynamic->uri($file), "cdn/$expected", "Generates correct URI for $file");
}
is(md5_hex(HTTP::CDN::dynamic->content('style.css')), $MD5_FOR{'style.css'});
is(md5_hex(HTTP::CDN::dynamic->content('script.js')), $MD5_FOR{'script.js'});
is(md5_hex(HTTP::CDN::dynamic->content('background.gif')), $MD5_FOR{'background.gif'});
my $info = HTTP::CDN::dynamic->info('style.css');
is($info->{hash}, uc substr($MD5_FOR{'style.css'},0,12));
is($info->{extension}, 'css');
is($info->{mime}, 'text/css');

HTTP::CDN->dynamic_manifest('baredynamic', 't/data/');

# For the bare dynamic the MD5 of the stylesheet changes (due to the root path
# being different)
$MD5_FOR{'style.css'} = '0769aeca574c9b7f006a3f0b87bb0cfc';

foreach my $file ( sort keys %MD5_FOR ) {
    my $expected = $file;
    my $hash = uc(substr($MD5_FOR{$file}, 0, 12));
    $expected =~ s/(.*)\.(.*)/"$1.$hash.$2"/e;
    is(HTTP::CDN::baredynamic->uri($file), "$expected");
}
