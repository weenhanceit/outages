require "test_helper"

class SaveOutageTest < ActiveSupport::TestCase
  test "save a new valid outage" do
    outage = Outage.new(account: accounts(:company_a),
                        causes_loss_of_service: true,
                        completed: false,
                        description: "Company A outage for save test",
                        end_time: Time
                          .find_zone("Samoa")
                          .parse("2017-08-30T15:00:00"),
                        name: "Outage for save test",
                        start_time: Time
                          .find_zone("Samoa")
                          .parse("2017-08-30T14:00:00"))
    assert_difference ["Event.count","Outage.count"] do
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."

      assert_equal "outage", event.event_type
      assert_equal "New Outage", event.text
      assert_equal outage, event.outage
    end
  end

  test "save a new invalid outage" do
    outage = Outage.new
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert_not result
    end

  end

  test "save an existing but now invalid outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.active = nil
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert_not result
    end
  end

  test "save an existing unchanged outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    assert_no_difference ["Event.count","Outage.count"] do
      result = Services::SaveOutage.call(outage)
      assert true == result
    end
  end

  test "change start time of existing outage" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.start_time = outage.start_time + 14.minute
    assert_difference "Event.count" do
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "Outage Changed", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    outage_saved = Outage.find(outage.id)
    assert outage_saved.is_a?(Outage), "Could not find saved outage"
    assert_equal outage.start_time, outage_saved.start_time, "Start time unchanged"
  end

  test "make active outage inactive" do
    outage = outages(:company_a_outage_watched_by_edit)
    assert_difference "Event.count" do
      outage.active = false
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "Outage Cancelled", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    assert_equal 0, Outage.where(id: outage.id).size
    outage.reload
    assert_not outage.active
  end

  test "make inactive outage active" do
    outage = outages(:company_a_outage_watched_by_edit)
    outage.active = false
    outage.save
    assert_difference "Event.count" do
      outage.active = true
      event = Services::SaveOutage.call(outage)
      assert event.is_a?(Event), "Save outage #{outage.inspect} failed."
      assert_equal "outage", event.event_type
      assert_equal "New Outage", event.text
      assert_equal outage, event.outage
    end
    # check the changes were reflected in the database
    outage_saved = Outage.find(outage.id)
    assert outage_saved.is_a?(Outage), "Could not find saved outage"
  end

  test "event_text method" do
    test_case = [
      # -- changed -----------------------------------------------------------------
      {new: false, changed: false, active_changed: false, active: false, exp: nil},
      {new: false, changed: false, active_changed: false, active: true, exp: nil},
      # {new: false, changed: false, active_changed: true, active: false, exp: "x"}, impossible state
      # {new: false, changed: false, active_changed: true, active: true, exp: "x"}, impossible state
      {new: false, changed: true, active_changed: false, active: false, exp: nil},
      {new: false, changed: true, active_changed: false, active: true, exp: "Outage Changed"},
      {new: false, changed: true, active_changed: true, active: false, exp: "Outage Cancelled"},
      {new: false, changed: true, active_changed: true, active: true, exp: "New Outage"},
      # -- new -----------------------------------------------------------------
      # {new: true, changed: false, active_changed: false, active: false, exp: "x"}, impossible state
      # {new: true, changed: false, active_changed: false, active: true, exp: "x"}, impossible state
      # {new: true, changed: false, active_changed: true, active: false, exp: "x"}, impossible state
      # {new: true, changed: false, active_changed: true, active: true, exp: "x"}, impossible state
      # {new: true, changed: true, active_changed: false, active: false, exp: "x"},impossible state
      # {new: true, changed: true, active_changed: false, active: true, exp: "x"},impossible state
      {new: true, changed: true, active_changed: true, active: false, exp: nil},
      {new: true, changed: true, active_changed: true, active: true, exp: "New Outage"}
    ]

    test_case.each do |tc|
      outage = get_an_outage(tc)
      # puts "save_outage_test.rb TP_#{__LINE__}"
      # Check the outage is in the state we expect
      assert outage.is_a?(Outage)
      assert_equal tc[:new], outage.new_record?, "Outage.new_record? in unexpected state"
      assert_equal tc[:changed], outage.changed?, "Outage.changed? in unexpected state"
      assert_equal tc[:active_changed], outage.active_changed?, "Outage.active_changed? in unexpected state"
      assert_equal tc[:active], outage.active, "Outage.active? in unexpected state"
      results = Services::SaveOutage.event_text(outage)
      if tc[:exp].nil?
        assert_nil results
      else
        assert_equal tc[:exp], results
      end

    end
  end

  private

  def get_an_outage(odef={})
    # puts "save_outage_test.rb TP_#{__LINE__}: #{odef.inspect}"
    outage = Outage.new
    if !odef[:new]
      # Make sure outage is valid
      outage.account = accounts(:company_a)
      outage.causes_loss_of_service = true
      outage.completed = false
      assert outage.valid?

      if !odef[:changed] && !odef[:active_changed] && !odef[:active]
        outage.active = false
        outage.save
      elsif !odef[:changed] && !odef[:active_changed] && odef[:active]
        outage.save
      elsif odef[:changed] && !odef[:active_changed] && !odef[:active]
        outage.active = false
        outage.save
        outage.description = "a description"
      elsif odef[:changed] && !odef[:active_changed] && odef[:active]
        outage.save
        outage.description = "#{outage.description} !"
      elsif odef[:changed] && odef[:active_changed] && !odef[:active]
        outage.save
        outage.active = false
      elsif odef[:changed] && odef[:active_changed] && odef[:active]
        outage.save
        outage.active = false
        outage.save
        outage.active = true
      end
    else
      # puts "save_outage_test.rb TP_#{__LINE__}: new: #{outage.new_record?}, changed: #{outage.changed?} active_changed: #{outage.active_changed?} active: #{outage.active}"
      if !odef[:changed] && !odef[:active_changed] && odef[:active]
        # nothing needed to do
      elsif odef[:changed] && !odef[:active_changed] && odef[:active]
        outage.description = "a description"
      elsif odef[:changed] && odef[:active_changed] && !odef[:active]
        outage.active = false
      end
    end
    outage
  end
end
