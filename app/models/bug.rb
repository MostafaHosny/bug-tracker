require 'elasticsearch/model'
class Bug < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    has_one :state , dependent: :destroy

  #---------------------------------- Enums -----------------------------------
    STATUS = ['new' ,'In-progress', 'closed']
    enum priority: [:minor , :major , :critical]
    
    #this validate the app token and the numer are not repeated and uniqe 
    validates :number, uniqueness: { scope: :application_token }
    validates :status, :inclusion => {:in => STATUS } , :allow_nil => true
    validates :priority, inclusion: { in: priorities.keys } ,:allow_nil => true 

    scope :with_token, ->(application_token) { where(application_token: application_token) }

    def self.insert_new_bug (bug_params , state_params ,application_token)
      bug = Bug.new(bug_params)
        bug.application_token = application_token
        bug.state = State.new(state_params)
      bug.number = (Bug.where(application_token: application_token ).maximum(:number) ||0) +1
      unless bug.save
        bug.increment(:number) 
        bug.save 
      end
    end

    # the settings of elasticsearch which make the comment filed match as my sql %XYZ%
    settings index: { number_of_shards: 1 , 
          analysis: {
          analyzer: {
              ngram_analyzer: {
              tokenizer: "ngram_tokenizer"
            }
          },
          tokenizer: {
              ngram_tokenizer: {
              type: "nGram",
              min_gram: "3",
              max_gram: "20"
            }
          }
        }

        } do
      mappings dynamic: 'false' do
        indexes :priority 
        indexes :comment, type: 'string',analyzer: 'ngram_analyzer'
        indexes :application_token
        indexes :number
        indexes :status
      end
    end

    
    def self.elk_search(query)
        __elasticsearch__.search(
        {
            query: {
                multi_match: {
                    query: query,
                    fields: ['application_token', 'number' ,'status' , 'priority' , 'comment' ]
                }
            }
        }
        ).records.to_a
        end
    end
    # Delete the previous Bugs index in Elasticsearch
    Bug.__elasticsearch__.client.indices.delete index: Bug.index_name rescue nil

    # Create the new index with the new mapping
    Bug.__elasticsearch__.client.indices.create \
    index: Bug.index_name,
    body: { settings: Bug.settings.to_hash, mappings: Bug.mappings.to_hash }
    Bug.import # for auto sync model with elastic search