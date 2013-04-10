require 'spec_helper'

describe "Static pages" do

    subject {page}

    shared_examples_for "all static pages" do
        it { should have_selector('h1',    text: heading) }
        it { should have_selector('title', text: full_title(page_title)) }
    end

    describe "Home page" do
        before {visit root_path}
        let(:heading)    { 'Sample App' }
        let(:page_title) { '' }

        it_should_behave_like "all static pages"
        it {should_not have_selector('title', :text => '|')}

        it "should have the right links on the layout" do
            visit root_path
            click_link "About"
            page.should have_selector 'title', text: full_title('About Us')
            click_link "Help"
            page.should have_selector 'title', text: full_title('Help')
            click_link "Contact"
            page.should have_selector 'title', text: full_title('Contact')
            click_link "Home"
            page.should have_selector 'title', text: full_title('')
            click_link "Sign up now!"
            page.should have_selector 'title', text: full_title('Sign up')
            click_link "sample app"
            page.should have_selector 'title', text: full_title('')
        end

        describe "for signed-in users" do
            let(:user) { FactoryGirl.create(:user) }

            describe "with no microposts" do
                before do
                    valid_signin user
                    visit root_path
                end

                describe "should show string '0 microposts'" do
                    it {should have_content("#{user.microposts.count} microposts")}
                end
            end

            describe "with 1 micropost" do
                before do
                    FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
                    valid_signin user
                    visit root_path
                end
                describe "should show string '1 micropost'" do
                    it {should have_content("#{user.microposts.count} micropost")}
                    it {should_not have_content("#{user.microposts.count} microposts")}
                end
            end

            describe "with more than 1 micropost" do
                before do
                    FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
                    FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
                    valid_signin user
                    visit root_path
                end
                describe "should show string '2 microposts'" do
                    it {should have_content("#{user.microposts.count} microposts")}
                end
            end


            describe "no matter how many microposts the user have" do
                
                before do
                    FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
                    FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
                    valid_signin user
                    visit root_path
                end
                
                it "should render the user's feed" do
                    user.feed.each do |item|
                        page.should have_selector("li##{item.id}", text: item.content) 
                    end
                end

                it "should show the microposts count" do
                    page.should have_content("#{user.microposts.count} microp")
                end
            end

            describe "pagination" do

                before do
                    valid_signin user
                    visit root_path
                end

                describe "with less than 30 items" do
                    it "should not have paginator" do
                        page.should_not have_selector('li.next.next_page')
                    end
                end

                describe "with more than 30 items" do
                    before do
                        31.times do
                            FactoryGirl.create(:micropost, user: user)
                        end
                        visit root_path
                    end
                    
                    it "should have paginator" do
                        page.should have_selector('li.next.next_page')
                    end

                    describe "item 32" do
                        before do
                            FactoryGirl.create(:micropost, user: user, content: "Post numero 32. Nomes h'ha de mostrar a la segona pagina", created_at: 1.year.ago)
                            visit root_path
                        end

                        it "does not apear in first page" do
                            page.should_not have_content("Post numero 32. Nomes h'ha de mostrar a la segona pagina")
                        end

                        describe "must apear in second page" do
                            before do
                                click_link('Next')
                            end

                            it { should have_content("Post numero 32. Nomes h'ha de mostrar a la segona pagina") }
                        end
                    end
                end
            end
        end
    end

    describe "Help page" do
        before {visit help_path}
        let(:heading)    { 'Help' }
        let(:page_title) { 'Help' }

        it_should_behave_like "all static pages"
    end

    describe "About page" do
        before {visit about_path}
        let(:heading)    { 'About Us' }
        let(:page_title) { 'About Us' }

        it_should_behave_like "all static pages"
    end

    describe "Contact page" do
        before {visit contact_path}
        let(:heading)    { 'Contact' }
        let(:page_title) { 'Contact' }

        it_should_behave_like "all static pages"
    end
end
