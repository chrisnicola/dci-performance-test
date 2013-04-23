# Rails DCI Benchmarking

This is an extremely simplistic attempt to quantify the effect performance of
the `.extend` method of DCI in Ruby when using Rails. This work is inspired in
part by [James Golick's][1] recent work on [improving method caching in Ruby][2].

The hypothesis I started with here is that since Ruby and in particular Rails
seem to bust the cache so commonly the limited use of `.extend` used in applying
DCI in the domain a largely an irrelevant overhead. As it turns out, at least
for simple Rails applications, this is not the case.

The second hypothesis is that James' changes to the method cache in Ruby should
nearly eliminate the cost of using `.extend` to implement DCI. In particular
because DCI typically extends at or near the end of an object hierarchy so there
is little, if any, cost to busting the cache using James' approach.

## Conclusions

1. DCI does have a notable performance impact on the processing time of
   our requests. This seems even more significant in Ruby 2.0.

2. James' method cache patch does in fact eliminate almost any negative
   performance impact from using `.extend` for DCI.

So despite the fact that there is a lot of cache busting happening in Rails,
ActiveRecord and other gems, our single call to `extend` caused a notable drop
in performance.

That said, YMMV, perhaps if you are doing significantly more AR calls per
request or using other gems (this is a barebones examples) you may see less
impact from your DCI roles injection or maybe not.

Despite this fact, I remain quite bullish on DCI. The issues with performance
and DCI are obviously one of the language/VM implementation for Ruby and not an
issue with the DCI pattern, or even the choice to implement it using `.extend`
to support role injection. It's my hope that James' patch does get considered
for inclusion in a later patch of Ruby 2.0 when it's ready.

## Methodology

I am admittedly not experienced in performance benchmarking of this type so my
approach may be naive. I welcome comments, suggestions and pull requests.

I am using the apache benchmarking utility and running against a locally running
Thin server in production mode.

```
RAILS_ENV=production rake assets:precompile
RAILS_ENV=production rails s
```

Simple GET endpoints let you execute the tests

```
wget http://localhost:3000/things/setup
wget http://localhost:3000/things/1/do
wget http://localhost:3000/things/1/do_dci
```

Benchmarks were obtained using ApacheBench, Version 2.3 <$Revision: 1373084 $>

Each test was run with 1000 requests in serial.

```
ab -n 1000 -r http://localhost:3000/things/1/do
ab -n 1000 -r http://localhost:3000/things/1/do_dci
```

## Results

```
Ruby            With DCI/extend     Without DCI/extend      Difference
----            ---------------     ------------------      ----------
1.9.3-p327      131 tr/s            149 tr/s                14%
2.0.0-p0        126 tr/s            155 tr/s                23%
James Golick    150 tr/s            145 tr/s                3%
```

[1]: http://jamesgolick.com/
[2]: http://jamesgolick.com/2013/4/14/mris-method-caches.html
