package MT::Plugin::FaviconManager;

use strict;
use MT;
use vars qw($VERSION);
$VERSION = '0.2';

@MT::Plugin::FaviconManager::ISA = qw(MT::Plugin);

my $plugin = new MT::Plugin::FaviconManager({
  name => '<MT_TRANS phrase=\'_PLUGIN_NAME\'>',
  version => $VERSION,
  description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
  author_name => '<MT_TRANS phrase=\'_PLUGIN_AUTHOR\'>',
  author_link => 'http://blog.aklaswad.com/',
  settings => new MT::PluginSettings([
    ['faviconmanager_cms_icon', { Scope => 'system'}],
    ['faviconmanager_blog_icon'],
  ]),
  system_config_template => 'config.tmpl',
  blog_config_template => 'blogconfig.tmpl',
  doc_link => 'http://blog.aklaswad.com/',
  l10n_class => 'FaviconManager::L10N',
});

MT->add_plugin($plugin);
MT->add_callback('MT::App::CMS::template_source.header', 9, $plugin, \&_add_cmsfavicon);
MT->add_callback('build_page', 9, $plugin, \&_add_favicon);

sub get_favicon_url {
    my $plugin = shift;
    my $blog_id = shift;
    my $url = '';
    if ($blog_id) {
        my $config =  $plugin->get_config_hash('blog:' . $blog_id);
        $url = $config->{faviconmanager_blog_icon};
    }
    unless ($url) {
        my $config =  $plugin->get_config_hash('system');
        $url = $config->{faviconmanager_cms_icon};
    }

#    my $nonurlchar = '[^A-Za-z0-9\-\_\.\/\~\,\$\!\*\'\(\)\;\:\@\=\&\+]';
#    die "out of URL characters in Favicon URL" if $url =~ /$nonurlchar/;
    return $url;
}

sub _add_cmsfavicon {
    my ($eh, $app, $tmpl_ref) = @_;
    my $url = $plugin->get_favicon_url;
    my $add = <<"EOT";
<mt:setvarblock name="html_head" prepend="1">
    <link rel="shortcut icon" href="$url" />
</mt:setvarblock>
EOT
    $$tmpl_ref = $add . $$tmpl_ref;
}

sub _add_favicon {
    my ($eh, %param) = @_;
    my $tmpl = $param{'Template'};
    die "no tmpl" unless defined $tmpl;
    my $blog = $param{'Blog'};
    my $url = $plugin->get_favicon_url($blog->id);
    die "no url" unless $url;
    my $add = "<link rel=\"shortcut icon\" href=\"$url\" />\n    <link";
    my $file = $param{'File'};
    if ($file =~ /html$/) {
        my $html = $param{'Content'};
        $$html =~ s{<link}{$add};
    }
}


1;

