# Purpose: Extracts subdomain from request object. If subdomain is not present in request object, it tries to extract it from host. If host is not present, it returns nil.
class SubdomainExtractor
    def self.extract(request)
      subdomain = request.subdomain.presence || 
                  request.params[:subdomain] ||
                  extract_from_host(request.host)
      Rails.logger.debug "Extracted subdomain: #{subdomain}"
      subdomain
    end
  
    private
  
    def self.extract_from_host(host)
      return nil unless host
      if host =~ /^(.+)\.(lvh\.me|yourdomain\.com)$/
        $1
      end
    end
  end