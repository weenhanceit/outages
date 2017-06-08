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
    assert_equal 6, Outage.count
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
end
