require "test_helper"

class CiTest < ActiveSupport::TestCase
  test "validate presence of active" do
    ci = Ci.new # (account: accounts(:company_a))
    assert_not ci.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist",
      "Name can't be blank"
      # "Active can't be blank" Default scope means this doesn't happen.
    ], ci.errors.full_messages.sort
  end

  test "available_for_parents on new includes all" do
    ci = Ci.new(account: @account)
    assert_equal [
      @greatgrandparent,
      @grandparent,
      @parent,
      @ci,
      @child,
      @grandchild,
      @greatgrandchild,
      @unrelated
    ].sort,
      ci
        .available_for_parents
        .select { |x| x.css_class.nil? }
      .sort
  end

  test "ancestors" do
    assert_equal [
      @greatgrandparent,
      @grandparent,
      @parent
    ].sort,
      @ci
        .ancestors
        .select { |x| x.css_class.nil? }
      .sort
  end

  test "available_for_parents includes grandparent and greatgrandparent" do
    assert @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@grandparent)
    assert @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@greatgrandparent)
  end

  test "available_for_parents doesn't include parent" do
    assert_not @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@parent)
  end

  test "available_for_parents doesn't include child" do
    assert_not @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@child)
  end

  test "available_for_parents doesn't include grandchild" do
    assert_not @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@grandchild)
  end

  test "available_for_parents doesn't include self" do
    assert_not @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@ci)
  end

  test "available_for_parents includes unrelated" do
    assert @ci
      .available_for_parents
      .select { |x| x.css_class.nil? }
      .include?(@unrelated)
  end

  test "descendants" do
    assert_equal [
      @greatgrandchild,
      @grandchild,
      @child
    ].sort,
      @ci
        .descendants
        .select { |x| x.css_class.nil? }
      .sort
  end

  test "available_for_children on new includes all" do
    ci = Ci.new(account: @account)
    assert_equal [
      @greatgrandparent,
      @grandparent,
      @parent,
      @ci,
      @child,
      @grandchild,
      @greatgrandchild,
      @unrelated
    ].sort,
      ci
        .available_for_children
        .select { |x| x.css_class.nil? }
      .sort
  end

  test "available_for_children doesn't include grandparent" do
    assert_not @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@grandparent)
  end

  test "available_for_children doesn't include parent" do
    assert_not @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@parent)
  end

  test "available_for_children doesn't include child" do
    assert_not @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@child)
  end

  test "available_for_children includes grandchild and greatgrandchild" do
    assert @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@grandchild)
    assert @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@greatgrandchild)
  end

  test "available_for_children doesn't include self" do
    assert_not @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@ci)
  end

  test "available_for_children includes unrelated" do
    assert @ci
      .available_for_children
      .select { |x| x.css_class.nil? }
      .include?(@unrelated)
  end

  test "outages list is complete for a ci" do
    expected_outages = [make_outage, make_outage]
    other_outage = make_outage

    expected_outages[0].cis << @ci
    expected_outages[0].save!
    expected_outages[1].cis << @grandchild
    expected_outages[1].save!
    other_outage.cis << @parent
    other_outage.save!

    assert_equal expected_outages.sort, @ci.affected_by_outages.sort
  end

  def setup
    @account = Account.new(name: "No CIs")
    @ci = Ci.create(account: @account, name: "Me")
    @unrelated = Ci.create(account: @account, name: "Unrelated")
    @parent = @ci.parents.create(account: @account, name: "Parent")
    @grandparent =
      @parent.parents.create(account: @account, name: "Grandparent")
    @greatgrandparent =
      @grandparent.parents.create(account: @account, name: "Great-grandparent")
    @child = @ci.children.create(account: @account, name: "Child")
    @grandchild = @child.children.create(account: @account, name: "Grandchild")
    @greatgrandchild =
      @grandchild.children.create(account: @account, name: "Great-grandchild")
  end

  def make_outage(start_time = Time.zone.now.round)
    @account.outages.build(name: "Outage",
                           start_time: start_time,
                           end_time: start_time + 30.minutes,
                           causes_loss_of_service: true,
                           completed: false)
  end

end
