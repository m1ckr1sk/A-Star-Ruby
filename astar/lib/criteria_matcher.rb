class CriteriaMatcher

  def initialize(criteria)
    @criteria = criteria
  end

  def matches_criteria(messages)

    matches = 0
    messages.each do |key,value|
      if @criteria.include?(key) then
        matches += 1
      end
    end
  
    return matches == @criteria.length
  end
end