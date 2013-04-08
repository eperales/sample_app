require 'spec_helper'

describe "User pages" do

    subject {page}

    describe "index" do

        let(:user) { FactoryGirl.create(:user) }

        before(:each) do
            valid_signin user
            visit users_path
        end

        it { should have_selector('title', text: "All users") }
        it { should have_title('All users' ) }

        describe "pagination" do
            before(:all) {30.times { FactoryGirl.create(:user) }}
            after(:all) {User.delete_all}

            it { should have_selector('div.pagination') }

            it "should list each user" do
                User.paginate(page: 1).each do |user|
                    page.should have_selector('li', text: user.name)
                end
            end
        end

        describe "delete links" do
            
            it { should_not have_link('delete') }

            describe "as an admin user" do
                
                let(:admin) { FactoryGirl.create(:admin) }
                
                before do
                    valid_signin admin
                    visit users_path
                end

                it { should have_link('delete', href:user_path(User.first)) }
                it "should be able to delete another user" do
                    expect { click_link('delete') }.to change(User, :count).by(-1)
                end


                it "should not be able to delete himself" do
                    expect { delete user_path(admin) }.to change(User, :count).by(0)
                end

                it { should_not have_link('delete', href: user_path(admin)) }
            end
        end

    end

    describe "Signup page" do

        before {visit signup_path}

        it { should have_title('Sign up' ) }
        it { should have_selector( 'title', :text => full_title('Sign up')) }
    end

    describe "Profile page" do
        let(:user) { FactoryGirl.create(:user) }
        let!(:m1) {FactoryGirl.create(:micropost, user: user, content: "Foo")}
        let!(:m2) {FactoryGirl.create(:micropost, user: user, content: "Bar")}

        before { visit user_path(user) }

        it { should have_title( user.name ) }
        it { should have_selector( 'title', :text => user.name ) }

        describe "microposts" do
            it { should have_content(m1.content) }
            it { should have_content(m2.content) }
            it { should have_content(user.microposts.count) }
        end
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
                    before { signup_without_field('confirm') }
                    it { should have_content("confirmation can't be blank") }
                end

                describe "with password too short" do
                    before do
                        fill_in "Name",         with: "Example User"
                        fill_in "Email",        with: "user@example.com"
                        fill_in "Password",     with: "foo"
                        fill_in "Confirm", with: "foo"
                        click_button submit
                    end
                    it { should have_content("Password is too short (minimum is 6 characters)") }
                end


                describe "with diferent password and confirmation" do
                    before do
                        fill_in "Name",         with: "Example User"
                        fill_in "Email",        with: "user@example.com"
                        fill_in "Password",     with: "foobar"
                        fill_in "Confirm", with: "barfoo"
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
                        fill_in "Confirm", with: "foobar"
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


    describe "edit" do

        let(:user) { FactoryGirl.create(:user) }
        before do
            valid_signin user
            visit edit_user_path(user)
        end

        describe "page" do
            it { should have_selector('h1',    text: "Update your profile") }
            it { should have_selector('title', text: "Edit user") }
            it { should have_link('change', href: 'http://gravatar.com/emails') }
        end

        describe "with invalid information" do
            before { click_button "Save changes" }
            it { should have_content('error') }
        end

        describe "with valid information" do
            let(:new_name) {'New Name'}
            let(:new_email) {'new@example.com'}
            before do
                fill_in "Name",             with: new_name
                fill_in "Email",            with: new_email
                fill_in "Password",         with: user.password
                fill_in "Confirm password", with: user.password
                click_button "Save changes"
            end

            it { should have_selector('title', text: new_name) }
            it { should have_selector('div.alert.alert-success') }
            it { should have_link('Sign out', href: signout_path) }
            specify { user.reload.name.should  == new_name }
            specify { user.reload.email.should == new_email }
        end
    end
end
