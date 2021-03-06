class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :unsubscribe, :withdraw]

  def show
    @user = User.find(params[:id])
    @articles = @user.articles.page(params[:page]).per(5).order(created_at: :DESC)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      bypass_sign_in(@user) #更新時のログアウトを防ぐ
      redirect_to user_path(@user), notice: "プロフィールを更新しました"
    else
      render :edit
    end
  end

  def unsubscribe #退会確認画面
    @user = User.find(params[:id])
  end

  def withdraw #退会処理
    @user = User.find(params[:id])
    @user.update(is_deleted: true)
    reset_session
    redirect_to root_path
  end

  def follows
    @user = User.find(params[:id])
    @users = @user.followings.page(params[:page]).per(10)
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page]).per(10)
  end

  def my_answer
    @user = User.find(params[:id])
    answers = if params[:sort] == "old"
                @user.answers.includes([:theme]).order(created_at: :ASC)
              elsif params[:sort] == "rate"
                Answer.includes([:theme]).left_joins(:rates).where(user_id: @user.id).group(:id).order("SUM(rates.rate) DESC")
              else
                @user.answers.includes([:theme]).order(created_at: :DESC)
              end
    @answers = answers.page(params[:page]).per(5)    
  end

  def my_chart
    @user = User.find(params[:id])
    @score = Answer.joins(:rates, :user).group(:user_id).where(user_id: @user.id).select('answers.user_id, sum(rates.rate) as sum_rate')
    @counts = @user.rate_count #記述が長いためanswer.rbにメソッド定義
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :profile_image, :introduction)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to user_path(@user)
    end
  end
end
