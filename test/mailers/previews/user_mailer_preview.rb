class UserMailerPreview < ActionMailer::Preview

  def notify_system_admin
    system_admin = User.current.first
    user = User.current.first
    UserMailer.notify_system_admin(system_admin, user)
  end

  def status_activated
    user = User.current.first
    UserMailer.status_activated(user)
  end

  def user_added_to_project
    project_user = ProjectUser.where.not( invite_email: nil ).first
    UserMailer.user_added_to_project(project_user)
  end

  def invite_user_to_project
    project_user = ProjectUser.where.not( invite_email: nil ).first
    UserMailer.invite_user_to_project(project_user)
  end

  def subject_randomized
    assignment = Assignment.first
    user = User.current.first
    UserMailer.subject_randomized(assignment, user)
  end

end
