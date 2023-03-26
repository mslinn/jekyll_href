module HashArraySpec
  require_relative '../lib/hash_array'

  HashArray.add_local_link_for_page 'page1', 'link1'
  HashArray.add_global_link_for_page 'page10', 'link10'
  HashArray.add_local_link_for_page 'page1', 'link2'
  HashArray.add_global_link_for_page 'page10', 'link20'

  HashArray.add_local_link_for_page 'page2', 'link3'
  HashArray.add_global_link_for_page 'page20', 'link30'
  HashArray.add_local_link_for_page 'page2', 'link4'
  HashArray.add_global_link_for_page 'page20', 'link40'

  RSpec.describe HashArray do
    it 'accumulates arrays of strings' do
      local_hrefs = described_class.instance_variable_get :@local_hrefs
      value = { 'page1' => %w[link1 link2], 'page2' => %w[link3 link4] }
      expect(local_hrefs).to eq(value)

      global_hrefs = described_class.instance_variable_get :@global_hrefs
      value = { 'page10' => %w[link10 link20], 'page20' => %w[link30 link40] }
      expect(global_hrefs).to eq(value)
    end
  end
end

# module HRefTagSpec
#   require_relative '../lib/href_tag'

#   add_local_link_for_page 'page1', 'link1'
#   add_global_link_for_page 'page10', 'link10'
#   add_local_link_for_page 'page1', 'link2'
#   add_global_link_for_page 'page10', 'link20'

#   add_local_link_for_page 'page2', 'link3'
#   add_global_link_for_page 'page20', 'link30'
#   add_local_link_for_page 'page2', 'link4'
#   add_global_link_for_page 'page20', 'link40'

#   RSpec.describe HrefTag do
#     it 'accumulates arrays of strings' do
#       expect(@HrefTag.local_hrefs).to eq({ 'page1' => %w[link1 link2], 'page2' => %w[link3 link4] })
#       expect(@HrefTag.global_hrefs).to eq({ 'page10' => %w[link10 link20], 'page20' => %w[link30 link40] })
#     end
#   end
# end
