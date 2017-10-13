require 'rails_helper'

require 'rails_helper'

describe ProjectsController do
  describe '#index' do
    context 'when empty api token is provided' do
      it 'returns 401 status unauthorized' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }

        get :index, api_key: '', format: :json

        expect(response).to be_unauthorized
        expect(response).to have_http_status(401)
        json = JSON.parse(response.body)
        expect(json).to include('title' => 'Unauthorized request')
      end
    end

    context 'when invalid api token is provided' do
      it 'returns 401 status unauthorized' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }

        get :index, api_key: '0000', format: :json

        expect(response).to be_unauthorized
        expect(response).to have_http_status(401)
        json = JSON.parse(response.body)
        expect(json).to include('title' => 'Unauthorized request')
      end
    end

    context 'when valid api token is provided' do
      it 'returns list of projects' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }
        allow(ENV).to receive(:fetch).with('page_size') { 2 }
        create(:project, name: 'Project 1', customer_name: 'Customer 1', budget: 22.0, technologies: %w[technology1 technology2])
        create(:project, name: 'Project 2', customer_name: 'Customer 2', budget: 23, technologies: %w[technology3 technology4])

        get :index, api_key: 'b5b98', format: :json

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          'data' => match_array([
            include(
              'name' => 'Project 1',
              'customer_name' => 'Customer 1',
              'budget' => '22.0',
              'technologies' => "[\"technology1\", \"technology2\"]"),
            include(
              'name' => 'Project 2',
              'customer_name' => 'Customer 2',
              'budget' => '23.0',
              'technologies' => "[\"technology3\", \"technology4\"]")]),
          'links' => include('self' => 'http://example.com/projects?page=1')
        )
      end

      context 'when is 3 pages of results' do
        context 'when first page is requested' do
          it 'returns first page of projects and proper pagination links' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            create(:project, name: 'Project 1')
            create(:project, name: 'Project 2')
            create(:project, name: 'Project 3')
            create(:project, name: 'Project 4')
            create(:project, name: 'Project 5')

            get :index, api_key: 'b5b98', format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json).to include(
              'data' => match_array([
                include('name' => 'Project 1'),
                include('name' => 'Project 2')]),
              'links' => include('self' => 'http://example.com/projects?page=1', 'next' => 'http://example.com/projects?page=2')
            )
          end
        end

        context 'when second page is requested' do
          it 'returns second page of projects and proper pagination links' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            create(:project, name: 'Project 1')
            create(:project, name: 'Project 2')
            create(:project, name: 'Project 3')
            create(:project, name: 'Project 4')
            create(:project, name: 'Project 5')

            get :index, api_key: 'b5b98', page: 2, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json).to include(
              'data' => match_array([
                include('name' => 'Project 3'),
                include('name' => 'Project 4')]),
              'links' => include(
                'self' => 'http://example.com/projects?page=2',
                'next' => 'http://example.com/projects?page=3',
                'previous' => 'http://example.com/projects?page=1')
            )
          end
        end

        context 'third page' do
          it 'returns third page of projects and proper pagination links' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            create(:project, name: 'Project 1')
            create(:project, name: 'Project 2')
            create(:project, name: 'Project 3')
            create(:project, name: 'Project 4')
            create(:project, name: 'Project 5')

            get :index, api_key: 'b5b96', page: 3, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json).to include(
              'data' => match_array([
                include('name' => 'Project 5')]),
              'links' => include(
                'self' => 'http://example.com/projects?page=3',
                'previous' => 'http://example.com/projects?page=2')
            )
          end
        end
      end

      context 'when using sort parameters' do
        context 'sort records ascending by name' do
          it 'returns projects sorted ascending by name' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            params = { api_key: 'b5b96', sort: 'name'}
            create(:project, name: 'Argentina', customer_name: 'Customer', budget: 22.0, technologies: %w[technology technology])
            create(:project, name: 'Brasil', customer_name: 'Customer', budget: 22.0, technologies: %w[technology technology])

            get :index, params, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)

            expect(json).to include(
              'data' => match_array([
                include(
                    'name' => 'Argentina',
                    'customer_name' => 'Customer',
                    'budget' => '22.0',
                    'technologies' => "[\"technology\", \"technology\"]"),
                include(
                    'name' => 'Brasil',
                    'customer_name' => 'Customer',
                    'budget' => '22.0',
                    'technologies' => "[\"technology\", \"technology\"]")]),
              'links' => include('self' => 'http://example.com/projects?page=1&sort=name')
            )
          end
        end

        context 'sort records descending by name' do
          it 'returns projects descending sorted by name' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            params = { api_key: 'b5b96', sort: '-name'}
            create(:project, name: 'Argentina', customer_name: 'Customer', budget: 22.0, technologies: %w[technology technology])
            create(:project, name: 'Brasil', customer_name: 'Customer', budget: 22.0, technologies: %w[technology technology])

            get :index, params, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json).to include(
              'data' => match_array(
                [
                  include(
                    'name' => 'Brasil',
                    'customer_name' => 'Customer',
                    'budget' => '22.0',
                    'technologies' => "[\"technology\", \"technology\"]"),
                  include(
                    'name' => 'Argentina',
                    'customer_name' => 'Customer',
                    'budget' => '22.0',
                    'technologies' => "[\"technology\", \"technology\"]")
                ]),
              'links' => include('self' => 'http://example.com/projects?page=1&sort=-name')
            )
          end
        end

        context 'sort records ascending by budget' do
          it 'returns projects sorted ascending by budget' do
            allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
            allow(ENV).to receive(:fetch).with('page_size') { 2 }
            params = { api_key: 'b5b96', sort: 'budget'}
            create(:project, name: 'Project', customer_name: 'Customer', budget: 15.0, technologies: %w[technology technology])
            create(:project, name: 'Project', customer_name: 'Customer', budget: 20.0, technologies: %w[technology technology])

            get :index, params, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            expect(json).to include(
              'data' => match_array(
                [
                  include(
                    'name' => 'Project',
                    'customer_name' => 'Customer',
                    'budget' => '15.0',
                    'technologies' => "[\"technology\", \"technology\"]"),
                  include(
                    'name' => 'Project',
                    'customer_name' => 'Customer',
                    'budget' => '20.0',
                    'technologies' => "[\"technology\", \"technology\"]")

                ]),
              'links' => include('self' => 'http://example.com/projects?page=1&sort=budget')
            )
          end

          context 'sort records descending by budget' do
            it 'returns projects sorted descending by budget' do
              allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
              allow(ENV).to receive(:fetch).with('page_size') { 2 }
              params = { api_key: 'b5b96', sort: '-budget'}
              create(:project, name: 'Project', customer_name: 'Customer', budget: 15.0, technologies: %w[technology technology])
              create(:project, name: 'Project', customer_name: 'Customer', budget: 20.0, technologies: %w[technology technology])

              get :index, params, format: :json

              expect(response.content_type).to eq('application/json')
              expect(response).to have_http_status(:ok)
              json = JSON.parse(response.body)
              expect(json).to include(
                'data' => match_array(
                  [
                    include(
                      'name' => 'Project',
                      'customer_name' => 'Customer',
                      'budget' => '20.0',
                      'technologies' => "[\"technology\", \"technology\"]"),
                    include(
                      'name' => 'Project',
                      'customer_name' => 'Customer',
                      'budget' => '15.0',
                      'technologies' => "[\"technology\", \"technology\"]")
                  ]),
                'links' => include('self' => 'http://example.com/projects?page=1&sort=-budget')
              )
            end
          end

          context 'sort records ascending by name and budget' do
            it 'returns projects sorted ascending by name and budget' do
              allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
              allow(ENV).to receive(:fetch).with('page_size') { 2 }
              params = { api_key: 'b5b96', sort: 'name,budget'}
              create(:project, name: 'Project 3', customer_name: 'Customer', budget: 15.0, technologies: %w[technology technology])
              create(:project, name: 'Project 4', customer_name: 'Customer', budget: 20.0, technologies: %w[technology technology])

              get :index, params, format: :json

              expect(response.content_type).to eq('application/json')
              expect(response).to have_http_status(:ok)
              json = JSON.parse(response.body)
              expect(json).to include(
                'data' => match_array(
                  [
                    include(
                      'name' => 'Project 3',
                      'customer_name' => 'Customer',
                      'budget' => '15.0',
                      'technologies' => "[\"technology\", \"technology\"]"),
                    include(
                      'name' => 'Project 4',
                      'customer_name' => 'Customer',
                      'budget' => '20.0',
                      'technologies' => "[\"technology\", \"technology\"]")
                  ]),
                'links' => include('self' => 'http://example.com/projects?page=1&sort=name%2Cbudget')
              )
            end
          end

          context 'sort record ascending by customer name' do
            it 'returns 404 bad request' do
              allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
              allow(ENV).to receive(:fetch).with('page_size') { 2 }
              params = { api_key: 'b5b96', sort: 'customer_name'}

              get :index, params, format: :json

              expect(response.content_type).to eq('application/json')
              expect(response).to have_http_status(:bad_request)
              json = JSON.parse(response.body)
              expect(json).to include(
                'title' => 'Bad request', 'description' => 'Not supported attribute by sorting!', 'status' => '400'
              )
            end
          end
        end
      end
    end
  end

  # describe '#show' do
  #
  #   context 'when empty api token is provided' do
  #     it 'return 401 status unauthorized' do
  #       get :show, id: 1, api_key: '', format: :json
  #
  #       expect(response).to be_unauthorized
  #     end
  #   end
  #
  #   context 'when invalid api token is provided' do
  #     it 'return 401 status unauthorized' do
  #       get :show, id: 1, api_key: '0000', format: :json
  #
  #       expect(response).to be_unauthorized
  #     end
  #   end
  #
  #   context 'valid request with token' do
  #     it 'return project' do
  #       project = create(:project)
  #       get :show, id: project.id, format: :json
  #
  #       expect(response.content_type).to eq('application/json')
  #       expect(response).to have_http_status(:ok)
  #       result = JSON.parse(response.body)
  #     end
  #   end
  # end
end