---
layout: post
title: "ruby constructors"
date: 2015-03-15 13:24:08 -0500
comments: true
categories: [programming]
tags: [ruby, constructors]
---



``` vb.net Visual Basic .NET
'Visual Basic .NET
Dim sf As BaseballTeam = New BaseballTeam("San Francisco Giants")

'Dim - Allocates space for one or more variables
'As  - Identifies a data type in a declaration
'New - Creates a new object instace
```

``` ruby Ruby
#Ruby
sf = BaseballTeam.new("San Francisco Giants")

#Ruby is not strictly typed so there's no need to identify the data type.
#Object.new is a class method which allocates space and create an instance of the class.
```

Many languages use a 'new' keyword which Ruby does not have to create an object instance.
Ruby instead provides a method 'new' which is called directly on a class.

##Ruby Constructor Responsibilities 

The Ruby Constructor has three jobs. 

* It allocates space for the object
* It assigns instances variables their initial values
* It returns the instance of that class

``` ruby Ruby Constructor Responsibilities
class Foo
  def initialize(bar, biz)
    @bar = bar
    @biz = biz
  end
end

foo = Foo.new("a", "b")
```

Wait a second!? Why are we talking about 'initialize' all of a sudden? 
I thought we were talking about 'new'?

## #initialize vs .new

``` ruby #initialize vs .new
class Foo 
#         /-- defined as an instance method
#        /
  def initialize(bar, biz)
    @bar = bar
    @biz = biz
  end
end

#           /-- called on the class thus it's a class method
#          /
foo = Foo.new("a", "b")
```

* \#initialize is an instance method 
* .new is a class method  

To clarify, .new is the ruby constructor not the instance method #initialize. Remember, 
the constructor performs three actions. 

* It allocates space for a new instance of the class
* It assigns instances variables their initial values
* It returns the instance of that class

The class method .new performs these actions, not #initialize which is used for 
assigning instances variables their initial values.

We can implement our own version of the .new method to illustrate how it might 
accomplish this.

``` ruby Ruby
class Foo
  def self.new_object(*args)

#                  /-- allocates a new instance of the class.
#                 /    It does not call initialize
    instance = allocate

#         /-- pass the arguments over to #initialize in order to 
#        /    to set instance variables
    instance.send(:initialize, *args)

#       /-- return the instance of this class    
    instance
  end

  def initialize(bar, biz)
    @bar = bar
    @biz = biz
  end
end
```

``` irb Console Output 
#                                   /- as you can see the standard .new method and
#                                  /   our implementation both return instances of the
#                                 /    class and set the instance variables
>> Foo.new(1,2)        #=> #<Foo:0x007fac3e15d0a0 @bar=1, @biz=2>
>> Foo.new_object(1,2) #=> #<Foo:0x007fac3e206420 @bar=1, @biz=2>
```

As you can see above, our own custom constructor is functionally equivalent 
to the default constructor. Both constructors return an instance of class Foo 
with their instance variables set. This knowledge can help us do some pretty neat things.

##Constructor overloading...sort of

``` vb.net Constructor overloading in Visual Basic .NET
Public Class Vehicle
    Private m_Wheels As Integer

'        /- default constructor
    Sub New()                                  
        m_Wheels = 4
    End Sub

'        /- overloaded constructor
    Sub New(ByVal NumberOfWheels As Integer)   
        m_Wheels = NumberOfWheels
    End Sub

    Public Property NumberOfWheels()
        Get
            Return m_Wheels
        End Get
        Set(ByVal Value)
            m_Wheels = Value
        End Set
    End Property

End Class
```

One of the things I used to miss when I started working in Ruby was the ability to 
overload constructors. Strictly speaking, overloading uses the same constructor 
method name but uses a different signature or parameter list which you can't do in
Ruby. 

``` ruby Overloading constructors in Ruby
class Circle
  attr_accessor :radius, :area

  #=> Custom Constructors
  def self.new_by_radius(*args)
    circle = allocate
    circle.init_radius(*args)
    circle
  end

  def self.new_by_area(*args)
    circle = allocate
    circle.init_area(*args)
    circle    
  end

  #=> Custom Initializers
  def init_radius(_radius)
    @radius = _radius * 1.0
    @area = 3.14 * (@radius ** 2)
  end

  def init_area(_area)
    @area = _area * 1.0
    @radius = Math.sqrt(@area / 3.14)
  end
end
```

``` irb Console Output 
>> Circle.new_by_radius(10) #=> #<Circle:0x007fe77523d598 @radius=10.0, @area=314.0>
>> Circle.new_by_area(314)  #=> #<Circle:0x007fe7752e6f08 @radius=10.0, @area=314.0>
```
We can accomplish a similar goal by creating our own custom constructors.
Then we can see our custom constructors in action above.

##Summary

The ruby constructor performs 3 jobs; allocates space, assigns 
instance variables and returns the instance. The method .new is a class method and
constructor; #initialize is an instance method used to assign instance variables.
You can write your own constructors for fun and profit.

Feel free to drop some comments or questions below. And if you liked it then
please share on twitter, facebook or your prefered social media channel.
