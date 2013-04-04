class CasesController < BaseController
  cache_sweeper :case_sweeper

  before_filter :require_user, :except => [:index, :show, :metadata, :embedded_pager, :export]
  before_filter :load_single_resource, :only => [:show, :edit, :update, :destroy, :export, :approve]
  before_filter :store_location, :only => [:index, :show]

  # Only admin can edit cases - they must remain pretty much immutable, otherwise annotations could get
  # messed up in terms of location.

  access_control do
    allow all, :to => [:show, :index, :metadata, :autocomplete_tags, :new, :create, :embedded_pager, :export]
    allow :owner, :of => :case, :to => [:destroy, :edit, :update]
    allow :case_admin, :admin, :superadmin
  end

  def autocomplete_tags
    render :json => Case.autocomplete_for(:tags,params[:tag])
  end

  def metadata
    #FIXME
  end

  def embedded_pager
    super Case
  end

  # GET /cases
  def index
    common_index Case
  end

  # GET /cases/1
  def show
    add_javascripts 'cases'
    set_belongings Case

    if !@case.public || !@case.active
      flash[:notice] = "This case is not public or active."
      redirect_to cases_url
    end
  end

  def export
    render :layout => 'print'
  end

  def approve
    @case.approve!
    Notifier.deliver_case_notify_approved(@case)
    render :json => {}
  end
  
  # GET /cases/new
  def new
    @case = Case.new
    if params.has_key?(:case_request_id)
      case_request = CaseRequest.find(params[:case_request_id])
      @case.case_request = case_request

      [:full_name, :decision_date, :author, :case_jurisdiction].each do |f|
        @case.send("#{f}=", case_request.send(f))
      end
      case_docket_number = CaseDocketNumber.new(:docket_number => case_request.docket_number)
      @case.case_docket_numbers = [case_docket_number]
      @case.case_citations << CaseCitation.new(:reporter => case_request.reporter, 
                                               :volume => case_request.volume,
                                               :page => case_request.page)
    else
      @case.case_jurisdiction = CaseJurisdiction.new
    end

    add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'cases']
    add_stylesheets ['new_case']
  end

  # GET /cases/1/edit
  def edit
    add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'cases']
    add_stylesheets ['new_case']
  end

  # POST /cases
  def create
    unless params[:case][:tag_list].blank?
      params[:case][:tag_list] = params[:case][:tag_list].downcase
    end
    @case = Case.new(params[:case])

    add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'cases']
    add_stylesheets ['new_case']

    if @case.save
      @case.accepts_role!(:owner, current_user)
      @case.accepts_role!(:creator, current_user)
      @case.case_request.approve! if @case.case_request
      if @case.active
        Notifier.deliver_case_notify_approved(@case)
        flash[:notice] = 'Case was successfully created.'
        redirect_to "/cases/#{@case.id}"
      else
        flash[:notice] = 'Case was successfully created. It must be approved before it is visible.'
        redirect_to cases_url
      end
    else
      render :action => "new"
    end
  end

  # PUT /cases/1
  def update
    # This is not industrial level security - a user could theoretically overwrite the case content of a case they own via URL tampering.
    unless params[:case][:tag_list].blank?
      params[:case][:tag_list] = params[:case][:tag_list].downcase
    end
    add_javascripts ['tiny_mce/tiny_mce.js', 'h2o_wysiwig', 'switch_editor', 'cases']
    add_stylesheets ['new_case']

    if @case.update_attributes(params[:case])
      if @case.active
        Notifier.deliver_case_notify_updated(@case)
        flash[:notice] = 'Case was successfully updated.'
        redirect_to "/cases/#{@case.id}"
      else
        flash[:notice] = 'Case was successfully updated. It must be approved before it is visible.'
        redirect_to "/users/#{current_user.id}\#p_pending_cases"
      end
    else
      render :action => "edit"
    end
  end

  # DELETE /cases/1
  def destroy
    Notifier.deliver_case_notify_rejected(@case)
    @case.destroy
    render :json => {}
  end
end
