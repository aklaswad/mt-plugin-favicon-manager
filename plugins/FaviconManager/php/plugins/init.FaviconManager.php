<?php

global $mt;
$smarty =& $mt->context();
$smarty->register_outputfilter("faviconmanager_add_favicon");

function faviconmanager_add_favicon($tmpl, &$ctx){
    $blogid = $ctx->stash('blog_id');
    $scope = 'blog:' . $blogid;
    $config = $ctx->mt->db->fetch_plugin_config('FaviconManager', $scope);
    print_r($ctx);
    if ($config) {
        $setting_str = $config['faviconmanager_blog_icon'];
        $favicon_url = '';

        if (preg_match('/^asset:/', $setting_str)) {
            $asset_id = preg_replace('/^asset:/', '', $setting_str, 1);
            $args['asset_id'] = $asset_id;
            $asset = $ctx->mt->db->fetch_assets($args);
            if ($asset) {
                $favicon_url = $asset[0]['asset_url'];
            }
        }
        else {
            $favicon_url = $setting_str;
        }

        if ($favicon_url) {
            $insert_text = '<link rel="shortcut icon" href="' . $favicon_url . '" />' . "\n   <link";
            $tmpl = preg_replace('/<link/', $insert_text, $tmpl, 1);
        }
    }
    return $tmpl;
}

?>
