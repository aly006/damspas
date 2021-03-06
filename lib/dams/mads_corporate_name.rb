require 'active_support/concern'

module Dams
  module MadsCorporateName
    extend ActiveSupport::Concern
    include Dams::MadsSimpleType
    include Dams::MadsNameElements
    included do
      rdf_type MADS.CorporateName
      map_predicates do |map|
        map.elem_list(:in => MADS, :to => 'elementList', :class_name=>'MadsCorporateNameElementList')
      end
      def elementList
        elem_list.first || elem_list.build
      end
      accepts_nested_attributes_for :scheme, :nameElement, :fullNameElement, :givenNameElement, :familyNameElement, :dateNameElement, :termsOfAddressNameElement
      def serialize
        check_type( graph, rdf_subject, MADS.CorporateName )
        check_label( graph, rdf_subject, authLabel )
        super
      end

      delegate :nameElement_attributes=, to: :elementList
      alias_method :nameElement, :elementList

      delegate :fullNameElement_attributes=, to: :elementList
      alias_method :fullNameElement, :elementList
      
      delegate :givenNameElement_attributes=, to: :elementList
      alias_method :givenNameElement, :elementList

      delegate :familyNameElement_attributes=, to: :elementList
      alias_method :familyNameElement, :elementList

      delegate :dateNameElement_attributes=, to: :elementList
      alias_method :dateNameElement, :elementList

      delegate :termsOfAddressNameElement_attributes=, to: :elementList
      alias_method :termsOfAddressNameElement, :elementList

      def authLabel

        # explicitly-set name overrides generated label
        if !name.first.blank?
          return name.first
        end

        full = fullNameValue
        given = givenNameValue
        family = familyNameValue
        addr = termsOfAddressNameValue
        date = dateNameValue
        nameVal = nameValue

        authLabel = ""
        [full,family,given,addr,nameVal,date].each do |val|
          if !val.blank?
            authLabel += ", " if !authLabel.blank?
            authLabel += val
          end
        end
        authLabel if !authLabel.blank?
      end
      def nameValue
        get_value "MadsNameElements::MadsNameElement"
      end
      def familyNameValue
        get_value "MadsFamilyNameElement"
      end
      def fullNameValue
        get_value "MadsFullNameElement"
      end
      def givenNameValue
        get_value "MadsGivenNameElement"
      end
      def dateNameValue
        get_value "MadsDateNameElement"
      end
      def termsOfAddressNameValue
        get_value "MadsTermsOfAddressNameElement"
      end
      def get_value(name)
        el = elementList
        idx = 0
        while idx < el.size
          elem = el[idx]
          
          if elem.class.name.include? name
            if(elem.elementValue.nil?)
          		return nil
          	elsif(elem.elementValue.first == nil || elem.elementValue.first.size > elem.elementValue.size )
            	return elem.elementValue.first
          	else
          		return elem.elementValue.to_s
            end
          end
          idx += 1
        end
      end
      def to_solr (solr_doc={})
        Solrizer.insert_field(solr_doc, 'corporate_name', name)
        if elementList.first
          Solrizer.insert_field(solr_doc, "name_element", nameValue)
          Solrizer.insert_field(solr_doc, "given_name_element", givenNameValue)
          Solrizer.insert_field(solr_doc, "full_name_element", fullNameValue)
          Solrizer.insert_field(solr_doc, "family_name_element", familyNameValue)
          Solrizer.insert_field(solr_doc, "date_name_element", dateNameValue)
          Solrizer.insert_field(solr_doc, "terms_of_address_name_element", termsOfAddressNameValue)
        end
	    # hack to make sure something is indexed for rights metadata
	    ['edit_access_group_ssim','read_access_group_ssim','discover_access_group_ssim'].each {|f|
	      solr_doc[f] = 'dams-curator' unless solr_doc[f]
	    }
        solr_base solr_doc
      end
      class MadsCorporateNameElementList
        include ActiveFedora::RdfList
        map_predicates do |map|
          map.nameElement(:in=> MADS, :to =>"NameElement", :class_name => "MadsNameElement")
          map.givenNameElement(:in=> MADS, :to =>"GivenNameElement", :class_name => "MadsGivenNameElement")
          map.fullNameElement(:in=> MADS, :to =>"FullNameElement", :class_name => "MadsFullNameElement")
          map.familyNameElement(:in=> MADS, :to =>"FamilyNameElement", :class_name => "MadsFamilyNameElement")
          map.dateNameElement(:in=> MADS, :to =>"DateNameElement", :class_name => "MadsDateNameElement")
          map.termsOfAddressNameElement(:in=> MADS, :to =>"TermsOfAddressNameElement", :class_name => "MadsTermsOfAddressNameElement")
        end
        accepts_nested_attributes_for :nameElement, :givenNameElement, :fullNameElement, :familyNameElement, :dateNameElement, :termsOfAddressNameElement
      end
    end
  end
end
