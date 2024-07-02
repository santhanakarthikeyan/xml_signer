# frozen_string_literal: true

require 'nokogiri'
require 'openssl'

module XmlSigner
  class Signer
    def initialize(pfx_file, pfx_password)
      @pfx_file = pfx_file
      @pfx_password = pfx_password
      @p12 = OpenSSL::PKCS12.new(File.read(@pfx_file), @pfx_password)
      @cert = @p12.certificate
      @key = @p12.key
    end

    def sign(xml_string)
      doc = Nokogiri::XML(xml_string)
      signature = generate_signature_element(doc)
      doc.root.add_child(signature)
      doc.to_xml
    end

    private

    def generate_signature_element(doc)
      signature = Nokogiri::XML::Node.new('Signature', doc)
      signature.default_namespace = 'http://www.w3.org/2000/09/xmldsig#'

      signed_info = generate_signed_info(doc)
      signature.add_child(signed_info)

      signature_value = generate_signature(signed_info)
      append_signature(signature, signature_value)

      signature
    end

    def generate_signed_info(doc)
      signed_info = Nokogiri::XML::Node.new('SignedInfo', doc)

      canonicalization_method = Nokogiri::XML::Node.new('CanonicalizationMethod', doc)
      canonicalization_method['Algorithm'] = 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315'
      signed_info.add_child(canonicalization_method)

      signature_method = Nokogiri::XML::Node.new('SignatureMethod', doc)
      signature_method['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
      signed_info.add_child(signature_method)

      reference = Nokogiri::XML::Node.new('Reference', doc)
      reference['URI'] = ''

      transforms = Nokogiri::XML::Node.new('Transforms', doc)
      transform = Nokogiri::XML::Node.new('Transform', doc)
      transform['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#enveloped-signature'
      transforms.add_child(transform)
      reference.add_child(transforms)

      digest_method = Nokogiri::XML::Node.new('DigestMethod', doc)
      digest_method['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#sha1'
      reference.add_child(digest_method)

      # Digest the entire document excluding the Signature element
      canonized_xml = doc.canonicalize(Nokogiri::XML::XML_C14N_1_0)
      digest_value = OpenSSL::Digest::SHA1.new(canonized_xml).base64digest
      digest_value_node = Nokogiri::XML::Node.new('DigestValue', doc)
      digest_value_node.content = digest_value
      reference.add_child(digest_value_node)

      signed_info.add_child(reference)
      signed_info
    end

    def generate_signature(signed_info)
      # Canonicalize the SignedInfo node with the correct context
      temp_doc = Nokogiri::XML::Document.new
      temp_doc.root = signed_info.dup
      canonized_signed_info = temp_doc.canonicalize(Nokogiri::XML::XML_C14N_1_0)
      signature = @key.sign(OpenSSL::Digest::SHA1.new, canonized_signed_info)
      Base64.encode64(signature).delete("\n")
    end

    def append_signature(signature, signature_value)
      doc = signature.document
      signature_value_node = Nokogiri::XML::Node.new('SignatureValue', doc)
      signature_value_node.content = signature_value
      signature.add_child(signature_value_node)

      key_info = Nokogiri::XML::Node.new('KeyInfo', doc)
      x509_data = Nokogiri::XML::Node.new('X509Data', doc)

      x509_certificate = Nokogiri::XML::Node.new('X509Certificate', doc)
      x509_certificate.content = Base64.encode64(@cert.to_der).delete("\n")
      x509_data.add_child(x509_certificate)

      x509_subject_name = Nokogiri::XML::Node.new('X509SubjectName', doc)
      x509_subject_name.content = format_subject(@cert.subject)
      x509_data.add_child(x509_subject_name)

      key_info.add_child(x509_data)
      signature.add_child(key_info)

      doc.root.add_child(signature)
    end

    def format_subject(subject)
      subject.to_a.map { |name, value, _| "#{name}=#{value}" }.join(', ')
    end
  end
end
