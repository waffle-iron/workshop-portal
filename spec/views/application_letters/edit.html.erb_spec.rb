require 'rails_helper'

RSpec.describe "application_letters/edit", type: :view do
  before(:each) do
    @application_letter = assign(:application_letter, FactoryGirl.create(:application_letter))
  end

  it "renders the edit application form" do
    render

    assert_select "form[action=?][method=?]", application_letter_path(@application_letter), "post" do
      assert_select "input#application_letter_motivation[name=?]", "application_letter[motivation]"
      assert_select "input#application_letter_user_id[name=?]", "application_letter[user_id]"
      assert_select "input#application_letter_workshop_id[name=?]", "application_letter[workshop_id]"
    end
  end
end