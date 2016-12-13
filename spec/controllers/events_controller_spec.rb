require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe EventsController, type: :controller do
  let(:date1) { Date.current }
  let(:date2) { Date.current.next_day }
  let(:date3) { Date.current.next_day(2) }
  let(:date4) { Date.current.next_day(2) }

  # this is the format expected by our controller to receive its date ranges
  # in as a nested object
  let(:valid_attributes_post) do
    event = FactoryGirl.attributes_for(:event)
    event[:date_ranges_attributes] = [FactoryGirl.attributes_for(:date_range)]
    { event: event }
  end

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { FactoryGirl.attributes_for(:event) }

  let(:invalid_attributes) { FactoryGirl.attributes_for(:event, max_participants: "twelve") }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # EventsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context "With an existing event" do
    before :each do
      @event = Event.create! valid_attributes
    end

    describe "GET #index" do
      it "assigns all events as @events" do
        get :index, session: valid_session
        expect(assigns(:events)).to eq([@event])
      end
    end

    describe "GET #show" do
      it "assigns the requested event as @event" do
        get :show, id: @event.to_param, session: valid_session
        expect(assigns(:event)).to eq(@event)
      end

      it "assigns the number of free places as @free_places" do
        get :show, id: @event.to_param, session: valid_session
        expect(assigns(:free_places)).to eq(@event.compute_free_places)
      end

      it "assigns the number of occupied places as @occupied_places" do
        get :show, id: @event.to_param, session: valid_session
        expect(assigns(:occupied_places)).to eq(@event.compute_occupied_places)
      end
    end

    describe "GET #new" do
      it "assigns a new event as @event" do
        get :new, params: {}, session: valid_session
        expect(assigns(:event)).to be_a_new(Event)
      end
    end

    describe "GET #edit" do
      it "assigns the requested event as @event" do
        get :edit, id: @event.to_param, session: valid_session
        expect(assigns(:event)).to eq(@event)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {
              name: "Awesome new name"
          }
        }

        it "updates the requested event" do
          put :update, id: @event.to_param, event: new_attributes, session: valid_session
          @event.reload
          expect(@event.name).to eq(new_attributes[:name])
        end

        it "assigns the requested event as @event" do
          put :update, id: @event.to_param, event: valid_attributes, session: valid_session
          expect(assigns(:event)).to eq(@event)
        end

        it "redirects to the event" do
          put :update, id: @event.to_param, event: valid_attributes, session: valid_session
          expect(response).to redirect_to(@event)
        end

        it "does not append to date ranges but replaces them" do
          expect {
            put :update, id: @event.to_param, event: valid_attributes_post[:event], session: valid_session
          }.to change((Event.find_by! id: @event.to_param).date_ranges, :count).by(0)
        end
      end

      context "with invalid params" do
        it "assigns the event as @event" do
          put :update, id: @event.to_param, event: invalid_attributes, session: valid_session
          expect(assigns(:event)).to eq(@event)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @event.to_param, event: invalid_attributes, session: valid_session
          expect(response).to render_template("edit")
        end
      end

      describe "DELETE #destroy" do
        it "destroys the requested event" do
          expect {
            delete :destroy, id: @event.to_param, session: valid_session
          }.to change(Event, :count).by(-1)
        end

        it "redirects to the events list" do
          delete :destroy, id: @event.to_param, session: valid_session
          expect(response).to redirect_to(events_url)
        end
      end

      describe "GET #participants" do
        it "assigns the event as @event" do
          get :participants, id: @event.to_param, session: valid_session
          expect(assigns(:event)).to eq(@event)
        end
        it "assigns all participants as @participants" do
            get :participants, id: @event.to_param, session: valid_session
          expect(assigns(:participants)).to eq(@event.participants)
        end
      end
    end
  end

  describe "GET #participants_pdf" do
    let(:valid_attributes) { FactoryGirl.attributes_for(:event_with_accepted_applications) }

    it "should return an pdf" do
      event = Event.create! valid_attributes
      get :participants_pdf, id: event.to_param, session: valid_session
      expect(response.content_type).to eq('application/pdf')
    end

    it "should return an pdf with the name of the user" do
      event = Event.create! valid_attributes
      profile = FactoryGirl.create(:profile)
      user = FactoryGirl.create(:user, profile: profile)
      application_letter = FactoryGirl.create(:application_letter, status: ApplicationLetter.statuses[:accepted], event: event, user: user)
      response = get :participants_pdf, id: event.to_param, session: valid_session
      expect(response.content_type).to eq('application/pdf')

      pdf = PDF::Inspector::Text.analyze(response.body)
      expect(pdf.strings).to include("Vorname")
      expect(pdf.strings).to include("Nachname")
      expect(pdf.strings).to include(application_letter.user.profile.first_name)
    end
  end

  describe "GET #badges" do
    let(:valid_attributes) { FactoryGirl.attributes_for(:event_with_accepted_applications) }

    it "assigns the requested event as @event" do
      event = Event.create! valid_attributes
      get :badges, event_id: event.to_param, session: valid_session
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "POST #badges" do
    it "contains two name badges with title 'Max Mustermann'" do
      event = Event.create! valid_attributes
      rendered_pdf = post :print_badges,
                          event_id: event.to_param,
                          session: valid_session,
                          "1234_print"  => "Max Mustermann",
                          "1235_print"  => "Max Mustermann",
                          "1236_print"  => "Max Mustermann",
                          "1237_print"  => "Max Mustermann",
                          "1238_print"  => "Max Mustermann",
                          "1239_print"  => "Max Mustermann",
                          "1240_print"  => "John Doe",
                          "1241_print"  => "Max Mustermann",
                          "1242_print"  => "Max Mustermann",
                          "1243_print"  => "Max Mustermann",
                          "1244_print"  => "Max Mustermann",
                          "1245_print"  => "Max Mustermann"
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, valid_attributes_post, session: valid_session
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        post :create, valid_attributes_post, session: valid_session
        expect(assigns(:event)).to be_a(Event)
        expect(assigns(:event)).to be_persisted
      end

      it "saves optional attributes" do
        post :create, event: valid_attributes, session: valid_session
        event = Event.create! valid_attributes
        expect(assigns(:event).organizer).to eq(event.organizer)
        expect(assigns(:event).knowledge_level).to eq(event.knowledge_level)
      end

      it "redirects to the created event" do
        post :create, valid_attributes_post, session: valid_session
        expect(response).to redirect_to(Event.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        post :create, event: invalid_attributes, session: valid_session
        expect(assigns(:event)).to be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        post :create, event: invalid_attributes, session: valid_session
        expect(response).to render_template("new")
      end
    end

    it "should attach correct date ranges to the event entity" do
      post :create, valid_attributes_post, session: valid_session
      expect(assigns(:event)).to be_a(Event)
      expect(assigns(:event)).to be_persisted
      expect(assigns(:event).date_ranges).to_not be_empty
      expect(assigns(:event).date_ranges.first.event_id).to eq(assigns(:event).id)
      date_range = valid_attributes_post[:event][:date_ranges].first
      expect(assigns(:event).date_ranges.first.start_date).to eq(date_range.start_date)
      expect(assigns(:event).date_ranges.first.end_date).to eq(date_range.end_date)
    end
  end
end
