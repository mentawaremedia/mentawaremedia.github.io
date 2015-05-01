---
layout: post
title: "Yet Another Article About Ruby Closures"
date: 2015-04-28 19:23:52 -0500
comments: true
categories: [programming]
tags: [rails, ruby, ror] 

card_type: photo
card_title: "Yet Another Article About Ruby Closures"
card_site: "@terminalbreaker" 
card_description: "Some data on Blocks, Procs and Lambdas"
card_image: "http://www.verygoodindicators.com/images/closures_keyboard.jpg"
card_url: "http://www.verygoodindicators.com/blog/2015/04/28/yet-another-article-about-blocks/"
---

{% img right /images/closures_keyboard.jpg 300 %}

Today was the first day of company sponsored training on react.js, the new snazzy
js library by the fine folks at Facebook. Our instructor Ryan Florence was 
apparently familiar with Ruby and quizzed me a bit on Procs and lambdas. I tend to use 
blocks most often, lambdas quite infrequently and Procs very, very rarely.
As such I felt my knowledge of these deserved a little review and what better
way to review than to write a little article about the subject and share it
with all of you.

##Closures

Ruby Blocks, Procs and lambdas are basically Ruby's implementation on closures.
If you're familiar with what a closure is, it's basically a piece of code that
is bound to the environment in which that piece of code was defined. 


##Blocks 

Ruby blocks are syntax literals for Proc objects, defined as instructions 
between curly braces `{}` or `do...end` phrases for multiline blocks which may 
optionally take arguments and return values.

``` ruby Block Example
class Foo
  def run
    yield
  end
end

a = 10
b = 20

Foo.new.run do
  a + b
end
```

In the example given above on line 10 thru 12 we are creating a block. The block
consists of the code on line 11 along with it's environment. This block is sent over
to line 3 where it called implicitly by the `yield` statement.

##Procs

Proc is short for procedure. A Proc is a encapsulation of code used to perform
a specific task. A way of thinking of Procs and their behavior is like this.

``` ruby Proc Example
class Foo
  def run(my_proc)
    my_proc.call
    puts "Ho"
  end
end

proc = Proc.new do
  puts "Hi"
  return
end

Foo.new.run(proc)

# Hi 

#==> Equivalent To

class Bar
  def run
    puts "Hi"
    return
    puts "Ho"
  end
end

Bar.new.run

# Hi 
```

If a Proc contains a `return` it will do a hard `return` and exit completely out of 
the method it called. As such `"Ho"` will never be printed to the console.

This makes sense since it is designed as encapulation of 
a procedure. As you can see from the example above the Proc#call on line 3 is
functionally equivalent to line 21-22.

##Lambda 

Lambda get its name from lambda calculus. In this sense lambdas take the form
of anonymous functions.

``` ruby Lambda Example
class Foo
  def run(my_lam)
    my_lam.call
    puts "Ho"
  end
end

lam = lambda do
  puts "Hi"
  return
end

Foo.new.run(lam)

# Hi
# Ho

#==> Equivalent To

class Bar
  def run
    lam
    puts "Ho"
  end

  def lam
    puts "Hi"
    return
  end
end

Bar.new.run
```

The difference between `Foo` and `Bar` is that `Foo#run` executes an anonymous
method defined by the lambda where as `Bar#run` executes the named method
`Bar#lam`. 

The `return` statement in the lambda returns from the anonymous method just
as a `return` in a named method will return from that method. Thus it will not
exit out of the method in which it was invoked.

##Conclusion

So I know I'm skipping a whole bunch of stuff regrading Blocks, Procs and Lambdas
like parameter passing and appearance in argument lists but unfortunately I got
a late start on this article so I'll have to write some supplements to this
in the coming weeks.

Bye.


