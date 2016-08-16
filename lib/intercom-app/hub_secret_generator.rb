require 'digest/sha1'

module IntercomApp
  module Utils

    def random_string
      (0...20).map { (65 + rand(26)).chr }.join
    end

    def random_hub_secret
      Digest::SHA1.hexdigest random_string
    end
  end
end
