function handler () {

  echo $1 1>&2;

  # パラメータはjson形式で来るのでjqで分解
  FROM=`echo $1 | jq -r '.from'`
  TO=`echo $1 | jq -r '.to'`

  echo "FROM=$FROM" 1>&2;
  echo "TO=$TO" 1>&2;

  RESPONSE="Error"
  if [ -n "$FROM" -o "$FROM" = null -o -n "$TO" -o "$TO" = null]; then
    echo $RESPONSE
    exit 0
  fi

  # 変数展開を利用してファイル名を取り出したり、拡張子を取り除いたりする
  FROMEXT="${FROM##*/}"
  echo "FROMEXT=$FROMEXT" 1>&2;
  FROMNOEXT="${FROMEXT%.*}"
  echo "FROMNOEXT=$FROMNOEXT" 1>&2;

  # 変換後のファイル名は元のファイル名に拡張子を.pdfに変えたものになるはず
  TOEXT="${FROMNOEXT}.pdf"
  echo "TOEXT=$TOEXT" 1>&2;
  TOFULLPATH="${TO%/}/${TOEXT}"

  # Lambdaにおいて書き込み先は/tmpが無難
  mkdir -p /tmp/convertpdf
  cd /tmp/convertpdf
  aws s3 cp $FROM . 1>&2
  # Libreofficeは起動時にキャッシュを作るが、ホームディレクトリへの書き込みは禁じられているので、
  # ユーザープロファイルの場所も変えて起動する
  # https://wiki.documentfoundation.org/UserProfile
  # https://help.libreoffice.org/3.3/Common/Starting_the_Software_With_Parameters/ja
  /usr/bin/soffice -env:UserInstallation=file:///tmp/convertpdf --headless --convert-to pdf --outdir . ${FROMEXT} 1>&2;

  if [ -f "$TOEXT" ]; then
    aws s3 cp ${TOEXT} ${TOFULLPATH} 1>&2;
    rm -rf /tmp/convertpdf
    
    RESPONSE=$TOFULLPATH
  fi

  echo $RESPONSE

}