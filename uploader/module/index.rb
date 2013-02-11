#ほぼ完了
def processIndex(req,con)
	que_hash = req.RequestHash;
	outHeader(req,"トップページ");
	outForm(req);
	puts '<hr />'
	outSearchForm();

	cnt = 0;
	offset = que_hash['page'];
	if offset=='all'
		offset = -1;
	else
		offset = offset.to_i;
	end
	outList{
		if offset < 0
			cnt = selectFileAll(con){|item|
				outListItem(req,item);
			}
		else
			cnt = selectFile(con,offset){|item|
				outListItem(req,item);
			}
		end
	}
	outListNextLink(req,cnt);
end
