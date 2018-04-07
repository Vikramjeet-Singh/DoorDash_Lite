## Intro
The Restaurant API gives you access to a list of restaurants (say “Amarin Thai Cuisine”).

Note: that authentication is not required for the restaurant API endpoints.
Note: URL’s end with slash (or you’ll get a 301)
Note: These are our actual API’s, so there’ll be a lot more information/fields in the resources
than what you actually need.

## API Reference

_RootURL_: https://api.doordash.com/

**v1/store_search/?lat=37.42274&lng=-122.139956**

_return a list of store objects available for delivery at a given location_

- params
  - lat: latitude of the delivery address
  - lng: longitude of the delivery address
  
- important fields:
  - id: primary key
  - name: name of the store
  - description: description of the store
  - delivery_fee: the cost of delivery, in cents
  - cover_img_url: URL to icon image of the store
  - asap_time: estimated delivery time, in minutes
  
_Ex: https://api.doordash.com/v1/store_search/?lat=37.42274&lng=-122.139956_

