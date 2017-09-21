require "test_helper"
require "helpers/set_config_02.rb"
class SaveUserTest < ActionMailer::TestCase
  include TestCases
  test "save a new valid user" do
    user = User.new(account: accounts(:company_a),
                    name: "Mr User",
                    email: "user@mydomain.com",
                    password: "password1")

    assert Services::SaveUser.call(user)
  end

  test "save a new invalid user" do
    user = User.new()
    assert_not Services::SaveUser.call(user)
  end

  test "save an existing but now invalid user" do
    user = users(:basic)
    assert user.valid?
    user.email = nil
    assert_not Services::SaveUser.call(user)
  end

  test "change of preference to immediate email causes sends email" do
    user = setup_config02("Our Test Account")
    assert_difference "Notification.where(notified: false).size", -1 do
      assert_emails 1 do
        user.preference_individual_email_notifications = true
        assert Services::SaveUser.call(user)
      end
    end
  end


  private

  def get_an_outage(odef={})
    # Create a valid outage and save it
    # This method only deals with unchanged or changed outages
    outage = Outage.create(account: accounts(:company_a),
                           causes_loss_of_service: true,
                           completed: false)
    assert outage.save

    if !odef[:changed]
      # No changes needed
    else
      if !odef[:became_completed] && odef[:became_incompleted] &&
         odef[:only_completed]

        outage.completed = true
        outage.save
        outage.completed = false
      elsif odef[:became_completed] && !odef[:became_incompleted] &&
            odef[:only_completed]

        outage.completed = true
      elsif !odef[:became_completed] && !odef[:became_incompleted] &&
            !odef[:only_completed]

        outage.name = "#{outage.name} changed!"
      elsif !odef[:became_completed] && odef[:became_incompleted] &&
            !odef[:only_completed]

        outage.completed = true
        outage.save

        outage.completed = false
        outage.name = "#{outage.name} changed!"
      elsif odef[:became_completed] && !odef[:became_incompleted] &&
            !odef[:only_completed]

        outage.completed = true
        outage.name = "#{outage.name} changed!"
      end
    end


    # Check our outage is in the expected state
    # puts "Inspect odef: #{odef.inspect}"
    assert_equal (odef[:changed] ? true : false), outage.changed?
    assert_equal (odef[:became_completed] ? true : false), outage.became_completed?
    assert_equal (odef[:became_incompleted] ? true : false), outage.became_incompleted?
    assert_equal (odef[:only_completed] ? true : false), outage.only_completed_changed?

    outage
  end

end
