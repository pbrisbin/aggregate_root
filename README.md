# Aggregate Root

## Installation

Add to Gemfile:

~~~
gem 'aggregate_root', github: 'https://github.com/pbrisbin/aggregate_root'
~~~

Execute:

~~~
$ bundle
~~~

## Usage

~~~ { .ruby }
class Submission
  include AggregateRoot

  aggregates :user

  aggregates :email,
    if: ->(params) { params[:address].present? }

  aggregates :post,
    related_to: :user,
    model_class: BlogEntry,
    only: [:title],
end

submission = Submission.new(
  user_name: "Pat"
  user_age: 28
  email_address: "foo@gmail.com"
  post_title: "Great post"
  post_description: "This will be ignored"
)
# Will create a user
#
#  user = User.new(name: "Pat", age: 28)
#
# And an email, but only because the if block returned true
#
#  email = Email.new(address: "foo@gmail.com")
#
# And a post; notice the class used and the related model set to the 
# user from above
#
#  post = BlogEntry.new(title: "Great post", user: user)

submission.user_name
# Will respond with "Pat". Similarly for all other attributes.

submission.valid?
# Will perform overall validation of all models involved (TODO)

submission.errors
# Will return all errors (if any) from all models that were validated. 
# Keys will be prefixed (TODO)

submission.save
# Will save all the aggregated models (TODO)
~~~

## Options

`:model_class`

Specify the class used to instantiate the aggregated model. Defaults to 
the classified version of the component name.

`:related_to`

If the component has a `belongs_to` relation to another component, you 
can specify that here. This is best illustrated by the 
*post-related-to-user* example above.

Note that order of definition matters. You can only `relate_to` models 
that have already been defined as aggregated.

`:only`

By default, the aggregate object gains a (prefixed) accessor for every 
attribute of each aggregated model and will pass any attributes it finds 
with the correct prefix onto the underlying call to `new`.

By specifying a list of (unprefixed) attributes, only those will become 
accessors or be passed onto the `new` call.

`:if`

By default, every aggregated object is created. This option is useful 
for making that creation conditional on the presence of one or more 
attributes.
