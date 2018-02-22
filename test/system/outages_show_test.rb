# frozen_string_literal: true

require "application_system_test_case"

class OutagesShowTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength
  test "show two notes default order" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)
    notes = all("li.note")
    assert_equal 2, notes.size
    # There is an event in
    # assert_synchronized("Note A", 1)
    within(notes[0]) do
      assert_text "Note A"
      assert_text "1 hour ago"
      assert_link "Edit"
      assert_text "Basic"
    end
    within(notes[1]) do
      assert_text "Note B"
      assert_text "1 day ago"
      assert_no_link "Edit"
      assert_text "Can Edit CIs/Outages"
    end
  end

  test "show two notes ascending order" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)
    click_link "Oldest First"

    assert_synchronized("Note B")
    notes = all("li.note")
    within(notes[0]) do
      assert_text "Note B"
      assert_text "1 day ago"
      assert_no_link "Edit"
      assert_text "Can Edit CIs/Outages"
    end
    within(notes[1]) do
      assert_text "Note A"
      assert_text "1 hour ago"
      assert_link "Edit"
      assert_text "Basic"
    end

    # assert_synchronized("Note B")
    click_link "Newest First"
    # Since Note A is in the middle, you can't use it to synchronize on order.
    assert_synchronized("Note B", 2)
    assert_note_a(0)
    assert_note_b(1)
  end

  test "add a note default order" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)

    fill_in "New Note", with: "Note C."
    assert_difference "Note.count" do
      click_button "Save Note"
      assert_text "Note C."
    end

    assert_synchronized("Note C")
    assert_note_b(2)
    assert_note_a(1)
    assert_note_c(0)

    assert_no_field "New Note", with: "Note C."
  end

  test "add a note ascending order" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)
    click_link "Oldest First"
    assert_synchronized("Note B")
    assert_note_b(0)
    assert_note_a(1)

    fill_in "New Note", with: "Note C."
    assert_difference "Note.count" do
      click_button "Save Note"
      assert_text "Note C."
    end

    assert_synchronized("Note B")
    assert_note_b(0)
    assert_note_a(1)
    assert_note_c(2)
  end

  test "edit a note" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit outage_url(@outage)

    assert_no_difference "Note.count" do
      within(all("li.note")[1]) { click_link "Edit" }
      fill_in "Edit Note", with: "Note B Prime"
      click_button "Update Note"
    end

    assert_selector("li.note", count: 2)
    assert_synchronized("Note B Prime", 2)
    assert_note_b_prime(1)
  end

  test "delete a note" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)

    assert_selector("li.note", count: 2)
    assert_difference "Note.count", -1 do
      accept_alert do
        within(all("li.note")[0]) { click_link "Delete" }
      end
      assert_selector("li.note", count: 1)
    end

    assert_selector("li.note", count: 1)
    assert_synchronized("Note B", 1)
    assert_note_b(0)
  end

  test "note save failure" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)

    assert_no_difference "Note.count" do
      click_button "Save Note"
      assert_text "is too short (minimum is 1 character)"
    end
  end

  test "note destroy failure" do
    skip "Failing to destroy note would be too hard to fake."
  end

  test "set and unset completed" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit outage_url(@outage)

    assert_difference "Outage.unscoped.where(completed: true).count" do
      check "Completed"
    end
    assert_difference "Outage.unscoped.where(completed: true).count", -1 do
      uncheck "Completed"
    end
  end

  test "set and unset watched" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)

    assert_no_checked_field "Watch"
    assert_difference "Watch.count" do
      check "Watched"
    end
    assert_difference "Watch.count", -1 do
      uncheck "Watched"
    end
  end

  test "basic user can't set completed" do
    sign_in_for_system_tests(users(:basic))
    visit outage_url(@outage)
    assert_field "Completed", disabled: true
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

  # These also test that only the original author can edit or delete notes.
  def assert_note_a(index)
    within(all("li.note")[index]) do
      assert_text "Note A"
      assert_text "1 hour ago"
      assert_link "Edit"
      assert_link "Delete"
      # TODO: Make a link to user profile show.
      assert_text "Basic"
    end
  end

  def assert_note_b(index)
    within(all("li.note")[index]) do
      assert_text "Note B"
      assert_text "1 day ago"
      assert_no_link "Edit"
      assert_no_link "Delete"
      assert_text "Can Edit CIs/Outages"
    end
  end

  # This one is also for the other user.
  def assert_note_b_prime(index)
    within(all("li.note")[index]) do
      assert_text "Note B Prime"
      assert_text "1 day ago"
      assert_link "Edit"
      assert_link "Delete"
      assert_text "Can Edit CIs/Outages"
    end
  end

  def assert_note_c(index)
    within(all("li.note")[index]) do
      assert_text "Note C"
      assert_text "less than 5 seconds ago"
      assert_link "Edit"
      assert_link "Delete"
      assert_text "Basic"
    end
  end

  ##
  # Assert a waitable condition to make sure the page has been updated.
  # Remember that the css ordinals are 1-based. And that it's literally on
  # the type, so it doesn't select the nth note, only the nth <li>.
  def assert_synchronized(text, ordinal = 0)
    assert_selector "li.note:nth-of-type(#{ordinal + 1}) .note-body", text: text
  end
end
