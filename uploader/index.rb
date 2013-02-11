def main()
	req = Boggy::Web::Request::new({},{'color'=>'white','username'=>'名無しさん'},{},['color','username']);
	con = SQL_init()
	#モード別に分岐
	case req.RequestHash['mode']
		when nil#完了
			processIndex(req,con);
			outFooter();
		when 'down'#完了
			#フッタは送信しない
			processDown(req,con);
		when 'upload'#完了
			processUpload(req,con);
			outFooter();
		when 'delete'#完了
			processDelete(req,con);
			outFooter();
		when 'search'#完了
			processSearch(req,con);
			outFooter();
		when 'bbs'
			processBBS(req,con);
			outFooter();
		when 'rss'
			processRSS(req,con);
	end
	con.close
end

