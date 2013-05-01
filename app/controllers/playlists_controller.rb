require 'net/http'
require 'uri'

class PlaylistsController < BaseController

  include PlaylistUtilities
  
  cache_sweeper :playlist_sweeper
  caches_page :show, :export, :if => Proc.new{|c| c.instance_variable_get('@playlist').public?}

  # TODO: Investigate whether this can be updated to :only => :index, since access_level is being called now
  before_filter :load_single_resource, :except => [:embedded_pager, :index, :destroy, :check_export]
  before_filter :require_user, :except => [:embedded_pager, :show, :index, :export, :access_level, :check_export, :playlist_lookup]
  before_filter :store_location, :only => [:index, :show]
  before_filter :restrict_if_private, :except => [:embedded_pager, :index, :new, :create, :destroy]

  access_control do
    allow all, :to => [:embedded_pager, :show, :index, :export, :access_level, :check_export, :position_update]
    allow logged_in, :to => [:new, :create, :copy, :prepare_copy]

    allow logged_in, :to => [:notes], :if => :allow_notes?
    allow logged_in, :to => [:edit, :update], :if => :allow_edit?

    allow :admin, :playlist_admin, :superadmin
    allow :owner, :of => :playlist
  end

  def allow_notes?
    load_single_resource

    current_user.can_permission_playlist("edit_notes", @playlist)
  end

  def allow_edit?
    load_single_resource

    current_user.can_permission_playlist("edit_descriptions", @playlist)
  end

  def embedded_pager
    super Playlist
  end

  def access_level 
    session[:return_to] = "/playlists/#{@playlist.id}"
    if current_user
      can_edit = @playlist.admin? || @playlist.owner?
      can_position_update = can_edit || current_user.can_permission_playlist("position_update", @playlist)
      can_edit_notes = can_edit || current_user.can_permission_playlist("edit_notes", @playlist)
      can_edit_desc = can_edit || current_user.can_permission_playlist("edit_descriptions", @playlist)
      notes = can_edit_notes ? @playlist.playlist_items : @playlist.playlist_items.select { |pi| !pi.public_notes }
      render :json => {
        :logged_in            => current_user.to_json(:only => [:id, :login]),
        :can_edit             => can_edit,
        :notes                => can_edit_notes ? notes.to_json(:only => [:id, :notes, :public_notes]) : "[]",
        :playlists            => current_user.playlists.to_json(:only => [:id, :name]),
        :can_position_update  => can_position_update,
        :can_edit_notes       => can_edit_notes,
        :can_edit_desc        => can_edit_desc }
    else
      render :json => {
        :logged_in            => false,
        :can_edit             => false,
        :notes                => [],
        :playlists            => [],
        :can_position_update  => false,
        :can_edit_notes       => false,
        :can_edit_desc        => false }
    end
  end

  def index
    common_index Playlist
  end

  # GET /playlists/1
  def show
    add_javascripts ['playlists', 'jquery.tipsy', 'jquery.nestable']
    add_stylesheets ['playlists']

    @owner = @playlist.owners.first
    @author_playlists = @playlist.owners.first.playlists.paginate(:page => 1, :per_page => 5)
    @can_edit = current_user && (@playlist.admin? || @playlist.owner?)
    @parents = Playlist.find(:all, :conditions => { :id => @playlist.relation_ids })
    (@shown_words, @total_words) = @playlist.collage_word_count
  end

  def check_export
    cgi = request.query_parameters.delete_if { |k, v| k == "_" }.to_query
    clean_cgi = CGI.escape(cgi)
    if FileTest.exists?("#{RAILS_ROOT}/tmp/cache/playlist_#{params[:id]}.pdf?#{clean_cgi}")
      render :json => {}, :status => 200
    else
      render :json => {}, :status => 404
    end
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
    @can_edit_all = @can_edit_desc = true
  end

  def edit
    if current_user
      @can_edit_all = current_user.has_role?(:superadmin) ||
                      current_user.has_role?(:admin) || 
                      current_user.has_role?(:owner, @playlist)
      @can_edit_desc = @can_edit_all || current_user.can_permission_playlist("edit_descriptions", @playlist)
    else
      @can_edit_all = @can_edit_desc = false
    end
  end

  # POST /playlists
  def create
    @playlist = Playlist.new(params[:playlist])

    @playlist.title = @playlist.name.downcase.gsub(" ", "_") unless @playlist.title.present?

    if @playlist.save

      # If save then assign role as owner to object
      @playlist.accepts_role!(:owner, current_user)
      @playlist.accepts_role!(:creator, current_user)

      #IMPORTANT: This reindexes the item with author set
      @playlist.index!

      render :json => { :type => 'playlists', :id => @playlist.id }
    else
      render :json => { :type => 'playlists', :id => @playlist.id }
    end
  end

  # PUT /playlists/1
  def update
    if current_user
      can_edit_all = current_user.has_role?(:superadmin) ||
                      current_user.has_role?(:admin) || 
                      current_user.has_role?(:owner, @playlist)
      can_edit_desc = can_edit_all || current_user.can_permission_playlist("edit_descriptions", @playlist)
    else
      can_edit_all = can_edit_desc = false
    end
    if !can_edit_all
      params["playlist"].delete("name")  
      params["playlist"].delete("tag_list")  
    end

    if @playlist.update_attributes(params[:playlist])
      render :json => { :type => 'playlists', :id => @playlist.id }
    else
      render :json => { :type => 'playlists', :id => @playlist.id }
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    render :json => { :success => true }
  rescue Exception => e
    render :json => { :success => false, :error => "Could not delete #{e.inspect}" }
  end

  def prepare_copy
    @playlist = Playlist.find(params[:id])
  end

  def copy
    @playlist = Playlist.find(params[:id])  
    @playlist_copy = Playlist.new(params[:playlist])
    @playlist_copy.parent = @playlist

    if @playlist_copy.title.blank?
      @playlist_copy.title = params[:playlist][:name] 
    end

    if @playlist_copy.save
      @playlist_copy.accepts_role!(:owner, current_user)
      @playlist.creators && @playlist.creators.each do|c|
        @playlist_copy.accepts_role!(:original_creator,c)
      end
      @playlist_copy.playlist_items << @playlist.playlist_items.collect { |item| 
        new_item = item.clone
        new_item.resource_item = item.resource_item.clone
        item.creators && item.creators.each do|c|
          new_item.accepts_role!(:original_creator,c)
        end
        new_item.accepts_role!(:owner, current_user)
        new_item.playlist_item_parent = item
        new_item
      }

      create_influence(@playlist, @playlist_copy)
      flash[:notice] = "Your copy is below. Cheers!"

      render :json => { :type => 'playlists', :id => @playlist_copy.id } 
    else
      render :json => { :type => 'playlists', :id => @playlist_copy.id }, :status => :unprocessable_entity 
    end
  end

  def url_check
    return_hash = Hash.new
    test_url = params[:url_string]
    return_hash["url_string"] = test_url
    return_hash["description_string"]

    uri = URI.parse(test_url)

    object_hash = identify_object(test_url,uri)

    return_hash["host"] = uri.host
    return_hash["port"] = uri.port
    return_hash["type"] = object_hash["type"]
    return_hash["body"] = object_hash["body"]

    render :json => return_hash.to_json
  end

  def position_update
    can_position_update = @playlist.admin? || @playlist.owner? || current_user.can_permission_playlist("position_update", @playlist)

    if !can_position_update
      # TODO: Add permissions message here
      render :json => {}
      return
    end

    playlist_order = (params[:playlist_order].split("&"))
    playlist_order.collect!{|x| x.gsub("playlist_item[]=", "")}
     
    playlist_order.each_index do |item_index|
      PlaylistItem.update(playlist_order[item_index], :position => item_index + 1)
    end

    return_hash = @playlist.playlist_items.inject({}) { |h, i| h[i.id] = i.position.to_s; h }

    render :json => return_hash.to_json
  end

  def export
    render :layout => 'print'
  end

  def notes
    value = params[:type] == 'public' ? true : false
    @playlist.playlist_items.each { |pi| pi.update_attribute(:public_notes, value) } 

    render :json => {} 
  end

  def playlist_lookup
    render :json => { :items => @current_user.playlists.collect { |p| { :display => p.name, :id => p.id } } }
  end

end
