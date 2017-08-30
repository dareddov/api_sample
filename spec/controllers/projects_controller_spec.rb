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
        project_first_hash = { 'name' => 'Project 1', 'customer_name' => 'Customer 1', 'budget' => '22.0', 'technologies' => "[\"technology1\", \"technology2\"]" }
        project_second_hash = { 'name' => 'Project 2', 'customer_name' => 'Customer 2', 'budget' => '23.0', 'technologies' => "[\"technology3\", \"technology4\"]" }
        links_hash = { 'self' => 'http://example.com/projects?page=1' }

        get :index, api_key: 'b5b98', format: :json

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        projects = json['data']
        links = json['links']
        expect(projects).to include(project_first_hash, project_second_hash)
        expect(links).to include(links_hash)
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
            project_first_hash = { 'name' => 'Project 1' }
            project_second_hash = { 'name' => 'Project 2' }
            link_hash = { 'self' => 'http://example.com/projects?page=1', 'next' => 'http://example.com/projects?page=2' }

            get :index, api_key: 'b5b98', format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            projects = json['data']
            links = json['links']
            expect(projects.first).to include(project_first_hash)
            expect(projects.second).to include(project_second_hash)
            expect(links).to include(link_hash)
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
            project_first_hash = { 'name' => 'Project 3' }
            project_second_hash = { 'name' => 'Project 4' }
            link_hash = { 'self' => 'http://example.com/projects?page=2', 'next' => 'http://example.com/projects?page=3', 'previous' => 'http://example.com/projects?page=1' }

            get :index, api_key: 'b5b98', page: 2, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            projects = json['data']
            links = json['links']
            expect(projects.first).to include(project_first_hash)
            expect(projects.second).to include(project_second_hash)
            expect(links).to include(link_hash)
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
            project_hash = { 'name' => 'Project 5' }
            link_hash = { 'self' => 'http://example.com/projects?page=3', 'previous' => 'http://example.com/projects?page=2' }

            get :index, api_key: 'b5b96', page: 3, format: :json

            expect(response.content_type).to eq('application/json')
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body)
            projects = json['data']
            links = json['links']
            expect(links).to include(link_hash)
            expect(projects.first).to include(project_hash)
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