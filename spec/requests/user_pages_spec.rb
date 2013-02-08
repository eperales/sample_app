require 'spec_helper'

describe "User pages" do

    subject {page}

    describe "Singup page" do
        before {visit signup_path}
        it { should have_selector('h1', :text => 'Sing up') }
        it { should have_selector( 'title', :text => full_title('Sing up')) }
    end
end
