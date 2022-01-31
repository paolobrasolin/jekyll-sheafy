Node = Struct.new(:site, :data, :content, keyword_init: true) do
  def ==(other)
    self.__id__ == other.__id__
  end

  alias eql? ==
end
Site = Struct.new(:config, keyword_init: true)
