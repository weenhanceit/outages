require "application_system_test_case"

class CisShowTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "show two notes default order" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)
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

  test "show two notes ascending order" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)
    click_link "Oldest First"
    # TODO: I see no other way than to wait for some time here.
    sleep 2

    notes = all("li.note")
    within(notes[0]) do
      assert_text "Note B"
      assert_text "1 day ago"
      assert_no_link "Edit"
      # TODO: Make a link to user profile show.
      assert_text "Can Edit CIs/Outages"
    end
    within(notes[1]) do
      assert_text "Note A"
      assert_text "1 hour ago"
      assert_link "Edit"
      # TODO: Make a link to user profile show.
      assert_text "Basic"
    end

    click_link "Newest First"
    # TODO: I see no other way than to wait for some time here.
    sleep 2
    assert_note_a(0)
    assert_note_b(1)
  end

  test "add a note default order" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)

    fill_in "New Note", with: "Note C."
    assert_difference "Note.count" do
      click_button "Save Note"
      assert_text "Note C."
    end

    assert_note_b(2)
    assert_note_a(1)
    assert_note_c(0)

    assert_no_field "New Note", with: "Note C."
  end

  test "add a note ascending order" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)
    click_link "Oldest First"
    # TODO: I see no other way than to wait for some time here.
    sleep 2

    fill_in "New Note", with: "Note C."
    assert_difference "Note.count" do
      click_button "Save Note"
      assert_text "Note C."
    end

    assert_note_b(0)
    assert_note_a(1)
    assert_note_c(2)
  end

  test "edit a note" do
    sign_in_for_system_tests(users(:edit_ci_outages))
    visit ci_url(@ci)

    assert_no_difference "Note.count" do
      within(all("li.note")[1]) { click_link "Edit" }
      fill_in "Edit Note", with: "Note B Prime"
      click_button "Update Note"
    end

    assert_selector("li.note", count: 2)
    assert_note_b_prime(1)
  end

  test "delete a note" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)

    assert_selector("li.note", count: 2)
    assert_difference "Note.count", -1 do
      within(all("li.note")[0]) { click_link "Delete" }
      assert_selector("li.note", count: 1)
    end

    assert_selector("li.note", count: 1)
    assert_note_b(0)
  end

  test "note save failure" do
    # TODO: Add this test. Show the message and don't change pages.
    skip "Failed to save note"
  end

  test "note destroy failure" do
    # TODO: Add this test. Show the message and don't change pages.
    skip "Failed to destroy note"
  end

  test "set and unset watched" do
    sign_in_for_system_tests(users(:basic))
    visit ci_url(@ci)

    assert_checked_field "Watch"
    assert_difference "Watch.count", -1 do
      uncheck "Watched"
      sleep 2
    end
    skip "TODO: Don't forget to finish this test."
    assert_difference "Watch.count", -1 do
      check "Watched"
      sleep 2
    end
  end

  def setup
    @ci = Ci.find_by(account: accounts(:company_a), name: "Server A")
    @ci.notes.create([
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
    assert @ci.save, "Save of notes failed #{@ci.errors.full_messages}"
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
      # TODO: Make a link to user profile show.
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
      # TODO: Make a link to user profile show.
      assert_text "Can Edit CIs/Outages"
    end
  end

  def assert_note_c(index)
    within(all("li.note")[index]) do
      assert_text "Note C"
      assert_text "less than 5 seconds ago"
      assert_link "Edit"
      assert_link "Delete"
      # TODO: Make a link to user profile show.
      assert_text "Basic"
    end
  end
end
