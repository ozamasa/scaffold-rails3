class SamplesController < ApplicationController
  # GET /samples
  # GET /samples.xml
  def index
    @app_search.default 'id', 'asc'

    @app_search.sort 'id', 'samples.id'
    @app_search.sort 'name', 'samples.name'
    @app_search.sort 'kana', 'samples.kana'
    @app_search.sort 'url', 'samples.url'
    @app_search.sort 'updated', 'samples.updated_at'

    @app_search.query = "samples.id like ? or samples.name like ? or samples.zip like ? or samples.prefecture like ? or samples.address like ? or samples.building like ? or samples.kana like ? or samples.url like ? or samples.memo like ?"

    conditionquery  = @app_search.condition_query
#    conditionquery += " and " unless conditionquery.blank? or !params[:checkstop].blank?
    conditionparam  = @app_search.condition_keyword

    alls = Sample.all(
            :include => [],
            :conditions => [conditionquery] + conditionparam,
#            :conditions => @app_search.conditions,
#            :conditions => ["samples.name like ? or samples.cd like ? or samples.kana like ? or samples.url like ? or samples.memo like ? ", @app_search.keyword, @app_search.keyword, @app_search.keyword, @app_search.keyword, @app_search.keyword],
#            :conditions => [@app_search.condition_query] + @app_search.condition_keyword,
#            :conditions => [@app_search.condition_query + " and samples.name = ?"] + @app_search.condition_keyword << 'abc',
            :order => @app_search.orderby
           )
    @counter = alls.length
    @samples = alls.paginate(page: params[:page], per_page: PAGINATE_PER_PAGE)

    respond_to do |format|
      format.html # index.html.erb
      format.csv  { send_data(alls.to_csv(Sample), type: "text/csv") }
      format.xls  { send_data(alls.to_xls(Sample), type: "application/excel", disposition: "attachement", filename: "#{controller_name}#{Time.now.strftime('%Y%m%d%H%M%S')}.xls") }
      format.xml  { send_data(alls.to_xml,         type: "text/xml; charset=utf8;", disposition: "attachement") }
    end
  end

  # GET /samples/show
  # GET /samples/show.xml
  def show
    @sample = Sample.find(params[:id])
  end

  # GET /samples/new
  # GET /samples/new.xml
  def new
    @sample = Sample.new(params[:sample])
  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
    @sample.attributes = params[:sample]
  end

  # POST /samples
  # POST /samples.xml
  def create
    begin
      @sample = Sample.new(params[:sample])
      @sample.save!

      flash[:notice] = t(:success_created, id: @sample.id)
      redirect_to(samples_url)
#      redirect_to(action: :edit, id: @sample.id)
    rescue => e
      render action: :new
    end
  end

  # PUT /samples/1
  # PUT /samples/1.xml
  def update
    begin
      @sample = Sample.find(params[:id])
      @sample.attributes = params[:sample]
      @sample.save!

      flash[:notice] = t(:success_updated, id: @sample.id)
      redirect_to(action: :edit, id: @sample.id)
    rescue => e
      render action: :edit
    end
  end

  # POST /samples
  # POST /samples.xml
  def upload
    upload_file = ApplicationUpload.new(params[:file])
    upload_msgs = upload_file.import(Sample)

    flash[:notice] = t(:success_imported, msg: upload_msgs) unless upload_msgs.blank?
    redirect_to(samples_url)
  end

  # DELETE /samples/1
  # DELETE /samples/1.xml
  def destroy
    begin
      @sample = Sample.find(params[:id])
      @sample.destroy

      Log.create(user_id: session[:user_id], action: controller_name, error: "#{action_name} #{params[:id]}")

      flash[:notice] = t(:success_deleted, id: @sample.id)
      redirect_to(samples_url)
    rescue => e
      flash[:error] = t(:error_default, message: e.message)
      render action: :show
    end
  end
end
