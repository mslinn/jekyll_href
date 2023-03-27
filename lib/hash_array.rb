module HashArray
  def reset
    @local_hrefs = {}
    @global_hrefs = {}
  end

  def add_link_for_page(href, hash)
    enclosing_page = href.path
    hash[enclosing_page] = [] if hash[enclosing_page].nil?
    pre_existing = hash[enclosing_page].find { |h| h.link == href.link }
    if pre_existing
      if pre_existing.follow != href.follow
        @logger.warn "HRef tags for '#{href.link}' have inconsistent 'follow' keyword options on line #{href.line_number} of page #{enclosing_page}"
      end
    else
      hash[enclosing_page] << href unless href.summary_exclude
    end
  end

  def add_local_link_for_page(href)
    add_link_for_page(href, HashArray.instance_variable_get(:@local_hrefs))
  end

  def add_global_link_for_page(href)
    add_link_for_page(href, HashArray.instance_variable_get(:@global_hrefs))
  end

  module_function :add_link_for_page, :add_local_link_for_page, :add_global_link_for_page, :reset
  public :add_local_link_for_page, :add_global_link_for_page, :reset

  reset
end
