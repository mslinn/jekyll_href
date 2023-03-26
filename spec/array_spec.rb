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

add_local_link_for_page 'page1', 'link1'
add_global_link_for_page 'page10', 'link10'
add_local_link_for_page 'page1', 'link2'
add_global_link_for_page 'page10', 'link20'

add_local_link_for_page 'page2', 'link3'
add_global_link_for_page 'page20', 'link30'
add_local_link_for_page 'page2', 'link4'
add_global_link_for_page 'page20', 'link40'

puts @local_hrefs
puts @global_hrefs
