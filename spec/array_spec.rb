hrefs = {}

def add_link_to_page(page_path, link)
  hrefs = [] if hrefs.nil?
  hrefs[page_path] << link
end

add_link_to_page'page1', 'link1'
add_link_to_page'page1', 'link2'

add_link_to_page'page2', 'link3'
add_link_to_page'page2', 'link4'

puts hrefs
