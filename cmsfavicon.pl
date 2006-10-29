package MT::Plugin::CMSFavicon;

use strict;
use MT;
use MT::Template::Context;
use vars qw($VERSION);
$VERSION = '0.1';

@MT::Plugin::CMSFavicon::ISA = qw(MT::Plugin);

my $plugin = new MT::Plugin::CMSFavicon({
  name => '<MT_TRANS phrase=\'_PLUGIN_NAME\'>',
  version => $VERSION,
  description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
  author_name => '<MT_TRANS phrase=\'_PLUGIN_AUTHOR\'>',
  author_link => 'http://blog.aklaswad.com/',
  settings => new MT::PluginSettings([
    ['cmsfavicon_path_to_icon'],
  ]),
  system_config_template => 'config.tmpl',
  doc_link => 'http://blog.aklaswad.com/',
  l10n_class => 'CMSFavicon::L10N',
});

MT->add_plugin($plugin);
MT->add_callback('MT::App::CMS::AppTemplateSource.header', 9, $plugin, \&_add_favicon);


sub _add_favicon {
  my ($eh, $app, $tmpl_ref) = @_;
  my $plugin_param;
  $plugin_param = $plugin->get_config_hash();
  
  my $old = <<'HTML';
<link rel="stylesheet" href="<TMPL_VAR NAME=STATIC_URI>styles.css?v=<TMPL_VAR NAME=MT_VERSION ESCAPE=URL>" type="text/css" />
HTML

  my $new = '
<link rel="shortcut icon" href="' . $plugin_param->{'cmsfavicon_path_to_icon'};

  $new .= <<'HTML';
">
<link rel="stylesheet" href="<TMPL_VAR NAME=STATIC_URI>styles.css?v=<TMPL_VAR NAME=MT_VERSION ESCAPE=URL>" type="text/css" />
HTML

  $old = quotemeta($old);
  $$tmpl_ref =~ s/$old/$new/;
}

1;

