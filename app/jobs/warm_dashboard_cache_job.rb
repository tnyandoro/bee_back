class WarmDashboardCacheJob < ApplicationJob
  def perform
    Organization.find_each do |org|
      Rails.cache.delete("dashboard:v5:org_#{org.id}") # or write fresh
      # Optionally: trigger build in background
    end
  end
end