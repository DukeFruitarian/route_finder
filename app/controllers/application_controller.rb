class ApplicationController < ActionController::Base
	protect_from_forgery

  private

		def setup_page_title
		  @page_title = t('.title')#"Flight finder"
	  end

end
