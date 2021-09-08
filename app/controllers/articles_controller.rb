class ArticlesController < ApplicationController
  impressionist :actions=> [:show], unique: [:ip_address]
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def index
    @articles = Article.page(params[:page]).per(5).order(created_at: :DESC)

  end

  def show
    @article = Article.find(params[:id])
    impressionist(@article, nil, unique: [:ip_address])
  end

  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.new(article_params)
    if @article.save
      redirect_to articles_path, notice: "募集を投稿しました"
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @article.update(article_params)
      redirect_to article_path(@article), notice: "編集が完了しました"
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "削除が完了しました"
  end

  private
    def article_params
      params.require(:article).permit(:title, :content, :area, :category)
    end

    def ensure_correct_user
      @article = Article.find(params[:id])
      if @article.user_id != current_user.id
        redirect_to articles_path
      end
    end
end
