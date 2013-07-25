require 'net/http'
require 'json'

class DamsProvenanceCollectionsController < ApplicationController
   include Blacklight::Catalog
  include Dams::ControllerHelper
  load_and_authorize_resource
  skip_authorize_resource :only => :index

  

  def show
    @dams_provenance_collection = DamsProvenanceCollection.find(params[:id])
   end

  def new
    
    @dams_provenance_collection_parts=get_objects('DamsProvenanceCollectionPart','title_tesim')
    @mads_complex_subjects = get_objects('MadsComplexSubject','name_tesim')
    @dams_units = get_objects('DamsUnit','unit_name_tesim')   
    @dams_assembled_collections = get_objects('DamsAssembledCollection','title_tesim')
    @mads_languages =  get_objects('MadsLanguage','name_tesim')
    @mads_authorities = get_objects('MadsAuthority','name_tesim')
    
    uri = URI('http://fast.oclc.org/fastSuggest/select')
    res = Net::HTTP.post_form(uri, 'q' => 'suggestall :*', 'fl' => 'suggestall', 'wt' => 'json', 'rows' => '100')
    json = JSON.parse(res.body)
    @jdoc = json.fetch("response").fetch("docs")
  
    @autocomplete_items = Array.new
    @jdoc.each do |value|
    @autocomplete_items << value['suggestall']
  end 

  end

  def edit
    @dams_provenance_collection = DamsProvenanceCollection.find(params[:id])
    @dams_provenance_collection_parts=get_objects('DamsProvenanceCollectionPart','title_tesim')
    @mads_complex_subjects = get_objects('MadsComplexSubject','name_tesim')
    @dams_units = get_objects('DamsUnit','unit_name_tesim')   
    @dams_assembled_collections = get_objects('DamsAssembledCollection','title_tesim')
    @mads_languages =  get_objects('MadsLanguage','name_tesim')
    @mads_authorities = get_objects('MadsAuthority','name_tesim')
    @dams_names = get_objects('MadsPersonalName','name_tesim')
    
    @provenance_collection_part_id = @dams_provenance_collection.provenanceCollectionPart.to_s.gsub(/.*\//,'')[0..9]
    @language_id = @dams_provenance_collection.language.to_s.gsub(/.*\//,'')[0..9]
    @role_id = @dams_provenance_collection.relationshipRoleURI.to_s.gsub(/.*\//,'')[0..9]
    @name_id = get_relationship_name_id(@dams_provenance_collection)
    @name_type = get_relationship_name_type(@dams_provenance_collection)
    @dams_names = get_objects("Mads#{@name_type}",'name_tesim')
    @nameTypeArray = Array.new
    @nameTypeArray << @name_type
    @dams_provenance_collection.relationshipNameType = @nameTypeArray

    @simple_subject_type = get_simple_subject_type(@dams_provenance_collection)  
    @dams_simple_subjects = get_objects(@simple_subject_type,'name_tesim')
    @simpleSubject_id = get_simple_subject_id(@dams_provenance_collection)

    
    @complexSubject_id = @dams_provenance_collection.subject.to_s.gsub(/.*\//,'')[0..9] if !@dams_provenance_collection.subject.nil?
     
   @simpleSubjectValue = get_simple_subject_value(@dams_provenance_collection)

  uri = URI('http://fast.oclc.org/fastSuggest/select')
  res = Net::HTTP.post_form(uri, 'q' => 'suggestall :*', 'fl' => 'suggestall', 'wt' => 'json', 'rows' => '100')
  json = JSON.parse(res.body)
  @jdoc = json.fetch("response").fetch("docs")
  
  @autocomplete_items = Array.new
  @jdoc.each do |value|
    @autocomplete_items << value['suggestall']
  end        
  
  end

  def create
    @dams_provenance_collection.attributes = params[:dams_provenance_collection]
    if @dams_provenance_collection.save
        redirect_to @dams_provenance_collection, notice: "ProvenanceCollection has been saved"
    else
      flash[:alert] = "Unable to save provenance_collection"
      render :new
    end
  end

  def update
    @dams_provenance_collection.attributes = params[:dams_provenance_collection]
    if @dams_provenance_collection.save
        redirect_to @dams_provenance_collection, notice: "Successfully updated provenance_collection"
    else
      flash[:alert] = "Unable to save provenance_collection"
      render :edit
    end
  end

  def index
    @units = DamsProvenanceCollection.all( :order=>"system_create_dtsi asc" )
  end


end
