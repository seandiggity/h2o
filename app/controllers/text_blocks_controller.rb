class TextBlocksController < BaseController
  cache_sweeper :text_block_sweeper

  before_filter :require_user, :except => [:index, :show, :metadata, :embedded_pager, :export]
  before_filter :load_text_block, :only => [:show, :edit, :update, :destroy, :export]
  before_filter :store_location, :only => [:index, :show]

  before_filter :create_brain_buster, :only => [:new]
  before_filter :validate_brain_buster, :only => [:create]
  before_filter :restrict_if_private, :only => [:show, :edit, :update, :destroy, :embedded_pager, :export]
  access_control do
    allow all, :to => [:show, :index, :metadata, :autocomplete_tags, :new, :create, :embedded_pager, :export]
    allow :text_block_admin, :admin, :superadmin
    allow :owner, :of => :text_block, :to => [:destroy, :edit, :update]
  end

  def show
    add_stylesheets 'text_blocks'
  end

  def export
    render :layout => 'print'
  end

  # GET /text_blocks/1/edit
  def edit
    add_javascripts ['visibility_selector', 'new_text_block', 'tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor']
    add_stylesheets ['new_text_block']

    if @text_block.metadatum.blank?
      @text_block.build_metadatum
    end
  end

  def metadata
    #FIXME
  end

  def embedded_pager
    super TextBlock
  end

  # GET /text_blocks/new
  # GET /text_blocks/new.xml
  def new
    add_javascripts ['visibility_selector', 'new_text_block', 'tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor']
    add_stylesheets ['new_text_block']

    @text_block = TextBlock.new
    @text_block.build_metadatum
    @journal_article = JournalArticle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @text_block }
    end
  end

  def create
    unless params[:text_block][:tag_list].blank?
      params[:text_block][:tag_list] = params[:text_block][:tag_list].downcase
    end

    @text_block = TextBlock.new(params[:text_block])
    @journal_article = JournalArticle.new

    if @text_block.save
      @text_block.accepts_role!(:owner, current_user)
      @text_block.accepts_role!(:creator, current_user)
      flash[:notice] = 'Text Block was successfully created.'
      redirect_to "/text_blocks/#{@text_block.id}"
    else
      add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'new_text_block']
      add_stylesheets ['new_text_block']

      @text_block.build_metadatum
      render :action => "new"
    end
  end

  def build_search(params)
    text_blocks = Sunspot.new_search(TextBlock, JournalArticle)
    
    text_blocks.build do
      if params.has_key?(:keywords)
        keywords params[:keywords]
      end
      if params[:tags]
        if params[:any]
          any_of do
            params[:tags].each { |t| with :tag_list, t }
          end
        else
          params[:tags].each { |t| with :tag_list, t }
        end
      end
      if params[:tag]
        with :tag_list, CGI.unescape(params[:tag])
      end
      with :public, true
      with :active, true
      paginate :page => params[:page], :per_page => 25
      order_by params[:sort].to_sym, params[:order].to_sym
    end
    text_blocks.execute!
    text_blocks
  end

  # GET /text_blocks
  # GET /text_blocks.xml
  def index
    @page_title = "Text Blocks | H2O Classroom Tools"

    params[:page] ||= 1

    if params[:keywords]
      text_blocks = build_search(params)
      t = text_blocks.hits.inject([]) { |arr, h| arr.push(h.result); arr }
      @text_blocks = WillPaginate::Collection.create(params[:page], 25, text_blocks.total) { |pager| pager.replace(t) }
    else
      @text_blocks = Rails.cache.fetch("text_blocks-search-#{params[:page]}-#{params[:tag]}-#{params[:sort]}-#{params[:order]}") do 
        text_blocks = build_search(params)
        t = text_blocks.hits.inject([]) { |arr, h| arr.push(h.result); arr }
        { :results => t, 
          :count => text_blocks.total }
      end
      @text_blocks = WillPaginate::Collection.create(params[:page], 25, @text_blocks[:count]) { |pager| pager.replace(@text_blocks[:results]) }
    end

    if current_user
      @my_text_blocks = current_user.text_blocks
      @my_bookmarks = current_user.bookmarks_type(TextBlock, ItemTextBlock)
      @is_text_block_admin = current_user.is_text_block_admin
    else
      @my_text_blocks = @my_bookmarks = []
      @is_text_block_admin = false
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          @view = "text_block"
          @collection = @text_blocks
          render :partial => 'shared/generic_block'
        else
          render 'index'
        end
      end
      format.xml  { render :xml => @text_blocks }
    end
  end

  def autocomplete_tags
    render :json => TextBlock.autocomplete_for(:tags,params[:tag])
  end

  def update
    unless params[:text_block][:tag_list].blank?
      params[:text_block][:tag_list] = params[:text_block][:tag_list].downcase
    end

    if @text_block.update_attributes(params[:text_block])
      flash[:notice] = 'Text Block was successfully updated.'
      redirect_to "/text_blocks/#{@text_block.id}"
    else
      add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'new_text_block']
      add_stylesheets ['new_text_block']
      render :action => "edit"
    end
  end

  # DELETE /text_blocks/1
  # DELETE /text_blocks/1.xml
  def destroy
    @text_block.destroy
    respond_to do |format|
      format.html { redirect_to(text_blocks_url) }
      format.xml  { head :ok }
      format.json { render :json => {} }
    end
  end

  def render_or_redirect_for_captcha_failure
    add_javascripts ['new_text_block', 'tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor']
    add_stylesheets ['new_text_block']

    @text_block = TextBlock.new(params[:text_block])
    @text_block.build_metadatum
    @text_block.valid?
    @journal_article = JournalArticle.new
    create_brain_buster
    render :action => "new"
  end

  private 

  def load_text_block
    @text_block = TextBlock.find((params[:id].blank?) ? params[:text_block_id] : params[:id])
    @page_title = @text_block.name
  end
end
