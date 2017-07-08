require "application_system_test_case"

class OutagesShowTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "show two notes" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)
    notes = all("li.note")
    assert_equal 2, notes.size
    within(notes[0]) do
      assert_text "Note A"
      assert_text "1 hour ago"
      assert_link "Edit"
      # TODO: Make a link to user profile show.
      assert_text "Basic"
    end
    within(notes[1]) do
      assert_text "Note B"
      assert_text "1 day ago"
      assert_no_link "Edit"
      # TODO: Make a link to user profile show.
      assert_text "Can Edit CIs/Outages"
    end
  end

  test "add a note" do
    flunk
  end

  test "edit a note" do
    flunk
  end

  test "delete a note" do
    flunk
  end

  test "can't edit a note if you're not the original author" do
    flunk
  end

  test "can't delete a note if you're not the original author" do
    flunk
  end

  def setup
    @outage = Outage.find_by(account: accounts(:company_a), name: "Outage A")
    @outage.notes.create([
      {
        note: "Note A",
        user: users(:basic),
        created_at: Time.zone.now - 1.hour
      },
      {
        note: "Note B",
        user: users(:edit_ci_outages),
        created_at: Time.zone.now - 1.day
      }
    ])
    assert @outage.save, "Save of notes failed #{@outage.errors.full_messages}"
  end
end
