module HashArraySpec
  require_relative '../lib/hash_array'

  RSpec.describe HashArray do
    let(:logger) do
      PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    let(:parse_context) { TestParseContext.new }

    [1, 2, 3, 4, 10, 20, 30, 40].each do |x|
      let("href#{x}".to_sym) {
        domain = x.even? ? 'https://domain.com/' : ''
        href = HrefTag::HrefTag.send(
          :new,
          'href',
          + "#{domain}path/page#{x}.html Internal link text #{x}",
          parse_context
        )
        href.render(TestLiquidContext.new)
        href
      }
    end

    it 'accumulates arrays of href_tag' do
      described_class.reset

      described_class.add_local_link_for_page href1
      described_class.add_local_link_for_page href2

      described_class.add_global_link_for_page href10
      described_class.add_global_link_for_page href20

      described_class.add_local_link_for_page href3
      described_class.add_local_link_for_page href4
      described_class.add_global_link_for_page href30
      described_class.add_global_link_for_page href40

      local_hrefs = described_class.instance_variable_get :@local_hrefs
      value = { 'index.html' => [href1, href3] }
      expect(local_hrefs).to match_array(value)

      global_hrefs = described_class.instance_variable_get :@global_hrefs
      value = { 'index.html' => [href10, href30] }
      expect(global_hrefs).to match_array(value)
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
