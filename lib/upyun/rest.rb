# encoding: utf-8
require 'restclient'
require 'open-uri'

module Upyun
  class Rest
    include Utils

    attr_reader :options

    def initialize(bucket, operator, password, options={timeout: 60}, endpoint=Upyun::ED_AUTO)
      @bucket = bucket
      @operator = operator
      @password = md5(password)
      @options = options
      @endpoint = endpoint
    end

    def put(path, file, headers={})
      headers = headers.merge({'mkdir' => true}) unless headers.key?('mkdir')
      body = file.respond_to?(:read) ? IO.binread(file) : file
      options = {body: body, length: size(file), headers: headers}

      # If the type of current bucket is Picture,
      # put an image maybe return a set of headers
      # represent the image's metadata
      # x-upyun-width
      # x-upyun-height
      # x-upyun-frames
      # x-upyun-file-type
      res = request(:put, path, options) do |hds|
        hds.select { |k| k.to_s.match(/^x_upyun_/i) }.reduce({}) do |memo, (k, v)|
          memo.merge!({k[8..-1].to_sym => /^\d+$/.match(v) ? v.to_i : v})
        end
      end

      res == {} ? true : res
    ensure
      file.close if file.respond_to?(:close)
    end

    def get(path, savepath=nil, headers={})
      res = request(:get, path, headers: headers)
      return res if res.is_a?(Hash) || !savepath

      dir = File.dirname(savepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.write(savepath, res)
    end

    def getinfo(path)
      request(:head, path) do |hds|
        #  File info:
        #  x-upyun-file-type
        #  x-upyun-file-size
        #  x-upyun-file-date
        hds.select { |k| k.to_s.match(/^x_upyun_file/i) }.reduce({}) do |memo, (k, v)|
          memo.merge!({k[8..-1].to_sym => /^\d+$/.match(v) ? v.to_i : v})
        end
      end
    end

    alias :head :getinfo

    def delete(path)
      request(:delete, path)
    end

    def mkdir(path)
      request(:post, path, {headers: {folder: true, mkdir: true}})
    end

    def getlist(path='/')
      res = request(:get, path)
      return res if res.is_a?(Hash)

      res.split("\n").map do |f|
        attrs = f.split("\t")
        {
          name: attrs[0],
          type: attrs[1] == 'N' ? :file : :folder,
          length: attrs[2].to_i,
          last_modified: attrs[3].to_i
        }
      end
    end

    def usage
      res = request(:get, '/', {query: 'usage'})
      return res if res.is_a?(Hash)

      # RestClient has a bug, body.to_i returns the code instead of body,
      # see more on https://github.com/rest-client/rest-client/pull/103
      res.dup.to_i
    end

    private

      def fullpath(path)
        decoded = URI::encode(URI::decode(path.to_s.force_encoding('utf-8')))
        "/#{@bucket}#{decoded.start_with?('/') ? decoded : '/' + decoded}"
      end

      def request(method, path, options={}, &block)
        fullpath = fullpath(path)
        query = options[:query]
        fullpath_query = "#{fullpath}#{query.nil? ? '' : '?' + query}"
        headers = options[:headers] || {}
        date = gmdate
        length = options[:length] || 0
        headers.merge!({
          'User-Agent' => "Upyun-Ruby-SDK-#{VERSION}",
          'Date' => date,
          'Authorization' => sign(method, date, fullpath, length)
        })

        if [:post, :patch, :put].include? method
          body = options[:body].nil? ? '' : options[:body]
          rest_client[fullpath_query].send(method, body, headers) do |res|
            if res.code / 100 == 2
              block_given? ? yield(res.headers) : true
            else
              {
                request_id: res.headers[:x_request_id],
                error: {code: res.code, message: res.body}
              }
            end
          end

        else
          rest_client[fullpath_query].send(method, headers) do |res|
            if res.code / 100 == 2
              case method
              when :get
                res.body
              when :head
                yield(res.headers)
              else
                true
              end
            else
            {
              request_id: res.headers[:x_request_id],
              error: {code: res.code, message: res.body}
            }
            end
          end
        end
      end

      def rest_client
        @rest_clint ||= RestClient::Resource.new("http://#{@endpoint}", options)
      end

      def gmdate
        Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      end

      def sign(method, date, path, length)
        sign = "#{method.to_s.upcase}&#{path}&#{date}&#{length}&#{@password}"
        "UpYun #{@operator}:#{md5(sign)}"
      end

      def size(param)
        if param.respond_to?(:size)
          param.size
        elsif param.is_a?(IO)
          param.stat.size
        end
      end
  end
end
