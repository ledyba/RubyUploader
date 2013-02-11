#インクルード
require 'mysql'

##############################
## File関連のSQL処理
##############################
def SQL_init()
	MySQL::connect('localhost', 'postgres', '', 'uploader') 
end

def selectFile(con,offset = 0,word = nil,size = UPLOADER_FILE_PER_PAGE)
	cnt = 0;
	if word == nil || word == ""
		con.query("select * from file order by id desc offset #{offset} limit #{size}") {|rows|
			rows.each_hash{|item|
				yield(item);
				cnt += 1;
			}
		}
	else
		sql = "select * from file where "
		#なぜか一度置換する必要があるようだ…。
		word_cnt = 0;
		word.sub('　',' ').split(/\s/).each{
			item = MySQL::escape_string(item)
			if word_cnt != 0
				sql += " and "
			end
			sql += "(desctext like '%#{item}%' or orig_name like '%#{item}%' or username like '%#{item}%')"
			word_cnt+=1;
		}
		sql += " order by id desc offset #{offset} limit #{size}";
		con.query(sql){|rows|
			if defined? yield
				cnt = 0;
				rows.each_hash{|item|
					yield(item)
					cnt += 1;
				}
				return cnt;
			else
				ret_items = [];
				rows.each_hash{|item|
					ret_items << item
				}
				return ret_items
			end
		}
	end
end

def selectFileByID(con,id)
	ret = nil;
	res = con.query("select * from file where id = #{id} order by id desc limit 1"){|res|
		if res.num_rows == 1
			res.each_hash{|item|
				ret = item;
			}
			ret.freeze;
		end
	}
	return ret;
end

def updateDownCntByID(con,id)
	con.query("update file set downcnt = downcnt +1, lastdownloaded = current_timestamp() where id = #{id}"){|item|}
end

#データベースからすべて選択する
def selectFileAll(con,word = nil,size = UPLOADER_FILE_PER_PAGE)
	#準備する
	con.query("begin"){|res|}
	if word == nil
		con.query("declare cur_file cursor for select * from file order by id desc"){|res|}
	else
		sql = "declare cur_file cursor for select * from file where "
		cnt = 0;
		#なぜか一度置換する必要があるようだ…。
		word.sub('　',' ').split(/\s/).each{|item|
			item = MySQL::escape_string(item)
			if cnt != 0
				sql += " and "
			end
			sql += "(desctext like '%#{item}%' or orig_name like '%#{item}%' or username like '%#{item}%')"
			cnt+=1;
		}
		sql += " order by id desc";
		con.query(sql){|res|};
	end
	running = true
	index = nil;
	cnt = 0;
	while running
		#フェッチ
		now_cnt = 0;
		con.query("fetch forward #{size} in cur_file"){|res|
			res.each_hash{|item|
				yield(item)
				cnt += 1;
				now_cnt += 1;
			}
		}
		running = (now_cnt > 0);
	end
	#終了
	con.query("close cur_file"){|res|}
	res.query("end"){|res|}
	return cnt;
end

#データベースに追加する
def addFile(con,path,content_type,orig_name,size,desc,username,pass)
	con.query(
		'insert into file (path,orig_name,content_type,desctext,username,password,size)'+
		"values('#{MySQL::escape_string path}','#{MySQL::escape_string orig_name}','#{MySQL::escape_string content_type}','#{MySQL::escape_string desc}','#{MySQL::escape_string username}','#{MySQL::escape_string pass}',#{size})"
	){|res|};
end

#データベースから削除
def delFileByID(con,item)
	path = LOCAL_FILE_LOCATION+item[:path].untaint;
	File.delete(path);
	con.query("delete from file where id = #{item[:id]}"){|res|};
end

##############################
## Post関連のSQL処理
##############################

def addPost(con,fileid,username,password,posttext)
	con.query("begin"){|res|}
	#アップデート
	updatePostCntByID(con,fileid);
	con.query(
		'insert into post (fileid,postid,username,password,posttext)'+
		"values('#{MySQL::escape_string fileid}',(select count(*) from post where fileid = #{MySQL::escape_string fileid}),'#{MySQL::escape_string username}','#{MySQL::escape_string password}','#{MySQL::escape_string posttext}')"
	){|res|};
	con.query("end"){|res|}
end

def selectPostAll(con,fileid = nil,limit = nil)
	#準備する
	con.query("begin"){|res|}
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
	con.query("sql"){|res|}
	running = true
	index = nil;
	cnt = 0;
	if !(defined? yield)
		posts_items = [];
	end
	while running
		now_cnt = 0;
		if defined? yield
			con.query("fetch forward 20 in cur_post"){|res|
					res.each_hash{|item|
					yield(item)
					cnt++
					now_cnt += 1;
				}
			}
			ret = cnt;
		else
			con.query("fetch forward 20 in cur_post"){|res|
				res.each_hash{|item|
					posts_items << item
					now_cnt += 1;
				}
			}
			ret = posts_items;
		end
		running = now_cnt > 0;
	end
	#終了
	con.query("close cur_post"){|res|}
	con.query("end"){|res|}
	return cnt;
end

def updatePostCntByID(con,id)
	con.query("update file set postcnt = postcnt +1, lastposted = current_timestamp() where id = #{id}"){|item|}
end

def selectPostByID(con,id = nil)
	ret = nil;
	con.query(id == nil ? "select * from post order by id desc limit 1" : "select * from post where id = #{id} order by id desc limit 1"){|res|
		if res.num_rows == 1
			res.each_hash{|item|
				ret = item;
			}
		end
	}
	return ret;
end

def delPostByID(con,file_id,post_id)
	con.query("update post set erased = 't', lastmodified = current_timestamp() where id = #{post_id}")
	con.query("update file set postcnt = postcnt-1, lastposted = current_timestamp() where id = #{file_id}")
end
