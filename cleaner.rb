s = Time.now.to_i

require 'yaml'

DATA_FOLDER = File.join(File.dirname(__FILE__), 'data')
FileUtils.mkdir_p(DATA_FOLDER)

m = false

Dir.new(DATA_FOLDER).each do |f|
  c = File.join(DATA_FOLDER, f)
  next if ! File.file?(c)
  ex = YAML::load(File.open(c, 'r'))['expire'] || 0

  if ex - Time.now.to_i < 0
    m = true
    puts "Deleting #{c}"
    File.unlink(c)
  end
end

e = Time.now.to_i
puts "Finished in #{e -s } seconds." if m