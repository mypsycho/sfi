
insert into groups_users (group_id, user_id)
  select g.id, u.id
  from groups g, users u
  where g.name='sonar-administrators'
    and u.login='${sfi.sonar.admin.uid}' 
    and not exists (
	  select 1 
	  from groups_users gu 
	  where g.id = gu.group_id and u.id = gu.user_id
	)
