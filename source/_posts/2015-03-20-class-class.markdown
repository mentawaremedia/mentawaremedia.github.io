---
layout: post
title: "class Class"
date: 2015-03-20 20:53:35 -0500
comments: true
categories: [programming]
tags: [ruby, class Class]
---

This will post will be short and sweet; we'll cover the Ruby class Class. For
those unfamiliar with the class called Class, it is basically a Ruby object for creating 
Ruby classes. This comes in very handy when doing metaprogramming or writing code that
generates code.

``` ruby Typical Way of Creating a class
class Foo
  def hey
    "hey"
  end
end
```

Above you'll see the regular old way of creating a class in Ruby.

``` ruby Class Way of Creating a class
Foo = Class.new do
  def hey
    "hey"
  end
end
```

You can do the exact same thing using Class as the example above shows. Subclassing
can also be done very easily.

``` ruby Typical Way of Subclassing
class Bar < Foo

end
```

Above is how one would typically do subclassing. Class Bar inherits from class Foo.

``` ruby Class Way of Subclassing
Bar = Class.new(Foo)
```

And here is how it's accomplished with class Class.

A usual situation where I use Class is when I need to create custom errors. I think
we can all be code snobs from time to time (I hope it's not just me) so I maybe overly 
critical when I say the following. When people attempt to cram multiple lines of ruby 
code on one line using ';', a little piece of my dies.

``` ruby ...kill me now
class NameNotDefined < RuntimeError; end
```

Is it just me or is the above just painful to look at?

``` ruby A blissful expression
NameNotDefined = Class.new(RuntimeError)
```
Now isn't this so much better? I can now relax.

I hope it's been educational. Feel free to drop some comments or questions below. And if you liked it then
please share on twitter, facebook or your prefered social media channel.
