module Brake
  class << self
    attr_accessor :cache
  end
end

module CacheMock
  def setup_cache
    @cache = mock('cache')
    @cache_hash = {'compilers' => {}}

    @cache.should_receive(:[]) do |arg|
      @cache_hash[arg]
    end.at_least(:once)

    Brake.cache = @cache
  end
end
