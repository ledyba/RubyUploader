#!/bin/bash


#定数定義
INSTALL_FOLDER=******************************
DBMS=postgres

#フォルダ作成
mkdir ${INSTALL_FOLDER}
mkdir ${INSTALL_FOLDER}/skin
mkdir ${INSTALL_FOLDER}/files
chmod 777 ${INSTALL_FOLDER}/files

#構造コピー

#スクリプト本体のリビルド
rm ${INSTALL_FOLDER}/index.rb
cat ./uploader/conf.rb \
	./uploader/lib/sql_${DBMS}.rb \
	./uploader/index.rb \
	./uploader/lib/util.rb \
	./uploader/module/*.rb \
	./uploader/startup.rb \
	> ${INSTALL_FOLDER}/index.rb
chmod a+x ${INSTALL_FOLDER}/index.rb

#ライブラリ
rm ${INSTALL_FOLDER}/request.rb
svn export *************************************** ${INSTALL_FOLDER}/request.rb
chmod a+x ${INSTALL_FOLDER}/request.rb

#スキン
rm ${INSTALL_FOLDER}/skin/*
cp ./uploader/skin/* ${INSTALL_FOLDER}/skin/

#所有者はnobodyにしておく
chown nobody.root ${INSTALL_FOLDER} -R
