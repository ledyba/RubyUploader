def processBBS(req,con)
	fileid = req.RequestHash['file'].to_i;
	selected = selectFileByID(con,fileid);
	if selected == nil
		outHeader(req,"そのエントリが存在しません");
		puts 'そのエントリが存在しません'
		return
	end
	case req.RequestHash['bbsmode']
		when nil
			outHeader(req,"掲示板：#{CGI.escapeHTML selected[:orig_name]}");
			BBS_outFileImage(req,selected);
			BBS_outPost(req,con,fileid);
			outBBSForm(req);
		when 'delete'
			outHeader(req,"書き込みを削除");
			post = selectPostByID(con,req.RequestHash['postid'].to_i);
			post_hash = req.PostHash;
			if post == nil || post[:erased] == 't' || post[:erased] == 'true'
				puts '<p>そのような書き込みは存在しません。</p>'
			else
				if post_hash.size <= 0
					puts '<p>以下の書き込みを削除しますか？</p><hr />'
					outBBSItem(req,post);
					outBBSDeleteForm(req);
				else
					password = post_hash['password'][0];
					if password == MASTER_PASSWORD || password == post[:password]
						delPostByID(con,selected[:id],post[:id]);#POSTを削除
						puts '<p>削除に成功しました。</p>'
						puts "<ul><li><a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['postid',nil],['bbsmode',nil],])}\">戻る</a></li></ul>"
					else
						puts '<p>パスワードが違います。</p>'
						puts "<ul><li><a href=\"#{UPLOADER_LOCATION}?#{req.getQuery}\">戻る</a></li></ul>"
					end
				end
			end
		when 'post'
			outHeader(req,"投稿に成功しました。");
			BBS_addPost(req,con,selected);
			puts '<p>投稿に成功しました。</p>'
			puts '<hr />'
			BBS_outFileImage(req,selected);
			BBS_outPost(req,con,fileid);
			outBBSForm(req);
	end
end

def BBS_outPost(req,con,fileid)
	cnt = selectPostAll(con,fileid){|item|
		outBBSItem(req,item);
	}
	if cnt == 0
		puts '<p>この掲示板にはまだ何も記事が書かれていません。</p><hr />'
	end
end

def BBS_addPost(req,con,selectedfile)
	post_hash = req.PostHash;
	fileid = selectedfile[:id];
	username = post_hash['username'][0]
	password = post_hash['password'][0]
	posttext = post_hash['posttext'][0]
	addPost(con,fileid,username,password,posttext);
end

def BBS_outFileImage(req,file)
	viewed_orig_name = CGI.escapeHTML file[:orig_name];
	puts '<ul>'
	puts "<li>ファイル名：<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['mode','down'],['bbsmode',nil]])}\">#{viewed_orig_name}</a></li>"
	puts "<li>説明：#{CGI.escapeHTML file[:desctext]}</li>"
	puts "<li>アプ主：#{CGI.escapeHTML file[:username]}</li>"
	puts "<li>アップロード時間：#{file[:uploaded]}</li>"
	puts "<li>ダウンロード回数：#{file[:downcnt]}</li>"
	puts "<li>掲示板書き込み数：#{file[:postcnt]}</li>"
	puts '</ul>'
	#if file[:content_type].downcase.index('image/') == nil
	#else
	#	puts '<hr />'
	#	puts "<a href=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['binmode','true'],['mode','down'],['bbsmode',nil]])}\">"
	#	puts "<img src=\"#{UPLOADER_LOCATION}?#{req.getQueryArray([['binmode','true'],['mode','down'],['bbsmode',nil]])}\" alt=\"#{viewed_orig_name}\" id=\"view_gfx\" />"
	#	puts '</a>'
	#end
	puts '<hr />'
end

