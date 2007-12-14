dir = File.dirname(__FILE__)

[".", ".."].each do |p|
  path = File.expand_path("#{dir}/#{p}")

  $LOAD_PATH.unshift path unless $LOAD_PATH.include? path
end
