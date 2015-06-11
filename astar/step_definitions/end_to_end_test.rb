require 'net/http'

Given(/^there is a "([^"]*)" point$/) do |start_point|
  @start_point = start_point.split(',')
end

Given(/^there is an "([^"]*)" point$/) do |end_point|
  @end_point = end_point.split(',')
end

Given(/^there is a "([^"]*)"$/) do |map_file|
  @map = File.read('spec/test_data/' + map_file)
  @map = @map.gsub(/\n/,"\\n")
end

When(/^I send a the data to the service$/) do
  start_message = '{"message":"start_point","job_id":"end_to_end","value":"x,'+@start_point[0]+',y,'+@start_point[1]+'"}'
  puts "START:#{start_message}"
  end_message = '{"message":"end_point","job_id":"end_to_end","value":"x,'+@end_point[0]+',y,'+@end_point[1]+'"}'
  puts "END:#{end_message}"
  map_message = '{"message":"map","job_id":"end_to_end","value":"'+@map+'"}'
  puts "MAP:#{map_message}"
  http = Net::HTTP.new('localhost',4567)
  req = Net::HTTP::Post.new('/message', initheader = {'Content-Type' =>'application/json'})
  req.body = start_message
  res = http.request(req)
  expect(res).to be_kind_of(Net::HTTPOK)
  req.body = end_message
  res = http.request(req)
  expect(res).to be_kind_of(Net::HTTPOK)
  req.body = map_message
  res = http.request(req)
  expect(res).to be_kind_of(Net::HTTPOK)
end

Then(/^I should have a "([^"]*)" from start to end$/) do |expected_route|
  http = Net::HTTP.new('localhost',8000)
  req = Net::HTTP::Get.new('/route_receiver/')
  res = http.request(req)
  file = res.body.scan(/end_to_end_\d{1,2}_\d{1,2}_\d{1,2}.html/).last
  req = Net::HTTP::Get.new('/route_receiver/'+file)
  res = http.request(req)
  route = res.body.match(/var items = \[(.*)\]/)
  expected = File.read('spec/test_data/' + expected_route)
  puts route
  puts expected
  #expect(res.body).to include('end_to_end')
end

