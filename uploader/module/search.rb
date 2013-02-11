require 'kconv'
def processSearch(req,con)
	que_hash = req.RequestHash;
	word = que_hash['search'];
	word_viewd = CGI.escapeHTML(word);

	outHeader(req,"「#{word_viewd}」の検索結果");
	outForm(req);
	puts '<hr />'
	outSearchForm(word_viewd);
	puts "<p>「#{word_viewd}」の検索結果を以下に示します。</p>"
	puts '<hr />'

	cnt = 0;
	offset = que_hash['page'];
	if offset=='all'
		offset = -1;
	else
		offset = offset.to_i;
	end

	outList{
		if offset < 0
			cnt = selectFileAll(con,word){|item|
				outListItem(req,item);
			}
		else
			cnt = selectFile(con,offset,word){|item|
				outListItem(req,item);
			}
		end
	}
	outListNextLink(req,cnt);
end

