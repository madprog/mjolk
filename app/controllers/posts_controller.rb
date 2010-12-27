require 'xmlsimple'

class PostsController < ApplicationController
  # auth needed !
  before_filter :authenticate_user!

  def index
    # building conditions
    conditions = Array.new
    if params[:fromdt]
      conditions[0] = "bookmarked_at >= ?"
      conditions << DateTime.parse(params[:fromdt])
    end
    if params[:todt]
      conditions[0] += " AND " if params[:fromdt]
      conditions[0] += "bookmarked_at <= ?"
      conditions << DateTime.parse(params[:todt])
    end
    if params[:tag]
      @posts = current_user.bookmarks.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || -1), :conditions => conditions, :order => "bookmarked_at DESC")
    else  
      @posts = current_user.bookmarks.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || -1), :conditions => conditions, :order => "bookmarked_at DESC")
    end
    respond_to do |format|
      format.html
      format.xml do
        xml_posts = Array.new
        @posts.each do |post|
          tags = Array.new
          post.tags.each { |t| tags << t.name }
          xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
        end
        posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :hash => post.meta, :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
        xml_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + XmlSimple.xml_out(posts).gsub("opt","posts")
        render :xml => xml_output
      end
    end
  end

  def new
    @bookmark = Bookmark.new
  end

  # also respond to posts/add
  # implemented : url (req), description (req), tags, dt, shared
  # not implemented : replace, extended
  def create
    incomplete = true
    error = false
    if ((params[:url] != nil) &&( (params[:description] != nil ) || (params[:bookmark]["title"] != nil )))
      incomplete = false
      url = nil
      if params[:url][:url]
        url = params[:url][:url]
      else
        url = params[:url]
      end
      if not (url =~ /^http:\/\//)
        url = "http://" + url
      end
      link = Link.find_by_url(url) || Link.new(:url => url)
      link.save
      if link.users.include?(current_user)
        # already in
      else
        datetime = nil
        datetime = params[:dt] if params[:dt]
        description = params['description'] || params[:bookmark]['title']
        new_bookmark = Bookmark.new(:title => description, :link_id => link.id, :user_id => current_user.id, :bookmarked_at => (datetime || Time.now))
        new_bookmark.private = true if (params[:shared] && (params[:shared] == "no"))
        new_bookmark.tag_list = params['tags'] || params[:bookmark]['tags']
        if new_bookmark.save
          logger.info("bookmark for #{url} added")
        else
          error = true
          logger.warn("Error : could not save the new bookmark")
        end
      end
    end
    respond_to do |format|
      format.html do
        if incomplete || error
          flash[:error] = "incomplet"
          render :file => File.join(Rails.root, 'public', '400.html'), :status => 400
        else
          redirect_to :action => "index"
        end
      end
      format.xml do
        if incomplete || error
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"done\" />"
        end
      end
    end
  end

  def destroy
    error = false
    if params[:url]
      link = Link.find_by_url(params[:url]) || nil
      if link.users.include(current_user)
        bookmark = current_user.bookmarks.find(:all, :conditions => ["link_id = ?", link.id])
        bookmark.destroy
        link.destroy if link.bookmarks.size == 0 # destroy the link if no bookmarks are left
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.xml do
        if error
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"done\" />"
        end
      end
    end
  end

  # to fix
  def import
    if params[:file]
      # using hpricot to read
      xml_stuff = nil
      begin
        xml_stuff = Hpricot(params[:file])
      rescue
        logger.info("Hpricot doesn't like this. this is not xml")
      end
      if xml_stuff
        if (((xml_stuff/"posts") != nil) && ((xml_stuff/"posts").size > 0)) # hooray delicious format ?
          (xml_stuff/"posts").each do |post|
            
            # let's check if the url is already in the db
            # but first we need to check if there is http:// in there
            url = post["href"]
            if post["href"] =~ /^http:\/\//
            else
              url = "http://" + post["href"]
            end
            link = Link.find_by_url(url) || nil
            # not found must create
            if !link
              link = Link.new(:url => url)
            end


            # now taking care of the bookmark
            if link.users.include?(current_user)
              # already in
            else
              new_bookmark = Bookmark.new(:title => post['description'], :link => link)
              new_bookmark.tag_list = post['tag'].gsub(" ",", ")
              current_user.bookmarks << new_bookmark
              new_bookmark.save
            end 
          end
        end
      end
      redirect_to :action => 'index'
    else
      redirect_to login_path
    end
  end

  private
  def check_api
    if current_user && current_user.api_key == params[:api_key]
      return true
    end
    return false
  end
end
