class AutoJobDetailSender
  def initialize(plumbing_adapter)
    @plumbing_adapter=plumbing_adapter
    @plumbing_adapter.register_topic('job_data')
  end
  
  def send_job
    @plumbing_adapter.send_message('job_data','{"message":"end_point", "job_id":"1","value":"x,9,y,9"}')
    sleep(5)
    @plumbing_adapter.send_message('job_data','{"message":"start_point", "job_id":"1","value":"x,0,y,0"}')
    sleep(5)
    @plumbing_adapter.send_message('job_data','{"message":"map", "job_id":"1","value":"0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n"}')
    @plumbing_adapter.close
  end
  
end