package MT::Plugin::FaviconManager;

use strict;
use MT;
use vars qw($VERSION);
$VERSION = '0.1';

@MT::Plugin::FaviconManager::ISA = qw(MT::Plugin);

my $plugin = new MT::Plugin::FaviconManager({
  name => '<MT_TRANS phrase=\'_PLUGIN_NAME\'>',
  version => $VERSION,
  description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
  author_name => '<MT_TRANS phrase=\'_PLUGIN_AUTHOR\'>',
  author_link => 'http://blog.aklaswad.com/',
  settings => new MT::PluginSettings([
    ['cmsfavicon_path_to_icon', { Scope => 'system'}],
    ['favicon_path_to_icon'],
    ['add_favicon_to_new_blog', {Default => 1}],
  ]),
  callbacks => {'DefaultTemplateFilter' => \&default_template_callback},
  app_itemset_actions => {
    'MT::App::CMS' => [
      {  type => 'blog',
         key => "add_link_to_templates",
         label => 'Add favicon link to templates',
         code => \&add_link_to_template,
      }],
  },
  system_config_template => 'config.tmpl',
  blog_config_template => 'blogconfig.tmpl',
  doc_link => 'http://blog.aklaswad.com/',
  l10n_class => 'FaviconManager::L10N',
});

MT->add_plugin($plugin);
MT->add_callback('MT::App::CMS::AppTemplateSource.header', 9, $plugin, \&_add_cmsfavicon);
MT::Template::Context->add_tag(FaviconURL => \&_hdlr_favicon_url);
MT::Template::Context->add_tag(FaviconType => \&_hdlr_favicon_type);
MT::Template::Context->add_conditional_tag(HasFavicon => \&_hdrl_has_favicon);

sub add_link_to_template{
  require MT;
  require MT::Template;
  require MT::Blog;
  require MT::Permission;
  my ($app) = @_;
  my $t = time;
  my @id = $app->param('id');
  my @msg;
  my @tmpl_list = ('Main Index',
                   'Master Archive Index',
                   'Date-Based Archive',
                   'Category Archive',
                   'Individual Entry Archive',
                   );
  my $mt = new MT;
  
  foreach my $blog_id (@id) {
  my $blog = MT::Blog->load($blog_id);
    next unless $blog;
    if (!$app->{author}->is_superuser()) {
      my $perms = MT::Permission->load({ blog_id => $blog_id, author_id => $app->{author}->id });
      if (!$perms || (!$perms->can_edit_templates() && !$perms->can_administer_blog())) {
        push @msg, $app->translate("Insufficient permissions to modify templates for weblog '[_1]'", $blog->name());
        next;
      }
    }

    push @msg, $app->translate("Processing templates for weblog '[_1]'", $blog->name);

    foreach my $val (@tmpl_list) {
      
      my $terms = {};
      $terms->{blog_id} = $blog_id;
      $terms->{name} = $app->translate($val);
      my $tmpl = MT::Template->load($terms);

      if ($tmpl) {
        my $text = $tmpl->text;
        my $csslink = '<link rel="stylesheet" href="<$MTBlogURL$>styles-site.css" type="text/css" />';

        my $faviconlink = '<MTHasFavicon><link rel="shortcut icon" href="<$MTFaviconURL$>" /></MTHasFavicon>';
  
        my $qcsslink = quotemeta($csslink);
        my $qfaviconlink = quotemeta($faviconlink);
        if ($text =~ /$qcsslink/ ){
	  if(!($text =~ /$qfaviconlink/)) {
            $text =~ s/$qcsslink/$csslink\n   $faviconlink/;
            $tmpl->text($text);
            push @msg, $plugin->translate("Favicon link added at [_1].", $tmpl->name);
          } else {
            push @msg, $plugin->translate('Refreshing template [_1] aborted. favicon link already exists.', $tmpl->name);
          }
	} else {
          push @msg, $plugin->translate("Refreshing template [_1] aborted. maybe it is not default template.", $tmpl->name);
	}
        $tmpl->save;
      } else {
        push @msg, $app->translate("cant find template");
        
      }
    }
  }

  my @msg_loop;
  push @msg_loop, { message => $_ } foreach @msg;
  $app->build_page($plugin->load_tmpl('results.tmpl'), {message_loop => \@msg_loop, return_url => $app->return_uri });
}

sub default_template_callback {
  my %plugin_param;

  $plugin->load_config(\%plugin_param, 'system');
  return unless $plugin_param{add_favicon_to_new_blog};
  my ($cb, $tmpls) = @_;
  my $tmpl_list = {'Main Index' => 1,
                   'Master Archive Index' => 1,
                   'Date-Based Archive' => 1,
                   'Category Archive' => 1,
                   'Individual Entry Archive' => 1,
                   };
		   
  foreach my $tmpl (@$tmpls){
    if($tmpl_list->{$tmpl->{name}}){
      my $text = $tmpl->{text};
      my $csslink = '<link rel="stylesheet" href="<$MTBlogURL$>styles-site.css" type="text/css" />';

      my $faviconlink = '<MTHasFavicon><link rel="shortcut icon" href="<$MTFaviconURL$>" /></MTHasFavicon>';

      my $qcsslink = quotemeta($csslink);
      my $qfaviconlink = quotemeta($faviconlink);
      if ($text =~ /$qcsslink/ ){
        if(!($text =~ /$qfaviconlink/)) {
          $text =~ s/$qcsslink/$csslink\n   $faviconlink/;
          $tmpl->{text} = $text;
        }
      }
    }
  }
}

sub get_favicon_url {
    my $plugin = shift;
    my ($blog_id) = @_;
    my %plugin_param;

    $plugin->load_config(\%plugin_param, 'blog:'.$blog_id);
    my $url = $plugin_param{favicon_path_to_icon};
    unless ($url) {
        $plugin->load_config(\%plugin_param, 'system');
        $url = $plugin_param{favicon_path_to_icon};
    }
    my $nonurlchar = '[^A-Za-z0-9\-\_\.\/\~\,\$\!\*\'\(\)\;\:\@\=\&\+]';
    die "out of URL characters in Favicon URL" if $url =~ /$nonurlchar/;
    $url;
}

sub _hdlr_favicon_url {
  my ($ctx, $args) = @_;
  my $url = $plugin->get_favicon_url($ctx->stash('blog_id'));
  $url;
}

sub _hdlr_favicon_type {
  my ($ctx, $args) = @_;
  my $url = $plugin->get_favicon_url($ctx->stash('blog_id'));
  $url =~ s/.*\.//;
  $url;
}

sub _hdrl_has_favicon {
  my ($ctx, $args, $cond) = @_;
  my $url = $plugin->get_favicon_url($ctx->stash('blog_id'));
  $url ? 1 : 0;
}

sub _add_cmsfavicon {
  my ($eh, $app, $tmpl_ref) = @_;
  my $plugin_param = $plugin->get_config_hash();
  my $favicon_url;
  return unless ($favicon_url = $plugin_param->{'cmsfavicon_path_to_icon'});
  my $old = <<'HTML';
<link rel="stylesheet" href="<TMPL_VAR NAME=STATIC_URI>styles.css?v=<TMPL_VAR NAME=MT_VERSION ESCAPE=URL>" type="text/css" />
HTML

  my $new = '<link rel="shortcut icon" href="' . $favicon_url;
  $new .= <<'HTML';
">
<link rel="stylesheet" href="<TMPL_VAR NAME=STATIC_URI>styles.css?v=<TMPL_VAR NAME=MT_VERSION ESCAPE=URL>" type="text/css" />
HTML

  $old = quotemeta($old);
  $$tmpl_ref =~ s/$old/$new/;
}

1;

