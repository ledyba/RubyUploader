#とりあえずここにおいておく
def outLeftTime(is_center = false)
	left = ((is_center ? Time.local(2009,01,17,9) : Time.local(2008,12,16,15,30))-Time.now).to_i;
	day = left / (3600 * 24);
	hour = (left -= (day * 3600 * 24))/3600;
	min = (left -= hour * 3600) / 60;
	sec = left - (min * 60);
	return "<strong>#{day}日#{hour}時間#{min}分#{sec}秒</strong>"
end

#ウェブ関係のセッティング
UPLOADER_LOCATION="/*************"
UPLOADER_TITLE="***********************"
UPLOADER_NAME="****************** ver1.7(2008/11/20)"
UPLOADER_DESCRIPTION="身内専用<br /><strong>Atomフィードを追加！GoogleReaderやFirefoxなどで更新情報を確認できます！</strong><br />センター(2009/01/17)まで#{outLeftTime(true)}です。"
UPLOADER_SKINS=[
			{:desc=>"白属性",:name=>"white"},
			{:desc=>"黒属性",:name=>"black"}
]

#一画面に何ファイル表示する？
UPLOADER_FILE_PER_PAGE=30

MASTER_PASSWORD='*********************'

#いじらないでください
LOCAL_FILE_LOCATION="files/"
UPLOADER_SKIN_LOCATION="skin/"
UPLOADER_FILE_PREFIX="rima";

#ATOM用定数群
ATOM_ID = 'urn:PSI5465165445:JaglingParty65461657324651657'

#必要なライブラリ
require 'rubygems'
require 'request.rb'
