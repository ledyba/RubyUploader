def processUpload(req,con)
	uploaded = false;
	postHash = req.PostHash;
	file = postHash['file'][0];
	username = postHash['username'][0].read;
	password = postHash['password'][0].read;
	desctext = postHash['desctext'][0].read;
	path = makeTmpChar();
	orig_name = file.original_filename;
	separate_idx = orig_name.rindex('\\');
	if separate_idx != nil#IEのバグ対応
		orig_name = orig_name[separate_idx+1..-1]
	end
	content_type = file.content_type;
	size = file.size;
	#ファイルがあるなら追加
	if size > 0
		uploaded = true
		#ファイルコピー開始
		copy_file = File::open(LOCAL_FILE_LOCATION+path,'w',0666);
		FileUtils.copy_stream(file,copy_file);
		copy_file.flush;
		copy_file.close;
		#DBに追加
		addFile(con,path,content_type,orig_name,size,desctext,username,password);
	end
	#もういらないのでクローズ
	file.close;

	#やっと開始
	outHeader(req,"ファイルをアップロードしました");
	outForm(req);
	puts '<hr />'
	if uploaded
		puts "<p>ファイル「#{CGI.escapeHTML(orig_name)}」のアップロードを行いました</p>"
	else
		puts "<p>ファイルが無かったのでリロード扱いにしました</p>"
	end
	puts '<hr />'
	outSearchForm();
	cnt = 0;
	offset = 0;
	outList{
		cnt = selectFile(con){|item|
			outListItem(req,item);
		}
	}
	outListNextLink(req,cnt,true);
end

TMP_CHARS = '0123456789abcdefghijklmnopqrstuvwxyz'
def makeTmpChar(length = 20)
	ret = Time.now.strftime('%Y%m%d_%H%M%S_');
	for i in 1..length
		index = rand(TMP_CHARS.size);
		ret += TMP_CHARS[index..index];
	end
	return ret;
end

