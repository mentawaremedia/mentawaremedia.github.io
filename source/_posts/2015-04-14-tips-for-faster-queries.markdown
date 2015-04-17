---
layout: post
title: "tips for faster queries"
date: 2015-04-14 19:54:54 -0500
comments: true
categories: [programming]
tags: [postgres, rails, ruby, ror]
---


{% img right /images/fast_snail.jpg 300 %}

For the last few weeks I've been busy at work optimizing many of our
slowest queries. On my last Rails related post I covered a work around for 
PostgreSQL's inherit slowness with COUNT queries. On this post I'm covering 
some common tips for speeding up general queries. 

We'll start by looking at some code.


``` ruby
#app/serializers/business_serializer.rb
class BusinessSerializer < ActiveModel::Serializer
  attributes :name, :zip
end

#app/controllers/businesses_controller#any_ten_records
Business.where("revenue + ? = ?", params[:amount], 100).order(:created_at).to_a.first(10)

```

In the code above I use [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers)
to describe which model attributes will be serialized into JSON. If you are unfamiliar
with this gem consider reading up on it. It's pretty handy for DRYing up your code. The
database I am using is PostgreSQL.


##Don't SELECT *

``` ruby

#Business.where("revenue + ? = ?", params[:amount], 100).order(:created_at).to_a.first(10)
Business.select(:name, :zip)
  .where("revenue + ? = ?", params[:amount], 100)
  .order(:created_at)
  .to_a
  .first(10)

```

The serailizer tells me that the only thing I need to return is `business#name` 
and `business#zip`. The more record columns you request data on, the slower your
query might run as it will use more Network I/O and sometimes Disk I/O. 
You could boost performance by selecting only the columns you require.


##Filter Rows With Limit

``` ruby

#Business.select(:name, :zip)
#  .where("revenue + ? = ?", params[:amount], 100)
#  .order(:created_at)
#  .to_a
#  .first(10)
Business.select(:name, :zip)
  .where("revenue + ? = ?", params[:amount], 100)
  .limit(10)
  .order(:created_at)

```

We can see from `#first(10)` that we are only interested in returning the first
ten records we fetched from the query. We could potentially and unnecessarily 
request a huge record set and consume a ton of memory by instantiating those 
records as ActiveRecord objects.

##Avoid Sorting

``` ruby

#Business.select(:name, :zip)
#  .where("revenue + ? = ?", params[:amount], 100)
#  .limit(10)
#  .order(:created_at)
Business.select(:name, :zip)
  .where("revenue + ? = ?", params[:amount], 100)
  .limit(10)

```

Sorting is sometimes unavoidable but we should try not to utilize it when
possible. The `ORDER BY` generated will consume sorting memory on the server. 
In cases where memory becomes scarce on the server, it will spill over to
disk making it painfully slow.

##Don't Accidentally Skip Using an Index

``` ruby

#Business.select(:name, :zip)
#  .where("revenue + ? = ?", params[:amount], 100)
#  .limit(10)
Business.select(:name, :zip)
  .where("revenue = ? - ?", 100, params[:amount])
  .limit(10)

```

If the businesses table is using an index on the field revenue, the original code
would skip using the index. To take advantage of the index we need to shift the
calculation from the left hand side of the equation to the right hand side.

Thank you for coming by. Feel free to share and comment below.
