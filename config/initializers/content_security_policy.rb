Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  policy.img_src     :self, :https, :data
  policy.font_src    :self, :https, :data
  policy.frame_ancestors :none
end
