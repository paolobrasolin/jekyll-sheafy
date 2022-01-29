require "geo_pattern"

class GeoPatternGenerator < Jekyll::Generator
  def generate(site)
    name = site.config.fetch("github").fetch("repository_name")
    site.data["geo_pattern"] = GeoPattern.generate(name).to_data_uri
  end
end
