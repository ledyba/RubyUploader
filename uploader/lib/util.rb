#ヘッダを出力
def outHeader(req,mode)
	#ヘッダは出力しておく
	req.sendHeader()
	#スキンを設定
	color = req.CookieHash['color'];
	css_path = UPLOADER_SKIN_LOCATION+UPLOADER_SKINS[0][:name]+".css"
	UPLOADER_SKINS.each(){|item|
		if item[:name] == color
			css_path = UPLOADER_SKIN_LOCATION+color+".css"
			break
		end
	}
	#出力
	puts '<?xml version="1.0" encoding="UTF-8"?>'
	puts '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	puts '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">'
	puts '<head>'
	puts ' <meta http-equiv="Content-Style-Type" content="text/css" />'
	puts ' <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
	puts " <title> #{UPLOADER_TITLE}－#{mode}</title>"
	puts " <link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"#{css_path}\" charset=\"UTF-8\" />"
	puts "<link rel=\"alternate\" type=\"application/atom+xml\" title=\"Atomフィード\" href=\"#{UPLOADER_LOCATION}?mode=rss\" />"
	puts '</head>'
	puts '<body>'
	puts "<div id=\"header\"><a href=\"#{UPLOADER_LOCATION}\">#{UPLOADER_TITLE}</a>－#{mode}</div>"
	puts "<div id=\"desc\">#{UPLOADER_DESCRIPTION}</div>"
	puts '<div id="skin_changer"><ul id="skin_changer_list">'
	UPLOADER_SKINS.each(){|item|
		puts "<li class=\"skin_changer_item\"><a href=\"#{UPLOADER_LOCATION}?#{req.getQuery('color',item[:name])}\">#{item[:desc]}</a></li>";
	}
	puts '</ul></div><hr />'
end

def outFooter()
	puts '<hr />'
	puts '<div id="footer">'
	puts '<div style="text-align:right">'
	puts "#{UPLOADER_NAME} written by <a href=\"http://ledyba.ddo.jp/\">PSI</a><br />"
	puts 'Powered by mod_ruby + PostgreSQL'
	puts '</div>'
	puts '</div>'
	puts '</body>'
	puts '</html>'
end

def outForm(req)
	cookie_hash = req.CookieHash;
	puts '<div id="form">'
	puts '<div id="form_title">ファイルを登録する</div>'
	puts '<div id="form_content">'
	puts "<form method=\"post\" enctype=\"multipart/form-data\" action=\"#{UPLOADER_LOCATION}?mode=upload\">"
	puts 'ファイル：<input type="file"  size="60" name="file" /><br />'
	puts "あなたの名前：<input type=\"text\" size=\"20\" name=\"username\" value=\"#{CGI.escapeHTML cookie_hash['username']}\" />"
	puts 'パスワード：<input type="password" size="20" name="password" /><br />'
	puts 'ファイルの説明：<input type="text" size="60" name="desctext" value="" /><br />'
	puts '<input type="submit" value="送信" />'
	puts '</form>'
	puts '</div>'
	puts '</div>'
end

def outSearchForm(default = '')
	puts '<div id="search">'
	puts "<form method=\"get\" action=\"#{UPLOADER_LOCATION}?mode=search\">"
	puts "検索：<input type=\"text\" size=\"40\" name=\"search\" value=\"#{default}\" />"
	puts '<input type="hidden" name="mode" value="search" />'
	puts '<input type="submit" value="検索" />'
	puts '</form>'
	puts '</div>'
	puts '<hr />'
end

def outList()
	outListHeader()
	begin
		yield()
	rescue LocalJumpError
	end
	outListFooter()
end

def outListHeader()
	puts '<table id="file_table" summary="ファイルリスト">'
	puts '<tr>'
	puts '<th abbr="削除">Del</th>'
	puts '<th abbr="掲示板">BBS</th>'
	puts '<th abbr="No.">No.</th>'
	puts '<th abbr="ファイル名">ファイル名</th>'
	puts '<th abbr="説明">説明</th>'
	puts '<th abbr="アプ主">アプ主</th>'
	puts '<th abbr="時間">時間</th>'
	puts '<th abbr="サイズ">size</th>'
	puts '<th abbr="DL数">DL</th>'
	puts '</tr>'
end

def outListFooter()
	puts '</table>'
end

def outListItem(req,item)
	puts '<tr>'
	puts "<td><a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','delete'],['file',item[:id]]])}\">Del</a></td>"
	puts "<td><a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','bbs'],['file',item[:id]]])}\">#{item[:postcnt]}件</a></td>"
	puts "<td><a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','down'],['file',item[:id]],['numbering','true']])}\">#{item[:id]}</a></td>"
	puts "<td><a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','down'],['file',item[:id]]])}\">#{CGI.escapeHTML item[:orig_name]}</a></td>"
	puts "<td>#{CGI.escapeHTML item[:desctext]}</td>"
	puts "<td>#{CGI.escapeHTML item[:username]}</td>"
	puts "<td>#{item[:uploaded]}</td>"
	puts "<td>#{item[:size]}</td>"
	puts "<td>#{item[:downcnt]}</td>"
	puts '</tr>'
end

def outListNextLink(req,size,reset_page = false)
	off_str = req.RequestHash['page'];
	if off_str == 'all'
		return
	else
		offset = off_str.to_i;
	end
	puts '<div id="next_link">'
	#前のページ
	if offset > UPLOADER_FILE_PER_PAGE
		if reset_page
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode',nil],['page',(offset-UPLOADER_FILE_PER_PAGE).to_s]])}\">[前のページへ]</a>"
		else
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['page',(offset-UPLOADER_FILE_PER_PAGE).to_s]])}\">[前のページへ]</a>"
		end
	elsif offset != 0
		if reset_page
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode',nil],['page','0']])}\">[前のページへ]</a>"
		else
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['page','0']])}\">[前のページへ]</a>"
		end
	end
	#すべて表示
	if reset_page
		puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode',nil],['page','all']])}\">[すべて表示]</a>"
	else
		puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['page','all']])}\">[すべて表示]</a>"
	end
	#次のページ
	if size >= UPLOADER_FILE_PER_PAGE
		if reset_page
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode',nil],['page',(offset+UPLOADER_FILE_PER_PAGE).to_s]])}\">[次のページへ]</a>"
		else
			puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['page',(offset+UPLOADER_FILE_PER_PAGE).to_s]])}\">[次のページへ]</a>"
		end
	end
	puts '</div>'
	
end

##BBS関連

def outBBSForm(req)
	cookie_hash = req.CookieHash;
	puts 'このファイルの掲示板にポスト'
	puts '<div id="bbs_form">'
	puts "<form method=\"post\" action=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','bbs'],['bbsmode','post']])}\">"
	puts "名前：<input type=\"text\" size=\"40\" name=\"username\" value=\"#{CGI.escapeHTML cookie_hash['username']}\" />"
	puts 'パスワード：<input type="password" size="20" name="password" /><br />'
	puts '<textarea name="posttext" cols="60" rows="4"></textarea>'
	puts '<input type="submit" value="送信" />'
	puts '</form>'
	puts '</div>'
end

def outBBSItem(req,item)
	if item[:erased] == 't' || item[:erased] == 'true'
		puts '<div class="bbs_post">'
		puts '<div class="bbs_bar">'
		puts '<span class=\"bbs_del\">[DEL]</span>&nbsp;'
		puts "<span class=\"bbs_id\"><a name=\"post#{item[:postid]}\">#{item[:postid]}</a></span>&nbsp;"
		puts '<span class=\"bbs_name\">あぼーん</span>&nbsp;'
		puts "<span class=\"bbs_name\">0000-00-00 00:00:00</span>"
		puts '</div>'
		puts '<div class="bbs_post">'
		puts 'あぼーん'
		puts '</div>'
		puts '</div>'
		puts '<hr />'
	else
		puts '<div class="bbs_post">'
		puts '<div class="bbs_bar">'
		puts "<span class=\"bbs_del\">[<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','bbs'],['bbsmode','delete'],['postid',item[:id]]])}\">DEL</a>]</span>&nbsp;"
		puts "<span class=\"bbs_id\"><a name=\"post#{item[:postid]}\">#{item[:postid]}</a></span>&nbsp;"
		puts "<span class=\"bbs_name\">#{item[:username]}</span>&nbsp;"
		puts "<span class=\"bbs_name\">#{item[:posted]}</span>"
		puts '</div>'
		puts '<div class="bbs_post">'
		puts convertHTML(item[:posttext]);
		puts '</div>'
		puts '</div>'
		puts '<hr />'
	end
end

def outBBSDeleteForm(req)
	puts '<div id="bbs_del_form">'
	puts "<form method=\"post\" action=\"#{UPLOADER_LOCATION}?#{req.getQuery}\">"
	puts 'パスワード：<input type="password" size="20" name="password" />'
	puts '<input type="submit" value="送信" />'
	puts '</form>'
	puts '</div>'
end

URL_ESCAPE_REGEXP = /(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%\(\)]+)/
LINE_ESCAPE_REGEXP = /((\r\n)|\n|\r){5,}/;
LINE_HTML_REGEXP = /((\r\n)|\n|\r)/;
POST_ESCAPE_REGEXP = /&gt;&gt;([0-9]*)/
def convertHTML(content)
	content = CGI.escapeHTML(content);
    content.gsub!(LINE_ESCAPE_REGEXP,'\n\n\n\n\n');
    content.gsub!(LINE_HTML_REGEXP,'<br />');
    content.gsub!(URL_ESCAPE_REGEXP, '<a href=\'\\1\'>\\1</a>')
    content.gsub!(POST_ESCAPE_REGEXP,'<a href=#post\\1>&gt;&gt;\\1</a>');
	return content;
end
