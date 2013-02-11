#インクルード
require 'postgres'

##############################
## File関連のSQL処理
##############################
def SQL_init()
	PGconn.connect('localhost', 5432, '', '', 'uploader','postgres')
end

def selectFile(con,offset = 0,word = nil,size = UPLOADER_FILE_PER_PAGE)
	if word == nil || word == ""
		res = con.exec("select * from file order by id desc offset #{offset} limit #{size}")
	else
		word.gsub!(/['"]/) {|ch| ch + ch }
		sql = "select * from file where "
		cnt = 0;
		#なぜか一度置換する必要があるようだ…。
		word.sub('　',' ').split(/\s/).each{|item|
			if cnt != 0
				sql += " and "
			end
			sql += "(desctext like '%#{item}%' or orig_name like '%#{item}%' or username like '%#{item}%')"
			cnt+=1;
		}
		sql += " order by id desc offset #{offset} limit #{size}";
		res = con.exec(sql);
	end

	if defined? yield
		cnt = 0;
		loopQuery(res){|item|
			yield(item)
			cnt += 1;
		}
		res.clear
		return cnt;
	else
		ret_items = [];
		loopQuery(res){|item|
			ret_items << item
		}
		res.clear
		return ret_items
	end
end

def selectFileByID(con,id)
	res = con.exec("select * from file where id = #{id} order by id desc limit 1")
	if res.num_tuples != 1
		ret = nil;
	else
		ret = {};
		fields = res.fields;
		for i in 0..res.num_fields-1
			ret[fields[i].untaint.to_sym] = res.getvalue(0,i);
		end
		ret.freeze;
	end
	res.clear
	return ret;
end

def updateDownCntByID(con,id)
	res = con.exec("update file set downcnt = downcnt +1, lastdownloaded = date_trunc('sec',current_timestamp) where id = #{id}")
	res.clear
end

#データベースからすべて選択する
def selectFileAll(con,word = nil,size = UPLOADER_FILE_PER_PAGE)
	#準備する
	res = con.exec("begin")
	res.clear
	if word == nil
		res = con.exec("declare cur_file cursor for select * from file order by id desc")
	else
		word.gsub!(/['"]/) {|ch| ch + ch }
		sql = "declare cur_file cursor for select * from file where "
		cnt = 0;
		#なぜか一度置換する必要があるようだ…。
		word.sub('　',' ').split(/\s/).each{|item|
			if cnt != 0
				sql += " and "
			end
			sql += "(desctext like '%#{item}%' or orig_name like '%#{item}%' or username like '%#{item}%')"
			cnt+=1;
		}
		sql += " order by id desc";
		res = con.exec(sql);
	end
	res.clear
	running = true
	index = nil;
	cnt = 0;
	while running
		#フェッチ
		res = con.exec("fetch forward #{size} in cur_file")
		index = loopQuery(res,index){|item|
			yield(item)
			cnt += 1;
		}
		res.clear
		running &= index != nil;
	end
	#終了
	res = con.exec("close cur_file")
	res.clear
	res = con.exec("end")
	res.clear
	return cnt;
end

def loopQuery(res,index = nil)
	#もう終わりかどうかチェックする
	if res.num_tuples < 1
		return nil
	end
	#実際にやってみる
	fields = res.fields;
	#行と中身の対応をチェック
	if index == nil
		index = {};
		cnt = 0;
		fields.each{|field|
			index[cnt] = field.untaint.to_sym
			cnt+=1;
		}
	end
	#実際に読み込む
	for i in 0..res.num_tuples-1
		item = {}
		for j in 0..res.num_fields-1
			item[index[j]] = res.getvalue(i,j);
		end
		yield(item);
	end
	return index;
end

#データベースに追加する
def addFile(con,path,content_type,orig_name,size,desc,username,pass)
	path.gsub!(/['"]/) {|ch| ch + ch }
	orig_name.gsub!(/['"]/) {|ch| ch + ch }
	content_type.gsub!(/['"]/) {|ch| ch + ch }
	desc.gsub!(/['"]/) {|ch| ch + ch }
	username.gsub!(/['"]/) {|ch| ch + ch }
	pass.gsub!(/['"]/) {|ch| ch + ch }
	res = con.exec(
		'insert into file (path,orig_name,content_type,desctext,username,password,size)'+
		"values('#{path}','#{orig_name}','#{content_type}','#{desc}','#{username}','#{pass}',#{size})"
	);
	res.clear
end

#データベースから削除
def delFileByID(con,item)
	path = LOCAL_FILE_LOCATION+item[:path].untaint;
	File.delete(path);
	res = con.exec("delete from file where id = #{item[:id]}")
	res.clear
end

##############################
## Post関連のSQL処理
##############################

def addPost(con,fileid,username,password,posttext)
	res = con.exec("begin")
	res.clear
	fileid.gsub!(/['"]/) {|ch| ch + ch }
	username.gsub!(/['"]/) {|ch| ch + ch }
	password.gsub!(/['"]/) {|ch| ch + ch }
	posttext.gsub!(/['"]/) {|ch| ch + ch }
	#アップデート
	updatePostCntByID(con,fileid);
	res = con.exec(
		'insert into post (fileid,postid,username,password,posttext)'+
		"values('#{fileid}',(select count(*) from post where fileid = #{fileid})+1,'#{username}','#{password}','#{posttext}')"
	);
	res.clear
	res = con.exec("end")
	res.clear
end

def updatePostCntByID(con,id)
	res = con.exec("update file set postcnt = postcnt+1, lastposted = date_trunc('sec',current_timestamp) where id = #{id}")
	res.clear
end

def selectPostAll(con,fileid = nil,limit = nil)
	#準備する
	res = con.exec("begin")
	res.clear
	sql = "declare cur_post cursor for select * from post"
	if limit == nil && fileid == nil
	else
		if fileid != nil
			sql << " where fileid=#{fileid} order by postid"
		else
			sql << ' order by posted DESC'
		end
		if limit != nil
			sql << " limit #{limit}"
		end
	end
	res = con.exec(sql)
	res.clear
	running = true
	index = nil;
	cnt = 0;
	if !(defined? yield)
		posts_items = [];
	end
	while running
		#フェッチ
		res = con.exec("fetch forward 20 in cur_post")
		if defined? yield
			index = loopQuery(res,index){|item|
				yield(item)
				cnt += 1;
			}
			ret = cnt;
		else
			index = loopQuery(res,index){|item|
				posts_items << item
			}
			ret = posts_items;
		end
		res.clear
		running &= index != nil;
	end
	#終了
	res = con.exec("close cur_post")
	res.clear
	res = con.exec("end")
	res.clear
	return ret;
end

def selectPostByID(con,id = nil)
	if id == nil
		res = con.exec("select * from post order by id desc limit 1")
	else
		res = con.exec("select * from post where id = #{id} order by id desc limit 1")
	end
	if res.num_tuples != 1
		ret = nil;
	else
		ret = {};
		fields = res.fields;
		for i in 0..res.num_fields-1
			ret[fields[i].untaint.to_sym] = res.getvalue(0,i);
		end
		ret.freeze;
	end
	res.clear
	return ret;
end

def delPostByID(con,file_id,post_id)
	res = con.exec("update post set erased = 't', lastmodified = date_trunc('sec',current_timestamp) where id = #{post_id}")
	res.clear
	res = con.exec("update file set postcnt = postcnt-1, lastposted = date_trunc('sec',current_timestamp) where id = #{file_id}")
	res.clear
end
