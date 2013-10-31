class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @app_search.default 'account', 'asc'

    @app_search.sort 'account', 'users.account'
    @app_search.sort 'name', 'users.name'
    @app_search.sort 'updated', 'users.updated_at'

    @app_search.query = "users.id like ? or users.account like ? or users.name like ? "

#    conditionquery  = @app_search.condition_query
#    conditionquery += " and " unless conditionquery.blank? or !params[:checkstop].blank?
#    conditionparam  = @app_search.condition_keyword

    alls = User.all(
#            include: [],
#            conditions: [conditionquery] + conditionparam,
            conditions: @app_search.conditions,
#            conditions: ["users.name like ? or users.cd like ? or users.kana like ? or users.url like ? or users.memo like ? ", @app_search.keyword, @app_search.keyword, @app_search.keyword, @app_search.keyword, @app_search.keyword],
#            conditions: [@app_search.condition_query] + @app_search.condition_keyword,
#            conditions: [@app_search.condition_query + " and users.name = ?"] + @app_search.condition_keyword << 'abc',
            order: @app_search.orderby
           )
    @counter = alls.length
    @users = alls.paginate(page: params[:page], per_page: PAGINATE_PER_PAGE)

    respond_to do |format|
      format.html
      format.csv  { send_data(alls.to_csv(Sample), type: "text/csv",                disposition: "attachement", filename: "#{controller_name}#{Time.now.strftime('%Y%m%d%H%M%S')}.csv") }
      format.xls  { send_data(alls.to_xls(Sample), type: "application/excel",       disposition: "attachement", filename: "#{controller_name}#{Time.now.strftime('%Y%m%d%H%M%S')}.xls") }
      format.xml  { send_data(alls.to_xml,         type: "text/xml; charset=utf8;", disposition: "attachement", filename: "#{controller_name}#{Time.now.strftime('%Y%m%d%H%M%S')}.xml") }
    end
  end

  # GET /users/show
  # GET /users/show.xml
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new(params[:user])
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    begin
      @user = User.new(params[:user])
      @user.password = params[:user][:account]
      @user.save!

      flash[:notice] = t(:success_created, id: @user.id)
      redirect_to(users_url)
#      redirect_to(action: :edit, id: @user.id)
    rescue => e
      render action: :new
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    begin
      @user = User.find(params[:id])
      @user.update_attribute(:name, params[:user][:name])
#      @user.attributes = params[:user]
#      @user.save!

      flash[:notice] = t(:success_updated, id: @user.id)
      redirect_to(action: :edit, id: @user.id)
    rescue => e
      render action: :edit
    end
  end

  # POST /users
  # POST /users.xml
  def upload
    upload_file = ApplicationUpload.new(params[:file])
    upload_msgs = upload_file.import(User)

    flash[:notice] = t(:success_imported, msg: upload_msgs) unless upload_msgs.blank?
    redirect_to(users_url)
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    begin
      @user = User.find(params[:id])
      @user.destroy

      Log.create(user_id: session[:user_id], action: controller_name, error: "#{action_name} #{params[:id]}")

      flash[:notice] = t(:success_deleted, id: @user.id)
      redirect_to(users_url)
    rescue => e
      flash[:error] = t(:error_default, message: e.message)
      render action: :show
    end
  end
end
