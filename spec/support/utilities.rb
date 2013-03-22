include ApplicationHelper

#def full_title(page_title)
#  base_title = "Ruby on Rails Tutorial Sample App"
#  if page_title.empty?
#    base_title
#  else
#    "#{base_title} | #{page_title}"
#  end
#end

def valid_signin(user)
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
    # Sign in when not using Capybara as well.
    cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

def valid_signup()
    fill_in "Name",         with: "Example User"
    fill_in "Email",        with: "user@example.com"
    fill_in "Password",     with: "foobar"
    fill_in "Confirmation", with: "foobar"
end

RSpec::Matchers.define :have_title do |text|
  match do |page|
    page.should have_selector('h1', text: text)
  end
end

def signup_without_field(field)
    fields = {
        name: 'Example User',
        email: 'user@example.com',
        password: 'foobar',
        confirmation: 'foobar',
    }

    fields.each do |key, val|
        fill_in key.to_s.capitalize, with: val unless key.to_s == field
    end

    click_button submit
end
