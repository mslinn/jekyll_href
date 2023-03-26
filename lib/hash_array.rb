module HashArray
  @local_hrefs = {}
  @global_hrefs = {}

  def add_link_for_page(page_path, link, hash)
    hash[page_path] = [] if hash[page_path].nil?
    hash[page_path] << link
  end

  def add_local_link_for_page(page_path, link)
    add_link_for_page(page_path, link, @local_hrefs)
  end

  def add_global_link_for_page(page_path, link)
    add_link_for_page(page_path, link, @global_hrefs)
  end

  module_function :add_link_for_page, :add_local_link_for_page, :add_global_link_for_page
  public :add_local_link_for_page, :add_global_link_for_page
end
