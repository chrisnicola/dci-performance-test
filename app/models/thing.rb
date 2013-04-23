class Thing < ActiveRecord::Base
  attr_accessible :name

  def do_your_thing
    self.update_attribute(:name, rand(1024))
  end
end

module ThingDoing
  def do_it
    self.update_attribute(:name, rand(1024))
  end
end

