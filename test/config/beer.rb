

puts '[boot] hello from beer.rb'

## get all beer.db models
require 'beerdb'


### use Schemadoc::MODELS ???

## configure all models to document

MODELS = [
  BeerDb::Model::Beer,
  BeerDb::Model::Brand,
  BeerDb::Model::Brewery,

  WorldDb::Model::Continent,
  WorldDb::Model::Country,
  WorldDb::Model::Region,
  WorldDb::Model::City,

  TagDb::Model::Tag,    ### check - is TaxoDb ??
  TagDb::Model::Tagging,
]

### needs an established connection
# pp MODELS
