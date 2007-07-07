<?php

global $mt;
$ctx = &$mt->context();

function faviconmanager_add_favicon($tmpl, &$ctx){
    $insert_text = '<link rel="shortcut icon" href="http://www.msn.com/favicon.ico" />' . "\n    <link";
    $tmpl = preg_replace('!<link!', $insert_text, $tmpl, 1);
    return $tmpl;

}

$ctx->register_outputfilter("faviconmanager_add_favicon");

?>
