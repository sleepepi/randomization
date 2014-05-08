class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    @email_to = system_admin.email
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def status_activated(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email,
         subject: "#{user.name}'s Account Activated")
  end

  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.user.email
    mail(to: project_user.user.email,
         subject: "#{project_user.creator.name} Allows You to View Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def invite_user_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.invite_email
    mail(to: project_user.invite_email,
         subject: "#{project_user.creator.name} Invites You to View Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def subject_randomized(assignment, user)
    setup_email
    @assignment = assignment
    @user = user
    @email_to = user.email
    mail(to: user.email,
         subject: "#{assignment.user.name} Randomized A Subject to #{assignment.treatment_arm} on #{assignment.project.name}",
         reply_to: assignment.user.email)
  end

  protected

  def setup_email
    @footer_html = "<div style=\"color:#777\">Change #{DEFAULT_APP_NAME} email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a></div><br /><br />".html_safe
    @footer_txt = "Change #{DEFAULT_APP_NAME} email settings here: #{SITE_URL}/settings"
  end
end
