require 'slim'
require 'yaml'
require 'fileutils'

Dir.chdir "talks"
BASE_PATH = ".."

def render_partial(name, attributes={})
   Slim::Template.new("#{BASE_PATH}/templates/#{name}.slim").render(Object.new, attributes)
end

volumes = (Dir.glob "*.yaml").map do |filename|
	volume = YAML.load_file(filename)
	volume["id"] = filename.gsub(".yaml", "")
	volume
end

volumes.each do |volume|
	volume["talks"].each do |talk|
		siblings = volume["talks"] - [talk]
		content = Slim::Template.new("#{BASE_PATH}/templates/talk.slim", {:pretty => true}).render(Object.new, talk: talk, volume: volume["id"], siblings: siblings, size: volume["video_size"])
		File.open("#{BASE_PATH}/output/#{talk["slug"]}.html", "w") { |file| file.write(content) }
	end
end

# Generate index file
content = Slim::Template.new("#{BASE_PATH}/templates/index.slim").render(Object.new, volumes: volumes)
File.open("#{BASE_PATH}/output/index.html", "w") { |file| file.write(content) }

# Copy assets -- TODO: minify stylesheets
FileUtils.cp_r "#{BASE_PATH}/assets", "#{BASE_PATH}/output/"
