# ios-takehome-project

NetworkManager
-----------------------
It is a singleton that is responsible for making all the network calls using URLSession. It also includes an option to cancel all pending requests.

AddressViewController
------------------------
This View Controller is the initial view Controller and is responsible for selecting user's current location. User can drag the map to change the annotation view and the selected location. User can also tap anywhere on the map to select a location. In case of no internet, user's current location would be shown but "Confirm Address" button would be disabled. Once the internet is back, "Confirm Address" button would re-enable.

ExploreViewController
------------------------
This View Controller displays all the nearby restaurants for the selected location. If no restaurants are retrieved, appropriate alert view would be shown to the user.

ExploreViewModel
------------------------
This View Model is used by Explore View Controller to fetch all nearby restaurants and other updates.

NearbyRestaurantCell
-------------------------
This TableViewCell displays the fetched restaurant and its details

RawServerResponse
-------------------------
RawServerResponse represents fetched server response from DoorDash Api with only relevant keys.

Restaurant
-------------------------
Restaurant is an object to represent custom restaurant object generated from RawServerResponse.

DoorDashError
--------------------------
This struct represents custom errors for this application.

Resource
--------------------------
This struct is a wrapper struct to encapsulate endpoint url, request method and parse method to convert custom object from Data.

Cache
--------------------------
This NSCache wrapper represents cache for restaurant thumbnail images.

Location
--------------------------
This struct represents CLLocationCoordinate2D, street and city.

Other Notes
--------------------------
1. I did not use any third-party libraries as AFNetworking as it seemed like a very big hammer to hit a tiny nail (our requirements can be easily satisfied by URLSession data tasks)

2. As I explained on the introductory call with Anderthen, I did not write any it tests because currently my team does not write unit tests so I am very new to unit tests. This is something that I am interested in learning while working with individuals who are doing it on regular basis.
