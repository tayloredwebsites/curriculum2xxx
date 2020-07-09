module UserTestHelper

  def setup_all_users
    setup_admin
    setup_unauthorized_user
    setup_teacher
    setup_public
  end

  def setup_unauthorized_user
    @unauth = FactoryBot.create(:user, roles: '')
    @unauth.update(:roles => '')
    @unauth.confirm # do a devise confirmation of new user
  end
  def setup_teacher
    @teacher = FactoryBot.create(:user, roles: "#{User::TEACHER_ROLE}")
    @teacher.confirm # do a devise confirmation of new user
  end
  def setup_requesting_teacher
    @req_teacher = FactoryBot.create(:user, roles: "#{User::REQ_TEACHER_ROLE}")
    @req_teacher.confirm # do a devise confirmation of new user
  end
  def setup_admin
    @admin = FactoryBot.create(:user, roles: "#{User::ADMIN_ROLE}")
    @admin.confirm # do a devise confirmation of new user
  end
  def setup_public
    @public = FactoryBot.create(:user, roles: "#{User::PUBLIC_ROLE}")
    @public.confirm # do a devise confirmation of new user
  end

end
