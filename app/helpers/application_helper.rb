module ApplicationHelper
  def logo(size="h2")
    link_to(root_path, class: "logo #{size}") do
      "<i class =\"bi bi-safe-fill me-2\"></i>SafePass".html_safe
    end
  end
  def account_page?
    current_page?(edit_user_registration_path)
  end
end
