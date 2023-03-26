module HashArray
  @local_hrefs = {}
  @global_hrefs = {}

  def add_link_for_page(page_path, href, hash)
    hash[page_path] = [] if hash[page_path].nil?
    pre_existing = hash[page_path].find { |h| h.path == href.path }
    if pre_existing
      @logger.warn "HRef tags for '#{href.path}' have inconsistent 'follow' keyword options" if pre_existing.follow != href.follow
    else
      hash[page_path] << href
    end
  end

  def add_local_link_for_page(page_path, href)
    add_link_for_page(page_path, href, HashArray.instance_variable_get(:@local_hrefs))
  end

  def add_global_link_for_page(page_path, href)
    add_link_for_page(page_path, href, HashArray.instance_variable_get(:@global_hrefs))
  end

  module_function :add_link_for_page, :add_local_link_for_page, :add_global_link_for_page
  public :add_local_link_for_page, :add_global_link_for_page
end
