class JobCriteriaMatcher

  def initialize(message_criteria)
    @message_criteria = message_criteria
  end

  def matches_job_criteria(job_messages)

    matches = 0
    job_messages.each do |key,value|
      
      if @message_criteria.include?(key) then
        matches += 1
      end
    end
  
    return matches == @message_criteria.length
  end
end