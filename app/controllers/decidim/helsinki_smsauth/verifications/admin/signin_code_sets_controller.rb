# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          include Decidim::HelsinkiSmsauth::Verifications::Admin::Filterable
          layout "decidim/admin/users"

          helper_method :sets, :school_name

          def index
            enforce_permission_to :index, :authorization
            @collection = paginate(collection)
          end

          private

          def sets
            @sets ||= (filtered_collection + school_matches).uniq
            # @sets ||= filtered_collection
          end

          def collection
            ::Decidim::HelsinkiSmsauth::SigninCodeSet.all
          end

          def school_name(code)
            Decidim::HelsinkiSmsauth::SchoolMetadata.school_name(code)
          end

          def school_matches
            collection.select { |code_set| school_selections&.include?(code_set.metadata["school"]) }
          end

          def school_selections
            @school_selections ||= if ransack_params[:creator_name_cont].blank?
                                     nil
                                   else
                                     find_schools(ransack_params[:creator_name_cont])
                                   end
          end

          def find_schools(query)
            schools = Decidim::HelsinkiSmsauth::SchoolMetadata.school_options
            schools.select { |opt| opt[0].include?(query) }.map do |_key, val|
              val
            end
          end
        end
      end
    end
  end
end
