ATOM_TYPE_POST = 0
ATOM_TYPE_FILE = 1
require 'time'
def processRSS(req,con)
	#ヘッダ出力
	req.setContentType('text/xml; charset=UTF-8');
	req.sendHeader()
	OUT_atomStart();
	#DB操作
	files = selectFile(con);
	posts = selectPostAll(con,nil,UPLOADER_FILE_PER_PAGE);
	files_lastupdated = Time.parse(files[0][:uploaded]);
	posts_lastupdated = Time.parse(posts[0][:posted]);
	OUT_atomInfo(files_lastupdated > posts_lastupdated ? files_lastupdated : posts_lastupdated)
	#出力しちゃう
	post_idx = 0
	file_idx = 0
	while (post_idx + file_idx) < UPLOADER_FILE_PER_PAGE
		file_updated = Time.parse(files[file_idx][:uploaded]);
		post_updated = Time.parse(posts[post_idx][:posted]);
		if file_updated > post_updated
			OUT_atomEntry(ATOM_TYPE_FILE,file_updated,files[file_idx]);
			file_idx+=1;
		else
			OUT_atomEntry(ATOM_TYPE_POST,post_updated,posts[post_idx]);
			post_idx+=1;
		end
	end
	#出力終わり
	OUT_atomEnd();
end

def OUT_atomStart()
	puts '<?xml version="1.0" encoding="utf-8"?>'
	puts '<feed xmlns="http://www.w3.org/2005/Atom">'
end

def OUT_atomInfo(lastupdate)
	puts"<title>#{UPLOADER_TITLE}</title>"
	puts "<link href=\"#{UPLOADER_LOCATION}\" />"
	puts "<updated>#{lastupdate.iso8601}</updated>"
	puts '<author>'
	puts "<name>#{UPLOADER_NAME}</name>"
	puts '</author>'
	puts "<id>#{ATOM_ID}</id>"
end

def OUT_atomEntry(type,updated,item)
	case type
		when ATOM_TYPE_POST
			type_str = 'post'
			fileid = item[:fileid];
			title = "投稿：#{item[:username]}"
		when ATOM_TYPE_FILE
			type_str = 'file'
			fileid = item[:id];
			title = "ファイル：#{item[:desctext]}"
	end
	puts '<entry>'
	puts "<title>#{title}</title>"
	puts "<link href=\"#{UPLOADER_LOCATION}?mode=bbs&amp;file=#{fileid}\"/>"
	puts "<id>#{ATOM_ID}_#{type_str}#{item[:id]}</id>"
	puts "<updated>#{updated.iso8601}</updated>"
	puts '<summary>'
	puts '</summary>'
	puts '</entry>'
end

def OUT_atomEnd()
	puts '</feed>'
end

