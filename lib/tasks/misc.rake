# a rake task
namespace :misc do
  desc "Update bookmark privacy"
  task :private_update => :environment do
    Bookmark.all.each do |post|
      if post.private != 1
        post.private = 0
        post.save
      end
    end
  end

  desc "set default role if none"
  task :set_default_role => :environment do
    User.all.each do |user|
      if user.roles == nil
        user.roles = "guest"
        user.save
      end
    end
  end

  desc "get all short urls"
  task :get_shorts => :environment do
    Link.all.each do |l|
      l.shorten if l.short_url == nil
      if l.short_url
        Rails.logger.info("#{l.url} shorten to #{l.short_url}")
        l.save
      end
    end
  end

  desc "remove lost bookmarks"
  task :lost_bookmarks => :environment do
    Bookmark.all.each do |d|
      if d.user == nil
        d.destroy
      end
    end
  end
end