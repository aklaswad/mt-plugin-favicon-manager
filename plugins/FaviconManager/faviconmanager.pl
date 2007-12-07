package MT::Plugin::FaviconManager;

use strict;
use MT;
use vars qw($VERSION);
$VERSION = '2.0';

@MT::Plugin::FaviconManager::ISA = qw(MT::Plugin);

my $plugin = new MT::Plugin::FaviconManager({
    name        => 'FaviconManager',
    version     => $VERSION,
    description => '<__trans phrase=\'_PLUGIN_DESCRIPTION\'>',
    author_name => '<__trans phrase=\'_PLUGIN_AUTHOR\'>',
    author_link => 'http://blog.aklaswad.com/',
    settings    => new MT::PluginSettings([
        ['faviconmanager_cms_icon', { Scope => 'system'}],
        ['faviconmanager_blog_icon'],
    ]),
    doc_link    => 'http://blog.aklaswad.com/mtplugins/faviconmanager.html',
    l10n_class  => 'FaviconManager::L10N',
    system_config_template => 'config.tmpl',
    blog_config_template   => 'blogconfig.tmpl',
});

MT->add_plugin($plugin);
MT->add_callback('MT::App::CMS::template_source.header', 9, $plugin, \&_add_cmsfavicon);
MT->add_callback('MT::App::Search::template_source.header', 9, $plugin, \&_add_cmsfavicon);
MT->add_callback('build_page', 9, $plugin, \&_add_blog_favicon);

sub get_favicon_url {
    my $plugin = shift;
    my $blog_id = shift;
    my ($setting_str, $favicon_url);

    if ($blog_id) {
        my $config =  $plugin->get_config_hash('blog:' . $blog_id);
        $setting_str = $config->{faviconmanager_blog_icon};
    }
    else {
        my $config =  $plugin->get_config_hash('system');
        $setting_str = $config->{faviconmanager_cms_icon};
    }
    return unless $setting_str;

    if ($setting_str =~ /^asset:/) {
        $setting_str =~ s/asset://;
        my $asset_id = $setting_str;
        require MT::Asset;
        my $asset = MT::Asset->load($asset_id);
        die "Favicon Manager failed: can't load asset object." unless $asset;
        $favicon_url = $asset->url;
    }
    else {
        $favicon_url = $setting_str;
    }

    return $favicon_url;
}

sub _add_cmsfavicon {
    my ($eh, $app, $tmpl_ref) = @_;
    my $url = $plugin->get_favicon_url
        or return;
    my $add = <<"EOT";
<mt:setvarblock name="html_head" prepend="1">
    <link rel="shortcut icon" href="$url" />
</mt:setvarblock>
EOT
    $$tmpl_ref = $add . $$tmpl_ref;
}

sub _add_blog_favicon {
    my ($eh, %param) = @_;
    my $file = $param{'File'};
    return if $file !~ /html?$/;
    my $blog = $param{'Blog'};
    my $favicon_url = $plugin->get_favicon_url($blog->id)
        or return;
    my $add = "<link rel=\"shortcut icon\" href=\"$favicon_url\" />\n    <link";
    my $html = $param{'Content'};
    $$html =~ s{<link}{$add};
}

1;

