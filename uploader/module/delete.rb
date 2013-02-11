def processDelete(req,con)
	id = req.RequestHash['file'].to_i;
	selected = selectFileByID(con,id);
	if selected == nil
		outHeader(req,"そのエントリが存在しません");
		puts 'そのエントリが存在しません'
		outFooter();
		return
	end
	post = req.PostHash;
	if post.size <= 0
		outHeader(req,"ファイルを削除します");
		puts '<p>次のファイルを削除する場合、パスワードを入力して送信してください。</p>'
		outFileDelInfo(req,selected);
	else
		password = post['password'][0];
		if (selected[:password] != '' && password == selected[:password]) || (password == MASTER_PASSWORD)
			outHeader(req,"ファイルの削除に成功しました");
			delFileByID(con,selected);
			puts '<p>ファイルの削除に成功しました。</p>'
			puts "<ul><li><a href=\"#{UPLOADER_LOCATION}\">トップページへ戻る</a></li></ul>"
		else
			outHeader(req,"パスワードが違います");
			puts '<p>パスワードが異なります。再度試してみてください</p>'
			outFileDelInfo(req,selected)
		end
	end
end

def outFileDelInfo(req,selected)
	puts '<hr />'
	puts '<ul>'
	puts "<li>ファイル名：#{CGI.escapeHTML selected[:orig_name]}</li>"
	puts "<li>説明：#{CGI.escapeHTML selected[:desctext]}</li>"
	puts "<li>アプ主：#{CGI.escapeHTML selected[:username]}</li>"
	puts "<li>アップロード時間：#{selected[:uploaded]}</li>"
	puts "<li>ダウンロード回数：#{selected[:downcnt]}</li>"
	puts "<li>掲示板書き込み数：#{selected[:postcnt]}</li>"
	puts '</ul>'
	puts "<form method=\"post\" action=\"#{UPLOADER_LOCATION}?#{req.getQuery}\">"
	puts 'パスワード：<input type="password" size="10" name="password" />'
	puts '<input type="submit" value="削除" />'
	puts '</form>'
	puts '<hr />'
	puts "<ul><li><a href=\"#{UPLOADER_LOCATION}\">トップページへ戻る</a></li></ul>"
end
