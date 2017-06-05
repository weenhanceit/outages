class User
  def initialize(user_id)
    @user_id = (user_id || 'Basic User (Read Only)')
  end

  attr_reader :user_id

  def can_edit_outages?
    case
    when user_priviledge == "Domain Admin"
      true
    when user_priviledge == "User Admin (Manager)"
      true
    when user_priviledge == "Can Edit CIs/Outages"
      true
    else
      false
    end
  end

  def can_edit_cis?
    case
    when user_priviledge == "Domain Admin"
      true
    when user_priviledge == "User Admin (Manager)"
      true
    when user_priviledge == "Can Edit CIs/Outages"
      true
    else
      false
    end
  end


  def user_priviledge
    @user_id
  end

end
