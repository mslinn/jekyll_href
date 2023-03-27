module HashArraySpec
  require_relative '../lib/hash_array'

  RSpec.describe HashArray do
    let(:logger) do
      PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    let(:parse_context) { TestParseContext.new }

    [1, 2, 3, 4, 11, 22, 33, 44].each do |x|
      let("href#{x}".to_sym) do
        domain, where = if x.even?
                          ['https://domain.com/', 'External']
                        else
                          ['', 'Internal']
                        end
        href = HrefTag::HrefTag.send(
          :new,
          'href',
          + "#{domain}path/page#{x}.html #{where} link text #{x}",
          parse_context
        )
        href.render(TestLiquidContext.new)
        href
      end
    end

    it 'accumulates arrays of href_tag' do
      described_class.reset
      [href1, href3, href11, href33].each { |x| described_class.add_local_link_for_page x }
      [href2, href4, href22, href44].each { |x| described_class.add_global_link_for_page x }

      local_hrefs = described_class.instance_variable_get :@local_hrefs
      value = { 'index.html' => [href1, href3, href11, href33] }
      expect(local_hrefs).to match_array(value)

      global_hrefs = described_class.instance_variable_get :@global_hrefs
      value = { 'index.html' => [href2, href4, href22, href44] }
      expect(global_hrefs).to match_array(value)
    end
  end
end
