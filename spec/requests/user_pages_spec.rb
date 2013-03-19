require 'spec_helper'

describe "User pages" do

    subject {page}

    describe "Signup page" do

        before {visit signup_path}

        it { should have_title('Sign up' ) }
        it { should have_selector( 'title', :text => full_title('Sign up')) }
    end

    describe "Profile page" do
        let(:user) { FactoryGirl.create(:user) }
        before { visit user_path(user) }

        it { should have_title( user.name ) }
        it { should have_selector( 'title', :text => user.name ) }
    end

    describe "Signup" do
        before { visit signup_path }
        let(:submit) { "Create my account" }

        describe "with invalid information" do
            it "should not create a user" do
                expect { click_button submit }.not_to change(User, :count)
            end

            describe "after submission" do
                
                describe "blank form" do
                    before { click_button submit }
                    it { should have_selector('title', :text => 'Sign up') }
                    it { should have_content('error') }
                end

                describe "without name" do
                    before { signup_without_field('name') }
                    it { should have_content("Name can't be blank") }
                end

                describe "without email" do
                    before { signup_without_field('email') }
                    it { should have_content("Email can't be blank") }
                end

                describe "without password" do
                    before { signup_without_field('password') }
                    it { should have_content("Password can't be blank") }
                end

                describe "without confirmation" do
                    before { signup_without_field('confirmation') }
                    it { should have_content("confirmation can't be blank") }
                end

                describe "with password too short" do
                    before do
                        fill_in "Name",         with: "Example User"
                        fill_in "Email",        with: "user@example.com"
                        fill_in "Password",     with: "foo"
                        fill_in "Confirmation", with: "foo"
                        click_button submit
                    end
                    it { should have_content("Password is too short (minimum is 6 characters)") }
                end


                describe "with diferent password and confirmation" do
                    before do
                        fill_in "Name",         with: "Example User"
                        fill_in "Email",        with: "user@example.com"
                        fill_in "Password",     with: "foobar"
                        fill_in "Confirmation", with: "barfoo"
                        click_button submit
                    end
                    it { should have_content("Password doesn't match confirmation") }
                end

                describe "with already taken email" do
                    let(:user) { FactoryGirl.create(:user) }
                    before do
                        fill_in "Name",         with: "Example User"
                        fill_in "Email",        with: user.email
                        fill_in "Password",     with: "foobar"
                        fill_in "Confirmation", with: "foobar"
                        click_button submit
                    end
                    it { should have_content("Email has already been taken") }
                end
            end
        end

        describe "with valid information" do
            before { valid_signup() }

            it "should create a user" do
                expect { click_button submit }.to change(User, :count).by(1)
            end

            describe "after saving the user" do
                before { click_button submit }
                let(:user) { User.find_by_email('user@example.com') }

                it { should have_selector('title', text: user.name) }
                it { should have_success_message('Welcome') }
                it { should have_link('Sign out') }
            end
        end
    end
end
