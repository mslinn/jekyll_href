module HrefTag
  class HrefTag
    private

    def save_summary
      return if @summary_exclude || @link_save.start_with?('mailto:') || @link_save.start_with?('#')

      @summary = @summary.to_s.empty? ? @text : @summary.to_s
      if @summary == true
        warning = <<~END_WARNING
          Warning: a href plugin keyword option was detected in the link text for #{@path} on line #{line_number}.
          The href tag will not be included in the summary, and the link text will not have the word summary included.
          This is probably unintentional. Consider using the label option to correct this problem."
        END_WARNING
        puts warning.red
        return
      end
      return if @summary.class != String || @summary.empty?

      @summary = @summary[0].upcase + @summary[1..]
      @summary_href = "<a href='#{@link_save}'#{@target}#{@follow}>#{@summary}</a>"
      mini_href = MiniHref.new(
        follow:          @follow,
        html:            @summary_href,
        line_number:     @line_number,
        link:            @link_save,
        link_save:       @link_save,
        path:            @path,
        summary_exclude: @summary_exclude,
        summary_href:    @summary_href
      )
      if @link_save.start_with? 'http'
        add_global_link_for_page mini_href
      else
        add_local_link_for_page mini_href
      end
    end
  end
end
