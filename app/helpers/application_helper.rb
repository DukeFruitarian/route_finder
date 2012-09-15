module ApplicationHelper
	def hidden_div_if(flag, options = {}, &block)
		if flag
			options[:style] = "display: none"
		end
		content_tag("div", options, &block)
	end
	
	def number_to_currency(val)
    val = (val.to_f) * 30 if I18n.locale == :ru
    super(val)
  end
  
  def page_title
    @page_title || "Book store"
  end
end
