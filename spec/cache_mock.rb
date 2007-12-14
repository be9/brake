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
    end.any_number_of_times

    Brake.cache = @cache
  end
end
