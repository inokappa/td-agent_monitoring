# オレオレ td-agent 内部情報監視 dashboard

## 必要なもの

 * Sinatra
 * Graphite

***

## 使い方

 1. git clone
 1. apt-get install libsqlite3-dev(for debian and ubuntu) 
 1. gem install bundler 
 1. bundle install
 1. Change `GRAPHITE HOST` 
 1. bundle exec rackup config.ru
 1. Access to `/addhost` and Add Host
 1. Access to `overview`

あらかじめ `Graphite` をセットアップしておく必要がある。

***

## 出来ること

 * `td-agent` 又は `fluentd` の `monitor_agent` プラグインで取得出来る内部情報をホスト毎に表示出来る（はず）
 * `Graphite` を利用して各プラグインの `retry_count` / `buffer_total_queued_size` / `buffer_queue_length` のメトリクスを表示することが出来る（はず）

## Screenshot

#### ダッシュボード

 ![](http://hogehuga.inokara.com/images/2014060111.png)

#### メトリクス追加 

 ![](http://hogehuga.inokara.com/images/2014060113.png)

#### ホストの追加

 ![](http://hogehuga.inokara.com/images/2014060112.png)

***

## todo

 * メトリクスの情報は `Modal` で表示出来るようにする
 * `5` 分ごとにブラウザをリフレッシュさせているのを止める
 * タブがちゃんと動いていないので動くようにする
 * ホストの登録は `Serf` を利用して自動で行えるようにしたい
