require "rails_helper"

describe "Event", type: :feature do
  describe "index page" do
    it "should link to the show page when an event title is clicked" do
      event = FactoryGirl.create :event
      visit events_path
      click_link "Event-Name"
      expect(page).to have_current_path(event_path(event))
    end
  end

  describe "create page" do
    ['Camp', 'Workshop'].each do |kind|
      it "should allow picking the #{kind} kind camp" do
        visit new_event_path
        fill_in "Maximale Teilnehmerzahl", :with => 25
        choose(kind)
        click_button "Veranstaltung erstellen"
        expect(page).to have_text(kind)
      end
    end

    it "should not allow dates in the past" do
      visit new_event_path
      select_date_within_selector(Date.yesterday.prev_day, '.event-date-picker-start')
      select_date_within_selector(Date.yesterday, '.event-date-picker-end')
      click_button "Veranstaltung erstellen"
      expect(page).to have_text("Anfangs-Datum darf nicht in der Vergangenheit liegen.")
    end

    it "should warn about unreasonably long time spans" do
      visit new_event_path
      fill_in 'Maximale Teilnehmerzahl', :with => 25
      select_date_within_selector(Date.today, '.event-date-picker-start')
      select_date_within_selector(Date.today.next_year(3), '.event-date-picker-end')
      click_button "Veranstaltung erstellen"
      expect(page).to have_text("End-Datum liegt ungewöhnlich weit vom Start-Datum entfernt.")
    end

    it "should not allow an end date before a start date" do
      visit new_event_path
      select_date_within_selector(Date.today, '.event-date-picker-start')
      select_date_within_selector(Date.today.prev_day(2), '.event-date-picker-end')
      click_button "Veranstaltung erstellen"

      expect(page).to have_text("End-Datum kann nicht vor Start-Datum liegen")
    end
  end

  describe "show page" do
    it "should display the event kind" do
      %i[camp workshop].each do |kind|
        event = FactoryGirl.create(:event, kind: kind)
        visit event_path(event)
        expect(page).to have_text(kind.to_s.humanize)
      end
    end

    it "should display all date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      visit event_path(event.id)

      expect(page).to have_text(event.date_ranges.first.start_date.to_s +
                                ' bis ' + event.date_ranges.first.end_date.to_s)
      expect(page).to have_text(event.date_ranges.second.start_date.to_s +
                                ' bis ' + event.date_ranges.second.end_date.to_s)
    end
  end

  describe "edit page" do
    it "should preselect the event kind" do
      event = FactoryGirl.create(:event, kind: :camp)
      visit edit_event_path(event)
      expect(find_field('Camp')[:checked]).to_not be_nil
    end

    it "should display all existing date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      visit edit_event_path(event.id)

      page.assert_selector('.event-date-picker', count: 2)
    end

    it "should save edits to the date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      dateStart = Date.today.next_year
      dateEnd = Date.tomorrow.next_year

      visit edit_event_path(event.id)

      picker = page.all('.event-date-picker')[0]
      startPicker = picker.find('.event-date-picker-start')
      endPicker = picker.find('.event-date-picker-end')

      select_date_within_selector(dateStart, startPicker)
      select_date_within_selector(dateEnd, endPicker)

      click_button 'Veranstaltung aktualisieren'

      expect(page).to have_text(dateStart.to_s + ' bis ' + dateEnd.to_s)
    end
  end
end

