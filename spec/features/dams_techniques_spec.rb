require 'spec_helper'

# Class to store the path of the Technique
class Path
	class << self
		attr_accessor :path
	end
	# Variable to be used to store DAMS Technique path
	# Used for editing specified Technique
	@path = nil
end

def sign_in_developer
  visit new_user_session_path
  fill_in "name", :with => "name"
  fill_in "email", :with => "email@email.com"
  click_on "Sign In"
end
