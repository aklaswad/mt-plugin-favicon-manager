package FaviconManager::L10N::ja;

use strict;
use base 'FaviconManager::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.



%Lexicon = (
  '_PLUGIN_NAME' => 'FaviconManager',
  '_PLUGIN_DESCRIPTION' => '管理画面のfaviconを設定します。',
  '_PLUGIN_AUTHOR' => '澤田 哲',
  'CMS favicon URL' => '管理画面のfaviconのURL',
  'default favicon URL' => 'デフォルトのfaviconのURL',
  'enter URL address of your CMS shortcut icon.' => '管理画面で使用するショートカットアイコンのURLアドレスを指定してください。',
  'enter URL address of your blogs default shortcut icon.' => '各ブログのデフォルトのショートカットアイコンのURLアドレスを指定してください。',
    'enter URL address of this blog shortcut icon.' => 'このブログのショートカットアイコンのURLアドレスを指定してください。',
  'add favicon to new blog' => '新規ブログにfaviconを追加',
  'Insert favicon link tag when you create new blog.' => 'ブログの新規作成時にfaviconを追加',
  'Add favicon link to templates' => 'テンプレートにfaviconを追加',
  'Favicon link added at [_1].' => 'テンプレート [_1] にfaviconのリンクを追加しました',

  'Refreshing template [_1] aborted. favicon link already exists.' => 'テンプレート [_1] の更新は中止されました。すでにショートカットアイコンのリンクが存在します。',
  'Refreshing template [_1] aborted. maybe it is not default template.' => '[_1] テンプレートの更新は中止されました。デフォルトテンプレートでは無いようです。',
  'cant find template' => 'テンプレートが見つかりません。',
  'Adding Favicon Link To Templates' => 'テンプレートにfaviconを追加します。',
);

1;
