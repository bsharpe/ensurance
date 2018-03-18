# Ensurance

Allows you to ensure you have the class you expect... it's similar to

```
result = value.is_a?(Person) ? value : Person.find(value)
```

You can add fields to "ensure_by" (`self.primary_key` is the default)
e.g.

 if you add `ensure_by :token` to the User class
  User.ensure(<UserObject>) works
  User.ensure(:user_id) works
  User.ensure(:token) works

 .ensure() returns nil if the record is not found
 .ensure!() throws an exception if the record is not found

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ensurance'
```

And then execute:

    $ bundle

## Usage

In your Rails app... `include Ensurance` either in specific models or `ApplicationRecord` to cover all your models.

It's really handy for service objects or Jobs that you want to call from the console to try out.

```
class User < ApplicationRecord
  include Ensurance
end


class SomeServiceClass
  def perform(user)
    user = User.ensure(user)
    # do something constructive here
  end
end
```

In this way you can call it with a User object, or a user `id` and it works just the same.

Also adds ensurance features to `Hash`, `Time`, and `Date`

```
Time.ensure(Date.today) -> Date.today.beginning_of_day
Time.ensure(1509556285) -> 2017-11-01 11:11:25 -0600
Time.ensure("1509556285") -> 2017-11-01 11:11:25 -0600
Time.ensure(DateTime.now) -> DateTime.now.to_time
Time.ensure(nil) -> nil
Time.ensure(1..4) -> ArgumentError "Unhandled Type for Time to ensure: Range"

Date.ensure(Date.today) -> Date.today
Date.ensure(nil) -> nil
Date.ensure(1509556285) -> 2017-11-01

Hash.ensure(<aHash>) -> <aHash>
Hash.ensure(<json_string>) -> Hash
Hash.ensure(nil) -> nil
Hash.ensure(<an array>) -> <an array>.to_h
```

### ActiveRecord

You can specify another field or fields to ensure by doing the following:

```
class User < ApplicationRecord
  include Ensurance

  ensure_by :token    <- totally optional
end

User.ensure(1) == User.find(1)
User.ensure(<a user record>) -> <a user record>
User.ensure(<globalid>) == GlobalID::Locator.locate(<globalid>)
User.ensure(<globalid string>) == GlobalID::Locator.locate(<globalid string>)
User.ensure(<some token>) == User.where(token: <some token>).first
User.ensure(nil) -> nil
User.ensure!(nil) -> nil
User.ensure!(<unknown_id>) -> ActiveRecord::RecordNotFound
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bsharpe/ensurance.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
