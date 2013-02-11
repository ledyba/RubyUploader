#ほぼ完了
def processDown(req,con)
	#ファイルダウンロード部分
	id = req.RequestHash['file'].to_i;
	selected = selectFileByID(con,id);
	if selected == nil
		outHeader(req,"そのエントリが存在しません");
		puts 'そのエントリが存在しません'
		outFooter();
		return
	end
	path = LOCAL_FILE_LOCATION+selected[:path];
	begin
		file = File::open(path.untaint,'r');
	rescue
		outHeader(req,"そのファイルが存在しません");
		puts 'そのファイルが存在しません'
		outFooter();
		return;
	end
	content_type = selected[:content_type].downcase;
	is_image = content_type.index('image/') == 0;
	is_text = content_type.index('text/') == 0;
	if req.RequestHash['binmode'] == 'true' || (!is_image && !is_text)
		req.setContentType(selected[:content_type]);
		if req.RequestHash['numbering'] != 'true'
			req.sendHeader('Content-Disposition',"attachment; filename=\"#{selected[:orig_name]}\"");
		else
			newname = UPLOADER_FILE_PREFIX+sprintf("%08d",selected[:id])+File.extname(selected[:orig_name]);
			req.sendHeader('Content-Disposition',"attachment; filename=\"#{newname}\"");
		end
		req.setContentLength(selected[:size]);
		req.sendHeader
		#ファイルを送信！
		FileUtils.copy_stream(file,$defout);
		#ファイルダウンロード数追加処理
		updateDownCntByID(con,id);
	elsif is_image
		viewed_orig_name = CGI.escapeHTML(selected[:orig_name]);
		outHeader(req,"ファイルを表示：#{viewed_orig_name}");
		puts '<ul>'
		puts "<li>ファイル名：<a href=\"#{UPLOADER_LOCATION}?#{req.getQuery('binmode','true')}\">#{viewed_orig_name}</a></li>"
		puts "<li>説明：#{CGI.escapeHTML selected[:desctext]}</li>"
		puts "<li>アプ主：#{CGI.escapeHTML selected[:username]}</li>"
		puts "<li>アップロード時間：#{selected[:uploaded]}</li>"
		puts "<li>ダウンロード回数：#{selected[:downcnt]}</li>"
		puts "<li>掲示板書き込み数：#{selected[:postcnt]}</li>"
		puts '</ul>'
		puts '<hr />'
		puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQuery('binmode','true')}\">"
		puts "<img src=\"#{UPLOADER_LOCATION}?#{req.getQuery('binmode','true')}\" alt=\"#{viewed_orig_name}\" id=\"view_gfx\" />"
		puts '</a>'
		#img hrefのリクエストでダウンロード数は加算されるので、いらない。
	elsif is_text
		viewed_orig_name = CGI.escapeHTML(selected[:orig_name]);
		outHeader(req,"ファイルを表示：#{viewed_orig_name}");
		puts '<ul>'
		puts "<li>ファイル名：<a href=\"#{UPLOADER_LOCATION}?#{req.getQuery('binmode','true')}\">#{viewed_orig_name}</a></li>"
		puts "<li>説明：#{CGI.escapeHTML selected[:desctext]}</li>"
		puts "<li>アプ主：#{CGI.escapeHTML selected[:username]}</li>"
		puts "<li>アップロード時間：#{selected[:uploaded]}</li>"
		puts "<li>ダウンロード回数：#{selected[:downcnt]}</li>"
		puts "<li>掲示板書き込み数：#{selected[:postcnt]}</li>"
		puts '</ul>'
		puts '<hr /><pre>'
		FileUtils.copy_stream(file,$defout);
		puts '</pre>'
		#ファイルダウンロード数追加処理
		updateDownCntByID(con,id);
	end
	file.close;
	if req.RequestHash['binmode'] != 'true' && (is_image || is_text)
		puts '<hr />'
		BBS_outPost(req,con,id);
		outBBSForm(req);
		outFooter();
	end
end

