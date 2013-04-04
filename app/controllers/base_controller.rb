class BaseController < ApplicationController
  before_filter :store_location, :only => [:search, :index]

  def embedded_pager(model = nil)
    params[:page] ||= 1

    if params[:keywords].present?
      obj = model.nil? ? Sunspot.new_search(Playlist, Collage, Case, Media, TextBlock) : Sunspot.new_search(model)
      obj.build do
        keywords params[:keywords]
        paginate :page => params[:page], :per_page => 10 || nil
        order_by :score, :desc
      end
      obj.execute!
      t = obj.hits.inject([]) { |arr, h| arr.push([h.stored(:id), h.stored(:display_name), h.class_name.downcase, h.class_name == Media ? h.result.media_type.slug : h.class_name.downcase]); arr }
      @objects = WillPaginate::Collection.create(params[:page], 10, obj.total) { |pager| pager.replace(t) } 
    else
      cache_key = model.present? ? "#{model.to_s.tableize}-embedded-search-#{params[:page]}--display_name-asc" :
        "embedded-search-#{params[:page]}--display_name-asc"
      @objects = Rails.cache.fetch(cache_key) do
        obj = model.nil? ? Sunspot.new_search(Playlist, Collage, Case, Media, TextBlock) : Sunspot.new_search(model)
        obj.build do
          paginate :page => params[:page], :per_page => 10 || nil

          order_by :display_name, :asc
        end
        obj.execute!
        t = obj.hits.inject([]) { |arr, h| arr.push([h.stored(:id), h.stored(:display_name), h.class_name.downcase, h.class_name == "Media" ? "media-#{h.result.media_type.slug}" : h.class_name.downcase]); arr }
        { :results => t, :count => obj.total }
      end
      @objects = WillPaginate::Collection.create(params[:page], 10, @objects[:count]) { |pager| pager.replace(@objects[:results]) }
    end

    render :partial => 'shared/playlistable_item'
  end

  def partial_results
    per_page = 5
    params[:page] ||= 1

    if params[:type] == "playlists"
      playlists = []
      map = { "945" => "Copyright", "671" => "Criminal Law", "911" => "Music and Digital Media", "986" => "Torts" }
      [945, 671, 911, 986].each do |p|
        begin
          playlist = Playlist.find(p)
          playlists << { :title => map[p.to_s], :playlist => playlist, :user => playlist.owners.first } if playlist 
        rescue Exception => e
          Rails.logger.warn "Base#index Exception: #{e.inspect}"
        end
      end
      @highlighted_playlists = playlists.paginate(:page => params[:page], :per_page => per_page)
    elsif params[:type] == "users"
      @highlighted_users = User.find(:all, :conditions => "karma > 150 AND karma < 250", :order => "karma DESC").paginate(:page => params[:page], :per_page => per_page)
    elsif params[:type] == "author_playlists"
      @author_playlists = Playlist.find(params[:id]).owners.first.playlists.paginate(:page => params[:page], :per_page => per_page)
    end
        
    render :partial => "partial_results/#{params[:type]}"
  end

  def index
    per_page = 8

    @highlighted_playlists = []
    map = { "945" => "Copyright", "671" => "Criminal Law", "911" => "Music and Digital Media", "986" => "Torts" }
    [945, 671, 911].each do |p|
      begin
        playlist = Playlist.find(p)
        @highlighted_playlists << { :title => map[p.to_s], :playlist => playlist, :user => playlist.owners.first } if playlist 
      rescue Exception => e
        Rails.logger.warn "Base#index Exception: #{e.inspect}"
      end
    end
    Playlist.find(:all, :conditions => "karma IS NOT NULL", :order => "karma DESC", :limit => 5).each do |playlist|
      @highlighted_playlists << { :title => playlist.name, :playlist => playlist, :user => playlist.owners.first }
    end
    
    @highlighted_users = []
    [231, 322, 387].each do |u|
      begin
        user = User.find(u)
        @highlighted_users << user
      rescue Exception => e
        Rails.logger.warn "Base#index Exception: #{e.inspect}"
      end
    end
    User.find(:all, :conditions => "karma IS NOT NULL", :order => "karma DESC", :limit => 5).each do |user|
      @highlighted_users << user
    end
  end

  def search
    set_sort_params
    set_sort_lists
    params[:page] ||= 1

    @results = Sunspot.new_search(Playlist, Collage, Media, TextBlock, Case)
    @results.build do
      if params.has_key?(:keywords)
        keywords params[:keywords]
      end
      keywords params[:keywords]
      paginate :page => params[:page], :per_page => 25 
      with :public, true
      with :active, true
      order_by :score, :desc
      paginate :page => params[:page], :per_page => cookies[:per_page] || nil

      order_by params[:sort].to_sym, params[:order].to_sym
    end
    @results.execute!
    [Playlist, Collage, Case, Media, TextBlock].each do |model|
      set_belongings model
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'base/search_ajax' 
        else
          render 'search'
        end
      end
    end
  end

  def load_single_resource
    if params[:id].present?
      model = params[:controller] == "medias" ? Media : params[:controller].singularize.classify.constantize
      item = model.find(params[:id])
      if item.present?
        instance_variable_set "@#{model.to_s.tableize.singularize}", item
        @page_title = item.name
      end
    end
  end
end
