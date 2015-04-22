---
layout: post
title: "Why ActiveRecord Sucks"
date: 2015-04-20 21:49:23 -0500
comments: true
categories: [programming]
tags: [rails, ruby, ror] 

card_type: photo
card_title: "Why ActiveRecord Sucks"
card_site: "@terminalbreaker" 
card_description: "Let's face it. ActiveRecord has a lot of problems."
card_image: "http://www.verygoodindicators.com/images/aww-man-this-topics-sucks.jpg"
card_url: "http://www.verygoodindicators.com/blog/2015/04/20/why-activerecord-sucks/"
---

{% img right /images/aww-man-this-topics-sucks.jpg 300 %}

Ok, so I took an old play from the American media and used a sensationalized 
title to get your attention. The fact is that I like ActiveRecord, I really do.
In fact I like it a little too much. 

If you haven't done so you should read my last blog post titled ['Easy vs Simple'](http://www.verygoodindicators.com/blog/2015/04/19/easy-vs-simple/).
It's an article very much inspired by a [talk](http://www.infoq.com/presentations/Simple-Made-Easy)
given by the creator of Clojure, Rich Hickey. The point my article and one of the many fine
points in Hickey's lecture attempts to make is that we as developers 
have become obsessed with this idea of 'easy'. So much are we enamored by it that 
we're trading it in for a vast amount of complexity and inefficiency. 

Giving you a little of my background, I've had the pleasure working for two very 
experienced and well known people in our profession. The first was Dave Thomas author 
of the Pickaxe Book and Hal Helms who is very well known in the ColdFusion community. 
I currently work for Hal and we have some fairly interesting discussions and arguements. 
One revolves around ORMs. He is very  much of the opinion that we should not 
use an ORM at all in Rails, at least he leans in that direction. While I am not such an 
extremist, I have been tempering my enthusiasm for ActiveRecord with recent real world 
experience dealing with performance issues.

##ActiveRecord is Fat
How fat? When ActiveRecord sits around the house, it sits AROUND the house. I know bad 
joke. Look, all the magic ActiveRecord does requires a significant amount
code which then leads to large amount of [memory](https://blog.engineyard.com/2009/thats-not-a-memory-leak-its-bloat/) 
used to spin up an instance. Spin up enough ActiveRecord instances that are not
garbage collected quick enough and the available memory on your box might be 
all consumed.

ActiveRecord instances do a lot: persistence, validation, query generation, domain logic
and more. Yes it makes things easy and possibly makes code more readable but you're adding 
complexity at least in the background. If you've ever run into a new deep ActiveRecord bug, 
good luck digging into that code for the first time.

##Your Classes Become Dependent on ActiveRecord 

Let compare two versions of code. One uses ActiveRecord, the other does not.

``` ruby With ActiveRecord
#app/service/foo.rb
class Foo 
  attributes :business

  #business is an ActiveRecord instance
  def initialize(business)
    @business = business
  end

  def run
    owners = business.owners

    owners.map(&:name)
  end
end

#app/service/biz.rb
Foo.new(Business.find(1)).run
```

``` ruby Without ActiveRecord
#app/service/foo.rb
class Bar 
  attributes :owners

  #owners is an Array of Hashes
  def initialize(owners)
    @owners = owners
  end

  def run
    owners.map {|owner| owner["name"]}
  end
end

#app/service/biz.rb
Bar.new(Business.find(1).owners.map(&:attributes)).run
```

The Foo class is dependent on ActiveRecord. In order to run my rspec
tests on this code I'll have to load rails. Foo also expects the business
object to respond to #owners and each instance of owner to respond to #name. 
This is quite a bit that we're asking Foo to know about the business object.
Foo is also sensitive to changes made to Business as well such that if we chose
to drop or rename the association to owners, the class would break.
A good article related to this is ["Tell, Don't Ask"](https://pragprog.com/articles/tell-dont-ask)
which warns about this type of inadvertent coupling.

What we should be sending Foo is data not an object containing data that then needs
to be queried through it's api. Yes, I know a Hash is still
an object but I'm speaking semantically. As you can see, Bar is given a Hash only.
There is no dependency on rails so my test can be run without loading rails and thus
can be run much faster. We no longer have the coupling we witnessed before.


##ActiveRecord is Lousy at Generating SQL

It's not the fault of ActiveRecord, ORMs all have their limits.
For simple queries it works fine. Realize though that as your queries become
more complex and intricate the worse the SQL will be that AR generates. There's
just no way an ORM can craft a highly optimized complex query better than an 
experienced engineer.

A backwards thing I catch myself doing sometimes is mentally figuring out how a non-trivial
query would be crafted in SQL and then I try to rewrite it into AR. I think at that point
I should do it in SQL.


##ActiveRecord, not so readable

``` ruby
class Report
  def execute
    result = ActiveRecord::Base.connection.execute(main_sql_string).to_a
  end

  #=> Main Query
  def main_sql_string
    <<-SQL
      SELECT businesses.name AS business_name, 
        COALESCE(offer.name, format('Campaign ID - %s',offer.id::text)) AS campaign_name, 
        COALESCE(user_replied.count,0) AS user_replied_count,
      FROM businesses
      INNER JOIN offer
        ON businesses.id = offer.business_id
      LEFT OUTER JOIN (#{user_replied_sql_string}) user_replied
        ON offer.id = user_replied.offer_id
    SQL
  end

  #=> Subqueries
  def user_replied_sql_string
    <<-SQL
      SELECT cc_links.offer_id AS offer_id, COUNT(*) AS count 
      FROM conversations
      INNER JOIN cc_links
        ON conversations.id = cc_links.conversation_id
      WHERE conversations.status = '#{Conversation::Status::REPLIED_TO}' 
      GROUP BY cc_links.offer_id
    SQL
  end
end
```

Take a look at code above. Can you imagine writing this in ActiveRecord. You'd
have various calls to #joins, #group, #select, #from plus a fair share
of SQL fragments strewn about. For me the code above appears far more legible 
that trying to express it in AR. 

The last point I like to make is that I think there's an illness going around.
It might be caused by overzealous enthusiasm, inexperience or unwavering conviction.
But I've seen it so many times; people become entranced with an ideal, rushing towards it 
like a month to flame without the slightest thought to consequence or foresight. Again
I'm a fan of ActiveRecord for the ease it brings but let's also consider the cost
as well.

Take Care.






