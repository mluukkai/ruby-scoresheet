module ScoresHelper
  def format(score)
    return "pass" if score == true
    return "fail" if score == false
    ""
  end
end
