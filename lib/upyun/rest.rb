# encoding: utf-8
require 'restclient'
require 'digest/md5'
require 'uri'

module UpYun
  class Rest
    attr_accessor :endpoint

    def initialize(bucket, operator, password, endpoint=UpYun::ED_AUTO)
      @bucket = bucket
      @operator = operator
      @password = md5(password)
      @endpoint = endpoint
    end

    def endpoint=(ep)
      raise ArgumentError, "Valid endpoint are #{UpYun::ED_LIST}" unless UpYun::ED_LIST.member?(ep)
      @endpoint = ep
    end

    def put(path, file, headers={})
      raise ArgumentError, "'file' is not an instance of String" unless file.is_a?(String)
      headers = headers.merge({"mkdir" => true}) unless headers.key?("mkdir")
      options = if File.file?(file)
                  {body: File.read(file), length: File.size(file), headers: headers}
                else
                  {body: file, length: file.length, headers: headers}
                end

      request(:put, path, options)
    end

    def get(path, savepath=nil)
      res = request(:get, path)
      return res if res.is_a?(Hash) || !savepath

      dir = File.dirname(savepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.write(savepath, res)
    end

    def getinfo(path)
      hds = request(:head, path)
      hds = hds.key?(:error) ? hds : format_info(hds)
    end

    def delete(path)
      request(:delete, path)
    end

    def mkdir(path)
      request(:post, path, {headers: {folder: true, mkdir: true}})
    end

    def getlist(path="/")
      res = request(:get, path)
      return res if res.is_a?(Hash)
      res.split("\n").map do |f|
        attrs = f.split("\t")
        {
          name: attrs[0],
          type: attrs[1] == "N" ? :file : :folder,
          length: attrs[2].to_i,
          last_modified: attrs[3].to_i
        }
      end
    end

    def usage(path="/")
      res = request(:get, path, {params: "usage"})
      return res if res.is_a?(Hash)

      # RestClient has a bug, body.to_i returns the code instead of body,
      # see more on https://github.com/rest-client/rest-client/pull/103
      res.dup.to_i
    end

    private

      def format_info(hds)
        selected = hds.select { |k| k.to_s.match(/^x_upyun/i) }
        selected.reduce({}) do |memo, (k, v)|
          memo.merge!({k[8..-1].to_sym => /^\d+$/.match(v) ? v.to_i : v})
        end
      end

      def fullpath(path)
        "/#{@bucket}#{URI.encode(URI.decode(path[0] == '/' ? path : '/' + path))}"
      end

      def encode(fullpath, params)
        URI.join("http://#{@endpoint}", fullpath, params.nil? ? '' : '?' + params).to_s
      end

      def request(method, path, options={})
        fullpath = fullpath(path)
        url = encode(fullpath, options[:params])
        headers = options[:headers] || {}
        date = gmdate
        length = options[:length] || 0
        headers.merge!({
          'Date' => date,
          'Authorization' => sign(method, date, fullpath, length)
        })

        if [:post, :patch, :put].include? method
          RestClient.send(method, url, options[:body].nil? ? "" : options[:body], headers) do |res|
            res.code == 200 ? true : {error: {code: res.code, message: res.body}}
          end
        else
          RestClient.send(method, url, headers) do |res|
            if res.code == 200
              case method
              when :get
                res.body
              when :head
                res.headers
              else
                true
              end
            else
              {error: {code: res.code, message: res.body}}
            end
          end
        end
      end

      def gmdate
        Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      end

      def sign(method, date, path, length)
        sign = "#{method.to_s.upcase}&#{path}&#{date}&#{length}&#{@password}"
        "UpYun #{@operator}:#{md5(sign)}"
      end

      def md5(str)
        Digest::MD5.hexdigest(str)
      end
  end
end
