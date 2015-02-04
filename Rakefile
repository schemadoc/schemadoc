require 'hoe'
require './lib/schemadoc/version.rb'

Hoe.spec 'schemadoc' do

  self.version = SchemaDoc::VERSION

  self.summary = 'schemadoc - document your database schemas (tables, columns, etc.)'
  self.description = summary

  self.urls    = ['https://github.com/rubylibs/schemadoc']

  self.author  = 'Gerald Bauer'
  self.email   = 'opensport@googlegroups.com'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'HISTORY.md'

  self.extra_deps = [
    ['logutils'],
    ['fetcher']
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
   required_ruby_version: '>= 1.9.2'
  }
end
