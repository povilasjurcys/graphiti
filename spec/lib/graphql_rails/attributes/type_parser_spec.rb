# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe TypeParser do
      subject(:parser) { described_class.new(type) }

      let(:type) { 'String!' }

      describe '#graphql_model' do
        subject(:graphql_model) { parser.graphql_model }

        context 'when costom type is provided' do
          let(:type) { 'SomeImage' }

          it 'returns custom model' do
            image = Object.const_set('SomeImage', Class.new { include GraphqlRails::Model })
            expect(graphql_model).to eq(image)
          end
        end

        context 'when graphql type is provided' do
          let(:type) { GraphQL::Types::Int }

          it { is_expected.to be_nil }
        end

        context 'when graphql_rails model is provided' do
          let(:type) do
            Class.new do
              include GraphqlRails::Model
              graphql.attribute(:name)
            end
          end

          it 'returns original type' do
            expect(graphql_model).to be(type)
          end
        end

        context 'when standard type is provided' do
          it { is_expected.to be_nil }
        end
      end

      describe '#type_arg' do
        subject(:type_arg) { parser.type_arg }

        context 'when type is an array' do
          let(:type) { '[String!]!' }

          context 'when inner type is optional' do
            context 'when array is required' do
              let(:type) { '[String]!' }

              it 'returns correct structore' do
                expect(type_arg).to eq([GraphQL::Types::String, { null: true }])
              end
            end

            context 'when array is optional' do
              let(:type) { '[String]' }

              it 'returns correct structore' do
                expect(type_arg).to eq([GraphQL::Types::String, { null: true }])
              end
            end
          end
        end
      end

      describe '#graphql_type' do
        subject(:graphql_type) { parser.graphql_type }

        context 'when graphql type is provided' do
          let(:type) { GraphQL::INT_TYPE }

          it 'returns original graphql type' do
            expect(graphql_type).to eq type
          end
        end

        context 'when model type is provided' do
          let(:type) { 'SomeImage' }

          it 'returns graphql type defined on that model' do
            graphql_class = Class.new do
              include GraphqlRails::Model

              graphql { |g| g.attribute(:format) }
            end
            image = Object.const_set('SomeImage', graphql_class)
            expect(graphql_type).to eq image.graphql.graphql_type
          end
        end

        context 'when attribute is required' do
          it { is_expected.to be_non_null }
        end

        context 'when attribute is optional' do
          let(:type) { 'String' }

          it { is_expected.not_to be_non_null }
        end

        context 'when attribute is integer' do
          let(:type) { 'Int' }

          it { is_expected.to be GraphQL::Types::Int }
        end

        context 'when attribute is ID' do
          let(:type) { 'ID' }

          it { is_expected.to be GraphQL::Types::ID }
        end

        context 'when attribute is boolean' do
          let(:type) { 'bool' }

          it { is_expected.to be GraphQL::Types::Boolean }
        end

        context 'when attribute is float type' do
          let(:type) { 'float' }

          it { is_expected.to be GraphQL::Types::Float }
        end

        context 'when attribute is not supported' do
          let(:type) { 'unknown' }

          it 'raises error' do
            expect { graphql_type }.to raise_error(TypeParseable::UnknownTypeError)
          end
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it { is_expected.to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it { is_expected.not_to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when array and its inner type is required' do
            it { is_expected.to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it { is_expected.not_to be_non_null }
            it { is_expected.to be_list }
          end
        end
      end
    end
  end
end
