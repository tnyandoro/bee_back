class SubdomainConstraint
    def self.matches?(request)
      # Match subdomains that are not blank and not 'www'
      request.subdomain.present? && request.subdomain != 'www'
    end
end
