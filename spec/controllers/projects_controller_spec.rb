require 'rails_helper'

require 'rails_helper'

describe ProjectsController do
  describe '#index' do
    context 'when empty api token is provided' do
      it 'return 401 status unauthorized' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b98' }

        get :index, api_key: '', format: :json

        expect(response).to be_unauthorized
        expect(response).to have_http_status(401)
        json = JSON.parse(response.body)
        expect(json).to include('title' => 'Unauthorized request')
      end
    end

    context 'when invalid api token is provided' do
      it 'return 401 status unauthorized' do
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
    end
  end

  describe '#show' do
    context 'when empty api token is provided' do
      it 'return 401 status unauthorized' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
        valid_hash = { 'title' => 'Unauthorized request' }

        get :show, id: 1, api_key: '', format: :json

        expect(response).to be_unauthorized
        expect(response).to have_http_status(401)
        json = JSON.parse(response.body)
        expect(json).to include(valid_hash)
      end
    end

    context 'when invalid api token is provided' do
      it 'return 401 status unauthorized' do
        allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
        valid_hash = { 'title' => 'Unauthorized request' }

        get :show, id: 1, api_key: '0000', format: :json

        expect(response).to be_unauthorized
        expect(response).to have_http_status(401)
        json = JSON.parse(response.body)
        expect(json).to include(valid_hash)
      end
    end

    context 'valid request with token' do
      context 'when project exist' do
        it 'return project' do
          allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
          project = create(:project, name: 'Project 1', customer_name: 'Customer 1', budget: 22.0, technologies: %w[technology1 technology2])
          valid_hash = {
            'data' => {
              'type' => 'projects',
              'id' => project.id,
              'attributes' => {
                'name' => 'Project 1',
                'customer_name' => 'Customer 1',
                'budget' => '22.0',
                'technologies' => "[\"technology1\", \"technology2\"]"
              }
            },
            'links' => { 'self' => "http://example.com/projects/#{project.id}" }
          }

          get :show, id: project.id, api_key: 'b5b96', format: :json

          expect(response.content_type).to eq('application/json')
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to include(valid_hash)
        end
      end

      context 'when project not exist' do
        it 'returns 404 not found' do
          allow(ENV).to receive(:fetch).with('api_key') { 'b5b96' }
          valid_hash = { 'title' => 'Not found', 'description' => 'The project was not found', 'status' => '404' }

          get :show, id: 0, api_key: 'b5b96', format: :json

          expect(response.content_type).to eq('application/json')
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json).to include(valid_hash)
        end
      end
    end
  end
end