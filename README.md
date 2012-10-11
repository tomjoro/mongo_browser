Mongo Browser using JQueryFileTree running on Sinatra

This application allows you to browse your mongo database in hierarchical tree view fashion.

It uses the JQueryFileTree to show the mongo databse

It can browse:
  * databases
  * collections
  * objects in collection (the _id's of the last 20 greatest _id's are shown by default)
  * fields

The values refesh everytime you open the folder. So if you collection is updated, if you close and repoen the folder the updates will be seen.

## Installation

This Is is a standalone project, and doesn't really require anything much except sinatra. It runs with Ruby > 1.9.2 and Sinatra.

```sh
gem install mongo
gem install sinatra
```

Open up the config.ru file and set the database configuration parameters
```ruby
 set :mongo_connection, 'localhost'
```

## Running

```sh
rackup config.ru
```

## Notes

 Browsing mongo is harder than I expected!


path can be:
```sh
/
/database_name/
/database_name/collection/
/database_name/collection/_id
/database_name/collection/_id/field
```

This is a bit convoluted but here goes:
  JQueryFiletree requires '/' as the delimiter. So mongo has some issues with this.
  * **database names** can't have / so we are ok there
  * **collection names** can have '/', but not $, so we use the $ to escape the /'s in the collection name
  * The **_id** can be String or BSON::ObjectId which is stripped by to_s, so I added an extra path $String or $BSON::ObjectId
  	  - The **_id** is assumed to be everything after the type match (which is the 4th '/')
  * Finally the *field_name* can have everything except '.' in it's name so I surround it with '.''s
      - then take /1/2/3/type_of_id/this is the _id/.key.
      - take 4 slashes down to get start of _id
      - work updwards removing the .key.
      - all you got left is the id. _wheh_


## Tests





