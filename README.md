
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kansuji2arabic.MeCab

<!-- badges: start -->

<!-- badges: end -->

`{kansuji2arabic.MeCab}`は文字列中の漢数字をアラビア数字に変換するための関数を含むパッケージで、`{zipangu}`の`kansuji2arbic_str()`を`MeCab`を使用し形態素解析を行った品詞細分類上で数と判定された漢数字のみをアラビア数字に変換するように改変したものです。

処理に`MeCab`を使用しているので、`MeCab`が使用する辞書によって結果（変換精度)は異なります

## Imports

Rパッケージ以外の必要ソフトウェア

  - `MeCab`

`MeCab`については[MeCab: Yet Another Part-of-Speech and Morphological
Analyzer](https://taku910.github.io/mecab/)に詳細がああります。

Rパッケージ

  - `{RMeCab}`
  - `{stringr}`
  - `{zipangu}`
  - `{arabic2kansuji}`
  - `{purrr}`
  - `{stats}`
  - `{utils}`

現在、`{zipangu}`はgithubからインストールできる開発版[uribo/zipangu](https://github.com/uribo/zipangu)に依存しています。

`{RMeCab}`と`{arabic2kansuji}`はCRANに登録されていないパッケージです。

`{arabic2kansuji}`は[indenkun/arabic2kansuji](https://github.com/indenkun/arabic2kansuji)に詳細があります。

`{RMeCab}`は[アールメカブ -
RMeCab](http://rmecab.jp/wiki/index.php?RMeCab)に詳細があります。

## Installation

``` r
remotes::install_github("indenku/kansuji2arabic.MeCab")
```

でインストールできます。

## Example

``` r
library(kansuji2arabic.MeCab)
## basic example code
```

`{kansuji2arabc.MeCab}`は`kansuji2arabic_str_MeCab()`のみを含みます。

基本動作は、`{zipangu}`の`kansuji2arabic_str()`と同じで、文字列中の漢数字をアラビア数字に漢数字が表す数で変換するものです。

``` r
kansuji2arabic_str_MeCab("東京都新宿区西新宿二丁目八-一")
#> [1] "東京都新宿区西新宿2丁目8-1"
```

上記の例（東京都庁の住所）では`zipangu::kansuji2arabic_str()`と同じ結果になりますが、次の例（徳島県庁の住所）では

``` r
zipangu::kansuji2arabic_str("徳島県徳島市万代町一-一")
#> [1] "徳島県徳島市10000代町1-1"
kansuji2arabic_str_MeCab("徳島県徳島市万代町一-一")
#> [1] "徳島県徳島市万代町1-1"
```

と、万代町を固有名詞と`MeCab`が判定することで万を10000に変換することを避けることができます（`MeCab`のデフォルトの辞書の場合）。

ただし、デフォルトの辞書の場合は一月、二月という月が品詞細分類で副詞可能と判定されるため、

``` r
kansuji2arabic_str_MeCab("一月一日")
#> [1] "一月1日"
```

となってしまいますが、`MeCab`（辞書）の処理に依存するものであり仕様です。使用する辞書を変更するとうまく変換できるかもしれません（未検証です）。

この他にも`MeCab`側で数を表す漢数字を品詞細分類で数と判定していない場合には、うまく漢数字からアラビア数字に意図した形に変換できません。

また、未知語の処理についても`MeCab`は優れていますが、その上で固有明治相当の漢数字が数と判定された場合には固有名詞の漢数字もアラビア数字に変換します。
