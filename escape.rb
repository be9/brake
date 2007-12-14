# from http://www.gelato.unsw.edu.au/archives/git/att-17970/shpatch.rb
module Shell
  # Escape string string so that it is parsed to the string itself
  # E.g. Shell.escapeString("what's in a name") = "what\'s\ in\ a\ name"
  # Compare to Regexp.escape
  def Shell.escape(string)
    string.gsub(%r{([^-._0-9a-zA-Z/])}i, '\\\\\1')
  end
end
