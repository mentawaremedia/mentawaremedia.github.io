---
layout: post
title: "Faster Count Queries"
date: 2015-04-07 16:11:47 -0500
comments: true
categories: [programming]
tags: [postgres, rails, ruby, ror]

card_type: summary
card_title: "Faster Count Queries"
card_site: "@terminalbreaker" 
card_description: "PostgreSQL's slow COUNT troubling you?"
card_image: "http://www.verygoodindicators.com/images/cheetah_still.jpg"
card_url: "http://www.verygoodindicators.com/blog/2015/04/07/faster-count-queries/"
---

{% img right /images/cheetah_still.jpg 150 %}

Some of you have noticed that PostgreSQL's count performs painfully slow on tables
of any significant size. If you're looking for a quick solution and you don't
care about super exact numbers on the count then I'll show you what I did.

The reason counts are so slow in postgres has to do with the way Multi-Version 
Concurrency Control(MVCC) has been implemented in the 
[product](http://wiki.postgresql.org/wiki/Slow_Counting). Since multiple transactions
can see different states of the data then there can be no straightforward way for "COUNT(*)"
to summarize data across the whole table. As a result postgres must walk through all rows
in a sense.

I found an interesting article on how to accomplish a much faster, although less accurate
count by tapping into the EXPLAIN output through a custom [function](https://wiki.postgresql.org/wiki/Count_estimate).
I'll walk you through the steps I took.

``` sql count_estimate function
CREATE FUNCTION count_estimate(query text) RETURNS integer AS
$func$
DECLARE
    rec   record;
    rows  integer;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN rows IS NOT NULL;
    END LOOP;
 
    RETURN rows;
END
$func$ LANGUAGE plpgsql;
```

Above is the create query for out SQL function that we'll need to create on the server. 
First we'll create a migration to hold our function creation statement.

``` ruby migration
#run this at the console first
#  bundle exec rails g migration AddCountEstimateFunction
 

class AddCountEstimateFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION count_estimate(query text) RETURNS integer AS
      $func$
      DECLARE
          rec   record;
          rows  integer;
      BEGIN
          FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
              rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
              EXIT WHEN rows IS NOT NULL;
          END LOOP;
       
          RETURN rows;
      END
      $func$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute "DROP FUNCTION count_estimate(query text);"
  end
end
```

After we run `bundle exec rake db:migrate` the function will be available for use.

``` ruby
ActiveRecord::Base.connection.execute("SELECT count_estimate('#{sql_query}')")

#Example:
#  sql_query = "SELECT * FROM businesses WHERE size > 3"
#  ActiveRecord::Base.connection.execute("SELECT count_estimate('#{sql_query}')").to_a
#
#returns
#  [{"count_estimate" => "500"}]
```

The snippet above shows how you would now use this SQL function

``` ruby
class Business < ActiveRecord::Base

  def comment_count
    #This will return an estimate but not exactly the real number
    ActiveRecord::Base.connection.execute("SELECT count_estimate('#{comments_sql_string}')").first["count_estimate"].to_i
  end  

  def comments_sql_string
    <<-SQL
      SELECT * FROM comments 
      WHERE comments.business_id = #{self.id} 
        AND comments.status = ''new''
    SQL
  end
end

#Business.last.comment_count
#
#=> 9
```

Finally, here is a more fleshed out implementation. Just a note, but make sure you character escape
those single quotes by using two single quotes `''` otherwise you'll get a SQL error on the syntax.

If this was useful then please share on your social media connections. I also like hearing
any suggestions and comments so feel free to drop some below.
