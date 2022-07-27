class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy change]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
    redirect_to team_path(@team), notice: "オーナー以外は編集不可！" unless current_user == @team.owner
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t("views.messages.create_team")
    else
      flash.now[:error] = I18n.t("views.messages.failed_to_save_team")
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t("views.messages.update_team")
    else
      flash.now[:error] = I18n.t("views.messages.failed_to_save_team")
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t("views.messages.delete_team")
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def change
    return unless current_user == @team.owner

    @team.invite_member(@team.owner)
    @team.owner.update(keep_team_id: nil)
    @team.update(owner_id: params[:user_id])
    User.find(params[:user_id]).update(keep_team_id: @team.id)
    Assign.where(team_id: @team.id, user_id: params[:user_id]).destroy_all

    AssignMailer.owner_mail(@team).deliver
    redirect_to request.referer, notice: "チームリーダーを変更しました！"
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
