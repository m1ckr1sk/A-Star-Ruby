Feature: End to end test

Scenario Outline: eating
  Given there is a "<start>" point
  And there is an "<end>" point
  And there is a "<map>"
  When I send a the data to the service
  Then I should have a "<route>" from start to end

  Examples:
    | start | end   | map                             | route                                         |
    |  0,0  |  9,9  | straight_route/map_10_clear.csv | straight_route/expected_straight_route_10.csv |