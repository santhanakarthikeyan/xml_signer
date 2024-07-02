# XmlSigner

XmlSigner is a Ruby gem for signing XML documents using a PKCS12 certificate, Nokogiri, and OpenSSL.

## Installation

```ruby
gem 'xml_signer'
```


## Usage

```ruby
require 'xml_signer'

pfx_file = 'path/to/your/certificate.pfx'
pfx_password = 'your_password'

signer = XmlSigner::Signer.new(pfx_file, pfx_password)

xml_to_sign = <<-XML
<Esign AuthMode="1" aspId="test" ekycIdType="A" responseSigType="pkcs7pdf" responseUrl="http://localhost:3000/response" sc="Y" ts="2024-07-01T19:29:42" txn="031ad56656beda1ab98c9debbd068d30" ver="2.1">
  <Docs>
    <InputHash docInfo="Trading Account opening form" hashAlgorithm="SHA256" id="1">be440a367d9c4d7357caff2b8bfa6640b60797c6cd41bd028b2067297c3ef317</InputHash>
  </Docs>
</Esign>
XML

signed_xml = signer.sign(xml_to_sign)
puts signed_xml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/santhanakarthikeyan/xml_signer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/xml_signer/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the XmlSigner project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/xml_signer/blob/main/CODE_OF_CONDUCT.md).
