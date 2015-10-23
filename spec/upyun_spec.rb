# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'
require 'uri'

describe "Upyun Restful API Basic testing" do
  before :all do
    @upyun = Upyun::Rest.new('sdkfile', 'tester', 'grjxv2mxELR3', {}, Upyun::ED_TELECOM)
    @file = File.expand_path('../upyun.jpg', __FILE__)
    @str = 'This is a binary string, not a file'
  end

  describe ".endpoint=" do
    it "known ENDPOINT, should return ok" do
      @upyun.endpoint = Upyun::ED_CMCC
      expect(@upyun.endpoint).to eq 'v3.api.upyun.com'
    end

    it "unknown ENDPOINT, should raise ArgumentError" do
      expect {@upyun.endpoint = 'v5.api.upyun.com'}.
        to raise_error(ArgumentError, /Valid endpoints/)
    end

    after { @upyun.endpoint = Upyun::ED_AUTO }
  end

  describe ".put" do
    before { @path = "/ruby-sdk/foo/#{String.random}/test.jpg" }

    it "PUT an image should return image information" do
      metas = @upyun.put(@path, File.new(@file, 'rb'))
      expect(metas).to include(:width, :height, :frames, :file_type)
      expect(metas[:width].is_a?(Integer))
      expect(metas[:height].is_a?(Integer))
      expect(metas[:frames].is_a?(Integer))
      expect(metas[:file_type].is_a?(String))
    end

    it "PUT a binary string should return no more information" do
      expect(@upyun.put(@path, @str)).to be true
    end

    it "PUT with some extra headers" do
      headers = {
        'Contetn-type' => 'image/jpeg',
        'x-gmkerl-type' => 'fix_width',
        'x-gmkerl-value' => 42,
        'x-gmkerl-unsharp' => true
      }
      metas = @upyun.put(@path, File.new(@file, 'rb'), headers)

      expect(metas).to include(:width, :height, :frames, :file_type)
      expect(metas[:width].is_a?(Integer))
      expect(metas[:height].is_a?(Integer))
      expect(metas[:frames].is_a?(Integer))
      expect(metas[:file_type].is_a?(String))
    end

    describe "PUT in Chinese path" do
      before(:all) { @path_cn = '/ruby-sdk/foo/这是中文路径/foo.txt' }

      it "should success" do
        expect(@upyun.put(@path_cn, @str)).to be true
      end

      it "then get the non encoded path also success" do
        expect(@upyun.get(@path_cn)).to eq(@str)
      end

      it "then get the encoded path should also success" do
        expect(@upyun.get(URI.encode(@path_cn))).to eq(@str)
      end

      it "after all, delete should success" do
        expect(@upyun.delete(@path_cn)).to be true
      end

      after(:all) { @upyun.delete(@path_cn) }
    end

    describe "PUT with '%2B' encoded url path" do
      before(:all) do
        @path_2b = '/ruby-sdk/foo/%2B/foo.txt'
        @str_2b = 'This is 2b string binary.'
      end

      it "shoud success" do
        expect(@upyun.put(@path_2b, @str_2b)).to be true
      end

      it "then get the same url should also success" do
        expect(@upyun.get(@path_2b)).to eq(@str_2b)
      end

      it "then get replaced('%2B' -> '+') should also success" do
        expect(@upyun.get(@path_2b.gsub("%2B", "+"))).to eq(@str_2b)
      end

      it "after all, delete should success" do
        expect(@upyun.delete(@path_2b)).to be true
      end

      after(:all) { @upyun.delete(@path_2b) }
    end

    describe "PUT with '+' encoded url path" do
      before(:all) do
        @path_plus = '/ruby-sdk/foo/+/foo.txt'
        @str_plus = 'This is plus string.'
      end

      it "should success" do
        expect(@upyun.put(@path_plus, @str_plus)).to be true
      end

      it "then get the same url should also success" do
        expect(@upyun.get(@path_plus)).to eq(@str_plus)
      end

      it "then get replaced('+' -> '%2B') should also success" do
        expect(@upyun.get(@path_plus.gsub("+", "%2B"))).to eq(@str_plus)
      end

      it "after all, delete should success" do
        expect(@upyun.delete(@path_plus)).to be true
      end

      after(:all) { @upyun.delete(@path_plus) }
    end

    describe "PUT with '%20' encoded url path" do
      before(:all) do
        @path_20 = '/ruby-sdk/bar/%20/foo.txt'
        @str_20 = 'This is %20 string.'
      end

      it "should success" do
        expect(@upyun.put(@path_20, @str_20)).to be true
      end

      it "then get the same url should also success" do
        expect(@upyun.get(@path_20)).to eq(@str_20)
      end

      it "then get replaced('%20' -> ' ') should also success" do
        expect(@upyun.get(@path_20.gsub("%20", " "))).to eq(@str_20)
      end

      it "after all, delete should success" do
        expect(@upyun.delete(@path_20)).to be true
      end

      after(:all) { @upyun.delete(@path_20) }
    end

    describe "PUT with '[{}]' encoded url path" do
      before(:all) do
        @path_sq = '/ruby-sdk/bar/[f{o]/}o.txt'
        @str_sq = 'This is %sq string.'
      end

      it "should success" do
        expect(@upyun.put(@path_sq, @str_sq)).to be true
      end

      it "then get the same url should also success" do
        expect(@upyun.get(@path_sq)).to eq(@str_sq)
      end

      it "after all, delete should success" do
        expect(@upyun.delete(@path_sq)).to be true
      end

      after(:all) { @upyun.delete(@path_sq) }
    end

    it "Put a file to PICTURE bucket should return the image's metadata" do
      upyunp = Upyun::Rest.new('sdkimg', 'tester', 'grjxv2mxELR3', {}, Upyun::ED_TELECOM)
      metas = upyunp.put(@path, File.new(@file), content_type: 'image/jpeg')
      expect(metas).to include(:width, :height, :frames, :file_type)
      expect(metas[:width].is_a?(Integer))
      expect(metas[:height].is_a?(Integer))
      expect(metas[:frames].is_a?(Integer))
      expect(metas[:file_type].is_a?(String))
    end

    after { @upyun.delete(@path) }
  end

  describe ".get" do
    before :all do
      @path = "/ruby-sdk/foo/#{String.random}/test.jpg"
      @upyun.put(@path, @str, {'Content-Type' => 'text/plain'})
    end

    it "GET a file" do
      expect(@upyun.get(@path)).to eq(@str)
    end

    it "GET a file and save" do
      expect(@upyun.get(@path, './save.jpg')).to eq(@str.length)
      expect(File.exists?('./save.jpg')).to eq(true)
      expect(File.read('./save.jpg')).to eq(@str)
      File.delete('./save.jpg')
    end

    it "GET a file with Accept Header" do
      expect(@upyun.get(@path, nil, {'Accept' => '*/*'})).to eq(@str)
    end


    it "GET a not-exist file" do
      res = @upyun.get("/ruby-sdk/foo/#{String.random}/test-not-exist.jpg")
      expect(res.is_a?(Hash) && res[:error][:code] == 404)
      expect(res[:request_id]).to be_instance_of(String)
    end

    after(:all) { @upyun.delete(@path) }
  end

  describe ".getinfo" do
    before :all do
      @dir = "/ruby-sdk/foo/#{String.random}"
      @path = "#{@dir}/test.jpg"
      @upyun.put(@path, @str, {'Content-Type' => 'text/plain'})
    end

    it "of file should success" do
      res = @upyun.getinfo(@path)
      expect(res[:file_type]).to eq('file')
    end

    it "of folder should success" do
      res = @upyun.getinfo(@dir)
      expect(res[:file_type]).to eq('folder')
    end

    after(:all) { @upyun.delete(@path) }
  end

  describe ".delete" do
    before do
      @path = "/ruby-sdk/foo/#{String.random}/test.jpg"
      @upyun.put(@path, File.new(@file))
    end

    it "DELETE a file" do
      expect(@upyun.delete(@path)).to be true
    end
  end

  describe ".mkdir" do
    before(:all) { @path = "/ruby-sdk/foo/dir/#{String.random}" }

    it "should success" do
      expect(@upyun.mkdir(@path)).to be true
    end

    after(:all) { @upyun.delete(@path) }
  end

  describe ".getlist" do
    before :all do
      @dir = "/ruby-sdk/foo/#{String.random}"
      10.times { |i| @upyun.put("#@dir/#{i}", File.new(@file)) }
    end

    it "should get a list of file record" do
      expect(@upyun.getlist("/")).to be_instance_of(Array)
    end

    it "should return the correct number of records" do
      expect(@upyun.getlist(@dir).length).to eq(10)
    end

    after :all do
      10.times { |i| @upyun.delete("#@dir/#{i}") }
    end
  end

  describe ".usage" do
    it "should be an Fixnum" do
      expect(@upyun.usage).to be_instance_of(Fixnum)
    end
  end
end

describe "Form Upload", current: true do
  before :all do
    @form = Upyun::Form.new('ESxWIoMmF39nSDY7CSFUsC7s50U=', 'sdkfile')
    @file = File.expand_path('../upyun.jpg', __FILE__)
  end

  describe ".endpoint=" do
    it "known ENDPOINT, should return ok" do
      @form.endpoint = Upyun::ED_CMCC
      expect(@form.endpoint).to eq 'v3.api.upyun.com'
    end

    it "unknown ENDPOINT, should raise ArgumentError" do
      expect {@form.endpoint = 'v5.api.upyun.com'}.
        to raise_error(ArgumentError, /Valid endpoints/)
    end

    after { @form.endpoint = Upyun::ED_AUTO }
  end

  describe ".upload" do
    it "with file path should success" do
      res = @form.upload(@file)
      expect(res.keys).to include(:code, :message, :url, :time)
      expect(res[:code]).to eq(200)
      expect(res[:message]).to match(/ok/)
      expect(res[:url]).to eq(Time.now.utc.strftime('/%Y/%m/%d/upyun.jpg'))
    end

    it "with file descriptor should success" do
      fd = File.new(@file, 'rb')
      res = @form.upload(fd)
      expect(res.keys).to include(:code, :message, :url, :time)
      expect(res[:code]).to eq(200)
      expect(res[:message]).to match(/ok/)
      expect(res[:url]).to eq(Time.now.utc.strftime('/%Y/%m/%d/upyun.jpg'))
      expect(fd.closed?).to eq(true)
    end

    it "with default 'save-key' should return '%Y/%m/%d/{filename}{.suffix}'" do
      res = @form.upload(@file)
      expect(res[:url]).to eq(Time.now.utc.strftime('/%Y/%m/%d/upyun.jpg'))
    end

    it "set 'save-key' should success" do
      res = @form.upload(@file, {'save-key' => 'name-ed keypath'})
      expect(res[:code]).to eq(200)
      expect(res[:url]).to eq('name-ed keypath')
    end

    it "set not correct 'expiration' should return 403 with expired" do
      res = @form.upload(@file, {'expiration' => 102400})
      expect(res[:code]).to eq(403)
      expect(res[:message]).to match(/authorization has expired/)
    end

    it "set 'return-url' should return a hash" do
      res = @form.upload(@file, {'return-url' => 'http://www.example.com'})
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(200)
      expect(res[:time]).to be_instance_of(Fixnum)
      expect(res[:request_id]).to be_instance_of(String)
    end

    it "set 'return-url' and handle failed, should also return a hash" do
      opts = {
        'image-width-range' => '0,10',
        'return-url' => 'http://www.example.com'
      }
      res = @form.upload(@file, opts)
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(403)
      expect(res[:time]).to be_instance_of(Fixnum)
      expect(res[:request_id]).to be_instance_of(String)
    end

    it "set 'notify-url' should return 200 success" do
      res = @form.upload(@file, {'notify-url' => 'http://www.example.com'})
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(200)
    end

    it "set 'notify-url' and handle failed, should return 403 failed" do
      opts = {
        'image-width-range' => '0,10',
        'notify-url' => 'http://www.example.com'
      }
      res = @form.upload(@file, opts)
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(403)
    end
  end
end
