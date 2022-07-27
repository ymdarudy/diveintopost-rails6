class AssignMailer < ApplicationMailer
  default from: "from@example.com"

  def assign_mail(email, password)
    @email = email
    @password = password
    mail to: @email, subject: I18n.t("views.messages.complete_registration")
  end

  def owner_mail(team)
    @team = team
    mail to: @team.owner.email, subject: "リーダー権限移動"
  end
end
