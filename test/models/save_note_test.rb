require "test_helper"

class SaveNoteTest < ActiveSupport::TestCase
  test "save a valid outage new note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_a_valid_note_to_instance outage, user
    end

    assert_difference "user.outstanding_notifications(:online).size" do
      assert_difference "Event.all.size" do
        assert Services::SaveNote.call(@note), "Valid, should be true"
        notification = user.outstanding_notifications(:online).last
        assert_check_notification(notification, event_text: "Note Added")
      end
    end
  end

  test "save a valid outage modified note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_a_valid_note_to_instance outage, user
    end
    # Save the note, then Modify the note
    @note.save
    @note.note = "#{@note.note} -- changed"

    assert_difference "user.outstanding_notifications(:online).size" do
      assert_difference "Event.all.size" do
        assert Services::SaveNote.call(@note), "Valid, should be true"
        notification = user.outstanding_notifications(:online).last
        assert_check_notification(notification, event_text: "Note Modified")
      end
    end
  end

  test "save an invalid outage note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_an_invalid_note_to_instance outage, user
    end

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert_not Services::SaveNote.call(@note), "Invalid, should be false"
      end
    end
  end

  test "save a valid new ci note" do
    user = select_user

    ci = create_valid_ci user

    assert_difference "ci.notes.size" do
      @note = add_a_valid_note_to_instance ci, user
    end

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert Services::SaveNote.call(@note), "Valid, should be true"
      end
    end
  end

  test "save an invalid ci note" do
    user = select_user

    ci = create_valid_ci user

    assert_difference "ci.notes.size" do
      @note = add_an_invalid_note_to_instance ci, user
    end

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert_not Services::SaveNote.call(@note), "Invalid, should be false"
      end
    end
  end

  test "save an existing but now invalid outage note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_a_valid_note_to_instance outage, user
    end
    assert @note.save

    # Make the note invalid
    @note.note = nil

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert_not Services::SaveNote.call(@note), "Invalid, should be false"
      end
    end
  end

  test "save an existing but now invalid ci note" do
    user = select_user

    ci = create_valid_ci user

    assert_difference "ci.notes.size" do
      @note = add_a_valid_note_to_instance ci, user
    end
    assert @note.save

    # Make the note invalid
    @note.note = nil

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert_not Services::SaveNote.call(@note), "Invalid, should be false"
      end
    end
  end

  test "save an existing unchanged outage note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_a_valid_note_to_instance outage, user
    end
    # Save the note
    @note.save

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert Services::SaveNote.call(@note), "Valid, should be true"
      end
    end
  end

  test "save an existing unchanged ci note" do
    user = select_user

    ci = create_valid_ci user

    assert_difference "ci.notes.size" do
      @note = add_a_valid_note_to_instance ci, user
    end
    # Save the note
    @note.save

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert Services::SaveNote.call(@note), "Valid, should be true"
      end
    end
  end

  test "delete existing outage note" do
    user = select_user

    outage = create_valid_outage user

    assert_difference "outage.notes.size" do
      @note = add_a_valid_note_to_instance outage, user
    end
    # Save this note for later deletion
    @note.save

    assert_difference "user.outstanding_notifications(:online).size" do
      assert_difference "Event.all.size" do
        assert_difference "outage.notes.size", -1 do
          assert Services::SaveNote.destroy(@note), "Valid, should be true"
          outage.reload
          notification = user.outstanding_notifications(:online).last
          assert_check_notification(notification, event_text: "Note Deleted")
        end
      end
    end
  end

  test "delete existing ci note" do
    user = select_user

    ci = create_valid_ci user

    assert_difference "ci.notes.size" do
      @note = add_a_valid_note_to_instance ci, user
    end
    # Save this note for later deletion
    @note.save

    assert_no_difference "user.outstanding_notifications(:online).size" do
      assert_no_difference "Event.all.size" do
        assert_difference "ci.notes.size", -1 do
          assert Services::SaveNote.destroy(@note), "Valid, should be true"
          ci.reload
        end
      end
    end
  end

  private

  def add_an_invalid_note_to_instance(instance, user)
    note = instance.notes.new(note: nil, user: user)
    assert_not note.valid?
    note
  end

  def add_a_valid_note_to_instance(instance, user)
    note = instance.notes.new(note: "A Testor's Note", user: user)
    assert note.valid?
    note
  end

  def assert_check_notification(notification, options)
    event_text = options[:event_text] || "Default Text"
    event_type = options[:event_type] || "outage_note"
    notification_type = options[:notification_type] || "online"

    assert_not notification.nil?, "No Notification"

    assert notification.is_a?(Notification)

    assert_equal event_text, notification.event.text,
      "Unexpected Event Text"
    assert_equal event_type, notification.event.event_type,
      "Unexpected Event Type"
    assert_equal notification_type, notification.notification_type,
      "Unexpected Notification Type"
  end

  def create_valid_ci(user)
    # Create a valid ci for user account and save it
    # Create a watch on the ci for the user
    ci = Ci.create(account: user.account,
                   name: "A Test CI")

    assert ci.save
    user.watches.create(active: true, watched: ci)

    ci
  end

  def create_valid_outage(user)
    # Create a valid outage for user and save it
    # Create a watch on the outage for the user
    outage = Outage.create(account: user.account,
                           start_time: Time.zone.now + 1.day,
                           end_time: Time.zone.now + 1.day + 1.hour,
                           causes_loss_of_service: true,
                           completed: false)
    assert outage.save
    user.watches.create(active: true, watched: outage)

    outage
  end

  def mark_users_online_notifications_read(user)
    user.outstanding_notifications(:online).each do |n|
      n.notified = true
      n.save
    end
  end

  def select_user
    user = users(:edit_ci_outages)
    user.notify_me_on_note_changes = true
    user.save
    mark_users_online_notifications_read(user)
    user
  end
end
