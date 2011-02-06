module ApplicationHelper
  def tag_cloud_limited(tags, classes, limit)
    tags = tags.all if tags.respond_to?(:all)

    return [] if tags.empty?

    max_count = tags.sort_by(&:count).last.count.to_f
    public_tags = Array.new
    tags.each do |tag|
      shared = false
      Bookmark.tagged_with(tag.name).all.each do |bookmark|
        shared = true if !bookmark.private?
      end
      public_tags << tag if shared
    end
    if limit > 0
      tags = public_tags.sort_by(&:count).last(limit).sort_by(&:name)
    else
      tags = public_tags.sort_by(&:count).sort_by(&:name)
    end

    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end
end
