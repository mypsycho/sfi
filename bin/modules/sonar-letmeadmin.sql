
insert into groups_users (group_id, user_id)
  select a.id, u.id
  from groups a, users u
  where a.name='sonar-administrators'
    and u.login='${sfi.sonar.admin.uid}' 
    and not exists (
	  select 1 
	  from groups_users gu 
	  where a.id = gu.group_id and u.id = gu.user_id
	)
