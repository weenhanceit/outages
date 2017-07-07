require "test_helper"

class OutageTest < ActiveSupport::TestCase
  test "validators" do
    outage = Outage.new
    assert_not outage.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist",
      # "Active can't be blank", The default scope sets this.
      "Causes loss of service can't be blank",
      "Completed can't be blank"
    ], outage.errors.full_messages.sort
  end

  test "default scope returns only active" do
    assert_equal 13, Outage.count
  end

  test "default scope sets value on new" do
    outage = Outage.new
    assert outage.active
  end

  test "default scope sets value on create" do
    outage = Outage.create(causes_loss_of_service: true,
                           completed: false,
                           account: accounts(:company_b))
    assert outage.active
  end

  test "default scope sets value on save" do
    outage = Outage.new(causes_loss_of_service: true,
                        completed: false,
                        account: accounts(:company_b))
    assert outage.save
    assert outage.active
  end

  test "find respects default scope" do
    assert_raises ActiveRecord::RecordNotFound do
      Outage.find(outages(:company_a_outage_inactive).id)
    end
  end

  test "outage exactly one day" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      start_time = Time.zone.local(2017, 7, 1, 0, 0, 0)
      end_time = Time.zone.local(2017, 7, 2, 0, 0, 0)
      outage = Outage.new(start_time: start_time, end_time: end_time)

      assert_equal start_time, outage.start_time_on_date(start_time.to_date)
      assert_equal end_time, outage.end_time_on_date(start_time.to_date)
    end
  end

  test "outage two days" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      start_time = Time.zone.local(2017, 7, 1, 0, 0, 0)
      end_time = Time.zone.local(2017, 7, 2, 0, 0, 1)
      outage = Outage.new(start_time: start_time, end_time: end_time)

      assert_equal start_time,
        outage.start_time_on_date(Time.zone.local(2017, 7, 1).to_date)
      assert_equal start_time + 1.day,
        outage.end_time_on_date(Time.zone.local(2017, 7, 1).to_date)

      assert_equal end_time.beginning_of_day,
        outage.start_time_on_date(Time.zone.local(2017, 7, 2).to_date)
      assert_equal end_time,
        outage.end_time_on_date(Time.zone.local(2017, 7, 2).to_date)
    end
  end

  test "outage three days" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      start_time = Time.zone.local(2017, 6, 30, 23, 59, 59)
      end_time = Time.zone.local(2017, 7, 2, 0, 0, 1)
      outage = Outage.new(start_time: start_time, end_time: end_time)

      assert_equal start_time,
        outage.start_time_on_date(Time.zone.local(2017, 6, 30).to_date)
      assert_equal (start_time + 1.day).beginning_of_day,
        outage.end_time_on_date(Time.zone.local(2017, 6, 30).to_date)

      assert_equal Time.zone.local(2017, 7, 1).beginning_of_day,
        outage.start_time_on_date(Time.zone.local(2017, 7, 1).to_date)
      assert_equal Time.zone.local(2017, 7, 2).beginning_of_day,
        outage.end_time_on_date(Time.zone.local(2017, 7, 1).to_date)

      assert_equal Time.zone.local(2017, 7, 2).beginning_of_day,
        outage.start_time_on_date(Time.zone.local(2017, 7, 2).to_date)
      assert_equal end_time,
        outage.end_time_on_date(Time.zone.local(2017, 7, 2).to_date)
    end
  end

  test "outage before date" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      start_time = Time.zone.local(2017, 7, 1, 0, 0, 0)
      end_time = Time.zone.local(2017, 7, 2, 0, 0, 0)
      outage = Outage.new(start_time: start_time, end_time: end_time)

      assert_raises ArgumentError do
        outage.start_time_on_date(Time.zone.local(2017, 7, 2).to_date)
      end
      assert_raises ArgumentError do
        outage.end_time_on_date(Time.zone.local(2017, 7, 2).to_date)
      end
    end
  end

  test "outage after date" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      start_time = Time.zone.local(2017, 7, 1, 0, 0, 0)
      end_time = Time.zone.local(2017, 7, 2, 0, 0, 0)
      outage = Outage.new(start_time: start_time, end_time: end_time)

      assert_raises ArgumentError do
        outage.start_time_on_date(Time.zone.local(2017, 6, 30).to_date)
      end
      assert_raises ArgumentError do
        outage.end_time_on_date(Time.zone.local(2017, 6, 30).to_date)
      end
    end
  end

  test "became_complete" do
    outage = outages(:company_a_outage_a)
    # Ensure that completed is in the state we expect
    outage.completed = false
    outage.save

    outage.completed = true
    assert outage.became_completed?
    assert_not outage.became_incompleted?

    outage.save
    outage.completed = false
    assert_not outage.became_completed?
    assert outage.became_incompleted?
  end

  test "became_active" do
    outage = outages(:company_a_outage_a)
    # Ensure that completed is in the state we expect
    outage.active = false
    outage.save

    outage.active = true
    assert outage.became_active?
    assert_not outage.became_inactive?

    outage.save
    outage.active = false
    assert_not outage.became_active?
    assert outage.became_inactive?
  end

  test "only completed changed" do
    outage = outages(:company_a_outage_a)
    # Ensure that completed is in the state we expect
    outage.completed = false
    outage.save

    outage.completed = true
    assert outage.only_completed_changed?

    outage.save
    outage.completed = false
    outage.name = "#{outage.name} changed!"
    assert_not outage.only_completed_changed?
  end

end
