require 'mongo'

module MongoList
  class MongoListError < StandardError
  end

  def self.connect(*connection_settings)
    @connection = Mongo::Connection.new(*connection_settings)
  end

  # create the directory hierarchy for mongo browsering
  #
  # path can be:
  # /
  # /database_name/
  # /database_name/collection/
  # /database_name/collection/_id
  # /database_name/collection/_id/field
  #
  # This is a bit convoluted but here goes:
  #   Jquerytree requires '/' as the delimiter. So mongo has some issues with this.
  #   * database names can't have / so we are ok there
  #   * collection names can have '/', but not $, so we use the $ to escape the /'s in the collection name
  #   * The _id can be String or BSON::ObjectId which is stripped by to_s, so I added an extra path $String or $BSON::ObjectId
  #   * The _id is assumed to be everything after the type match (which is the 4th '/')
  #   * Finally, the _id name can have '/''s and $'s etc, but it can't have '.', so I use that around the key name so when it's posted it makes sense.
  #       - then take /1/2/3/type_of_id/this is the _id/.key.
  #       - take 4 slashes down to get start of _id
  #       - work updwards removing the .key.
  #       - all you got left is the id. _wheh_
  #
  def self.list_dir(root, path, show_hidden = false)
    split_char = root
    puts "path = (#{path})"
    results = []
    slashes = path.split(split_char)
    puts "split up = #{slashes.inspect}"
    if slashes.size <= 1
      # nothing yet so we need to list the databases  (slash is illegal in database name so no worries)
      @connection.database_info.each do |info|
        results << { :abs_dir => "/#{info[0]}/", :rel_dir => "#{info[0]}" }
      end
    elsif slashes.size == 2
      #  database name given so list the collections
      db = @connection.db("#{slashes[1]}")
      db.collection_names.each do | name |
        e_name = escape_slashes(name)
        results << { :abs_dir => "/#{slashes[1]}/#{e_name}/", :rel_dir => "#{name}"}
      end
    elsif slashes.size == 3
      # list all the _id's in the collection
      db = @connection.db("#{slashes[1]}")
      puts "open collection #{slashes[2]}"
      ue_name = unescape_slashes(slashes[2])
      collection = db.collection(ue_name)
      collection.find().sort([['_id', -1 ]]).limit(20).each do | r |
        id_type = r['_id'].class
        results << { :abs_dir => "/#{slashes[1]}/#{slashes[2]}/$#{id_type}/#{r['_id']}/", :rel_dir => "#{r['_id']}" }
      end
    elsif slashes.size >= 4
      # list all the fields in the things as files!
      #  _id's can have '/' in name ... so!! this is fun. They can also have $ in them. - so just take the last thing :)
      db = @connection.db("#{slashes[1]}")
      ue_name = unescape_slashes(slashes[2])
      collection = db.collection("#{ue_name}")
      id_type = slashes[3]
      rejoin = slashes[0,4].join('/')
      id_part = path[rejoin.length + 1, path.length - rejoin.length - 2]
      puts "id_part = #{id_part}"
      if id_type =~ /BSON/
        r = collection.find_one( { '_id' => BSON::ObjectId( id_part ) } )
      else
        r = collection.find_one( { '_id' => id_part  } )
      end
      # field names can't have a period! So that's how you can find the field name from the end
      r.each do |key, value|
        results << { :file_ext => "txt", :abs_file => "/#{slashes[1]}/#{slashes[2]}/#{slashes[3]}/#{r['_id']}/.#{key}.", :rel_file => "#{key} : #{value}" }
      end
    else
      raise MongoListError, "wtf"
    end
    results
  end

  def self.escape_slashes(name)
    name.gsub('/','$')
  end

  def self.unescape_slashes(name)
    name.gsub('$','/')
  end

end
