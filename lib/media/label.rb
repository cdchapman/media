module Media
  class Label
    def initialize(args)
      @name = args.fetch(:name, [])
    end
      
    def to_s
      "[#{@name}]"
    end
  end
end