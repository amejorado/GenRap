module ApplicationHelper
  def flash_notifications
    message = flash[:error] || flash[:notice]

    return unless message
    type = flash.keys[0].to_s
    javascript_tag %{$.notification({ message:"#{message}", type:"#{type}" });}
  end
end
